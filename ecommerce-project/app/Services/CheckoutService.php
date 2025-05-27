<?php

namespace App\Services;

use App\Models\Address;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class CheckoutService
{
    protected $cartService;

    public function __construct(CartService $cartService)
    {
        $this->cartService = $cartService;
    }

    public function validateCustomerInfo(Request $request): array
    {
        return $request->validate([
            'first_name' => 'required|string|max:255',
            'last_name' => 'required|string|max:255',
            'email' => 'required|email|max:255',
            'phone' => 'required|string|max:20',
            'address_id' => 'nullable|exists:addresses,id',
        ]);
    }

    public function storeCustomerInfo(array $data): void
    {
        session()->put('checkout.customer_info', $data);
    }

    public function validateDeliveryInfo(Request $request): array
    {
        return $request->validate([
            'delivery_method' => 'required|string|in:standard,express',
            'address' => 'required|string',
            'city' => 'required|string',
            'state' => 'required|string',
            'postal_code' => 'required|string',
            'country' => 'required|string',
        ]);
    }

    public function storeDeliveryInfo(array $data): void
    {
        session()->put('checkout.delivery', $data);
        
        // Create address if needed
        $customerInfo = session('checkout.customer_info');
        if (empty($customerInfo['address_id'])) {
            $address = Address::create([
                'user_id' => Auth::id(),
                'street_address' => $data['address'],
                'city' => $data['city'],
                'state' => $data['state'],
                'postal_code' => $data['postal_code'],
                'country' => $data['country'],
                'is_default' => false
            ]);
            
            $customerInfo['address_id'] = $address->id;
            session()->put('checkout.customer_info', $customerInfo);
        }
    }

    public function validatePaymentInfo(Request $request): array
    {
        $rules = [
            'payment_method' => 'required|string|in:midtrans,bank_transfer',
            'payment_details' => 'nullable|string',
            'total' => 'required|numeric|min:0',
        ];

        $validated = $request->validate($rules);

        // Verify total amount
        $expectedTotal = $this->calculateExpectedTotal();
        if (abs($validated['total'] - $expectedTotal) > 0.01) {
            throw new \Exception('Total amount mismatch. Please refresh and try again.');
        }

        return $validated;
    }

    public function storePaymentInfo(array $data): void
    {
        session()->put('checkout.payment', [
            'payment_method' => $data['payment_method'],
            'payment_details' => $data['payment_details'] ?? null
        ]);
    }

    public function hasCustomerInfo(): bool
    {
        return session()->has('checkout.customer_info');
    }

    public function hasRequiredSessionData(): bool
    {
        return $this->hasCustomerInfo() && session()->has('checkout.delivery');
    }

    public function hasCompleteSessionData(): bool
    {
        return $this->hasRequiredSessionData() && session()->has('checkout.payment');
    }

    public function canCompleteOrder(): bool
    {
        if (!$this->hasCompleteSessionData()) {
            return false;
        }

        $payment = session('checkout.payment');
        return $payment['payment_method'] === 'bank_transfer';
    }

    public function getDeliveryPageData(): array
    {
        $customerInfo = session('checkout.customer_info');
        $cart = $this->cartService->getCart();
        $total = $this->cartService->calculateCartTotal();
        
        $deliveryOptions = [
            'standard' => ['name' => 'Standard Delivery', 'price' => 5.00, 'days' => '3-5'],
            'express' => ['name' => 'Express Delivery', 'price' => 15.00, 'days' => '1-2'],
        ];

        return compact('customerInfo', 'cart', 'total', 'deliveryOptions');
    }

    public function getPaymentPageData(): array
    {
        $cart = $this->cartService->getCart();
        
        if (!$this->cartService->isCartValid($cart)) {
            throw new \Exception('Cart is empty or invalid');
        }

        $customerInfo = session('checkout.customer_info');
        $delivery = session('checkout.delivery');
        $subtotal = $this->cartService->calculateCartTotal();
        $deliveryCost = $delivery['delivery_method'] === 'express' ? 15.00 : 5.00;
        $total = $subtotal + $deliveryCost;

        $paymentMethods = [
            'midtrans' => 'Midtrans Payment Gateway',
            'bank_transfer' => 'Manual Bank Transfer',
        ];

        return compact(
            'customerInfo', 'delivery', 'cart', 'subtotal', 
            'deliveryCost', 'total', 'paymentMethods'
        );
    }

    public function getConfirmationPageData(): array
    {
        $cart = $this->cartService->getCart();
        
        if (!$this->cartService->isCartValid($cart)) {
            throw new \Exception('Cart is empty or invalid');
        }

        $customerInfo = session('checkout.customer_info');
        $delivery = session('checkout.delivery');
        $payment = session('checkout.payment');
        
        $subtotal = $this->cartService->calculateCartTotal();
        $deliveryCost = $delivery['delivery_method'] === 'express' ? 15.00 : 5.00;
        $total = $subtotal + $deliveryCost;

        $address = Address::findOrFail($customerInfo['address_id']);
        
        $deliveryMethods = [
            'standard' => ['name' => 'Standard Delivery', 'price' => 5.00, 'days' => '3-5'],
            'express' => ['name' => 'Express Delivery', 'price' => 15.00, 'days' => '1-2'],
        ];

        $paymentMethods = [
            'midtrans' => 'Midtrans Payment Gateway',
            'bank_transfer' => 'Manual Bank Transfer',
        ];

        $orderPreview = $this->createOrderPreview($customerInfo, $address, $payment, $cart, $total);

        return compact(
            'customerInfo', 'delivery', 'payment', 'cart', 'subtotal',
            'deliveryCost', 'total', 'address', 'deliveryMethods', 
            'paymentMethods', 'orderPreview'
        );
    }

    public function prepareOrderData(): array
    {
        $customerInfo = session('checkout.customer_info');
        $delivery = session('checkout.delivery');
        $payment = session('checkout.payment');
        
        $cart = $this->cartService->getCart();
        $address = Address::findOrFail($customerInfo['address_id']);
        
        $subtotal = $this->cartService->calculateCartTotal();
        $deliveryCost = $delivery['delivery_method'] === 'express' ? 15.00 : 5.00;
        $total = $subtotal + $deliveryCost;

        return [
            'user_id' => Auth::id(),
            'address_id' => $customerInfo['address_id'],
            'total_amount' => $total,
            'subtotal' => $subtotal,
            'delivery_cost' => $deliveryCost,
            'status' => 'pending',
            'shipping_name' => trim($customerInfo['first_name'] . ' ' . $customerInfo['last_name']),
            'shipping_address' => $address->street_address,
            'shipping_city' => $address->city,
            'shipping_state' => $address->state,
            'shipping_postal_code' => $address->postal_code,
            'shipping_country' => $address->country,
            'payment_method' => $payment['payment_method'],
            'cart_items' => $cart->cartItems,
            'delivery_method' => $delivery['delivery_method']
        ];
    }

    public function getProgress(): array
    {
        return [
            'customer_info' => session()->has('checkout.customer_info'),
            'delivery' => session()->has('checkout.delivery'),
            'payment' => session()->has('checkout.payment'),
        ];
    }

    public function clearSession(): void
    {
        session()->forget([
            'checkout.customer_info',
            'checkout.delivery',
            'checkout.payment'
        ]);
    }

    private function calculateExpectedTotal(): float
    {
        $delivery = session('checkout.delivery');
        $subtotal = $this->cartService->calculateCartTotal();
        $deliveryCost = $delivery['delivery_method'] === 'express' ? 15.00 : 5.00;
        
        return $subtotal + $deliveryCost;
    }

    private function createOrderPreview($customerInfo, $address, $payment, $cart, $total): \stdClass
    {
        $orderPreview = new \stdClass();
        $orderPreview->order_number = 'ORD-' . date('Ymd') . '-' . strtoupper(substr(md5(uniqid()), 0, 8));
        $orderPreview->created_at = now();
        $orderPreview->shipping_name = $customerInfo['first_name'] . ' ' . $customerInfo['last_name'];
        $orderPreview->shipping_address = $address->street_address;
        $orderPreview->shipping_city = $address->city;
        $orderPreview->shipping_state = $address->state;
        $orderPreview->shipping_postal_code = $address->postal_code;
        $orderPreview->shipping_country = $address->country;
        $orderPreview->payment_method = $payment['payment_method'];
        $orderPreview->total_amount = $total;
        
        $orderPreview->items = collect($cart->cartItems)->map(function($item) {
            return (object)[
                'product_name' => $item->product->name,
                'quantity' => $item->quantity,
                'price' => $item->product->price,
                'subtotal' => $item->quantity * $item->product->price
            ];
        });

        return $orderPreview;
    }
}