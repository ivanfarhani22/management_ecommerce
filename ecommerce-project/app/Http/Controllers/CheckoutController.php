<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Services\OrderService;
use App\Services\CartService;
use App\Models\Address;
use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class CheckoutController extends Controller
{
    protected $orderService;
    protected $cartService;

    public function __construct(OrderService $orderService, CartService $cartService)
    {
        $this->orderService = $orderService;
        $this->cartService = $cartService;
    }

    public function index()
    {
        $cart = $this->cartService->getCart();
        $total = $this->cartService->calculateCartTotal();
        $addresses = Auth::user()->addresses;

        return view('checkout.index', compact('cart', 'total', 'addresses'));
    }

    public function processCustomerInfo(Request $request)
    {
        $request->validate([
            'first_name' => 'required|string|max:255',
            'last_name' => 'required|string|max:255',
            'email' => 'required|email|max:255',
            'phone' => 'required|string|max:20',
            'address_id' => 'nullable|exists:addresses,id',
        ]);

        session()->put('checkout.customer_info', $request->only([
            'first_name', 'last_name', 'email', 'phone', 'address_id'
        ]));

        return redirect()->route('checkout.delivery');
    }

    public function delivery()
    {
        $customerInfo = session('checkout.customer_info');

        if (!$customerInfo) {
            return redirect()->route('checkout.index')
                ->with('error', 'Please complete customer information first.');
        }

        $cart = $this->cartService->getCart();
        $total = $this->cartService->calculateCartTotal();
        $deliveryOptions = [
            'standard' => ['name' => 'Standard Delivery', 'price' => 5.00, 'days' => '3-5'],
            'express' => ['name' => 'Express Delivery', 'price' => 15.00, 'days' => '1-2'],
        ];

        return view('checkout.delivery', compact('customerInfo', 'cart', 'total', 'deliveryOptions'));
    }

    public function storeDelivery(Request $request)
    {
        $request->validate([
            'delivery_method' => 'required|string|in:standard,express',
            'address' => 'required|string',
            'city' => 'required|string',
            'state' => 'required|string',
            'postal_code' => 'required|string',
            'country' => 'required|string',
        ]);

        // Store delivery info in session
        $deliveryInfo = $request->only([
            'delivery_method', 'address', 'city', 'state', 'postal_code', 'country'
        ]);
        
        session()->put('checkout.delivery', $deliveryInfo);
        
        // Create a new address if no address_id is selected
        $customerInfo = session('checkout.customer_info');
        if (empty($customerInfo['address_id'])) {
            $address = new Address([
                'user_id' => Auth::id(),
                'street_address' => $request->address,
                'city' => $request->city,
                'state' => $request->state,
                'postal_code' => $request->postal_code,
                'country' => $request->country,
                'is_default' => false
            ]);
            $address->save();
            
            // Update customer info with the new address ID
            $customerInfo['address_id'] = $address->id;
            session()->put('checkout.customer_info', $customerInfo);
        }

        return redirect()->route('checkout.payment');
    }

    public function payment()
    {
        $customerInfo = session('checkout.customer_info');
        $delivery = session('checkout.delivery');

        if (!$customerInfo || !$delivery) {
            return redirect()->route('checkout.index')
                ->with('error', 'Please complete previous steps first.');
        }

        $cart = $this->cartService->getCart();
        $subtotal = $this->cartService->calculateCartTotal();
        
        // Calculate delivery cost based on selected method
        $deliveryCost = $delivery['delivery_method'] === 'express' ? 15.00 : 5.00;
        $total = $subtotal + $deliveryCost;

        $paymentMethods = [
            'credit_card' => 'Credit Card',
            'paypal' => 'PayPal',
            'bank_transfer' => 'Bank Transfer',
        ];

        return view('checkout.payment', compact(
            'customerInfo', 'delivery', 'cart', 'subtotal', 'deliveryCost', 'total', 'paymentMethods'
        ));
    }

    public function storePayment(Request $request)
    {
        $request->validate([
            'payment_method' => 'required|string|in:credit_card,paypal,bank_transfer',
            'payment_details' => 'nullable|string',
        ]);

        session()->put('checkout.payment', $request->only(['payment_method', 'payment_details']));

        return redirect()->route('checkout.confirmation');
    }

    public function confirmation()
    {
        $customerInfo = session('checkout.customer_info');
        $delivery = session('checkout.delivery');
        $payment = session('checkout.payment');

        if (!$customerInfo || !$delivery || !$payment) {
            return redirect()->route('checkout.index')
                ->with('error', 'Please complete previous steps first.');
        }

        $cart = $this->cartService->getCart();
        $subtotal = $this->cartService->calculateCartTotal();
        
        // Calculate delivery cost based on selected method
        $deliveryCost = $delivery['delivery_method'] === 'express' ? 15.00 : 5.00;
        $total = $subtotal + $deliveryCost;

        // Get address details
        $address = Address::find($customerInfo['address_id']);

        $deliveryMethods = [
            'standard' => ['name' => 'Standard Delivery', 'price' => 5.00, 'days' => '3-5'],
            'express' => ['name' => 'Express Delivery', 'price' => 15.00, 'days' => '1-2'],
        ];

        $paymentMethods = [
            'credit_card' => 'Credit Card',
            'paypal' => 'PayPal',
            'bank_transfer' => 'Bank Transfer',
        ];

        // Create an order preview object with the necessary properties
        $orderPreview = new \stdClass();
        $orderPreview->order_number = 'ORD-' . strtoupper(substr(md5(uniqid()), 0, 8));
        $orderPreview->created_at = now();
        $orderPreview->shipping_name = $customerInfo['first_name'] . ' ' . $customerInfo['last_name'];
        $orderPreview->shipping_address = $address->street_address;
        $orderPreview->shipping_city = $address->city;
        $orderPreview->shipping_state = $address->state;
        $orderPreview->shipping_postal_code = $address->postal_code;
        $orderPreview->shipping_country = $address->country;
        $orderPreview->payment_method = $payment['payment_method'];
        $orderPreview->total_amount = $total;
        
        $cartItems = $cart->cartItems;
        $orderPreview->items = collect($cartItems)->map(function($item) {
            return (object)[
                'product_name' => $item->product->name,
                'quantity' => $item->quantity,
                'price' => $item->product->price,
                'subtotal' => $item->quantity * $item->product->price
            ];
        });
        
        return view('checkout.confirmation', compact(
            'customerInfo', 'delivery', 'payment', 'cart', 'subtotal',
            'deliveryCost', 'total', 'address', 'deliveryMethods', 'paymentMethods', 'orderPreview'
        ));
    }

    public function success($orderId)
{
    try {
        // Cari order dan pastikan milik user yang login
        $order = Order::where('id', $orderId)
                      ->where('user_id', Auth::id())
                      ->firstOrFail();
        
        // Muat order items
        $order->load('items');
        
        // Log untuk debugging
        Log::info('Viewing success page', ['order_id' => $order->id, 'items_count' => $order->items->count()]);
        
        return view('checkout.success', compact('order'));
    } catch (\Exception $e) {
        Log::error('Error viewing success page', ['error' => $e->getMessage()]);
        return redirect()->route('orders.index')->with('error', 'Order not found');
    }
}

public function complete(Request $request)
{
    $customerInfo = session('checkout.customer_info');
    $delivery = session('checkout.delivery');
    $payment = session('checkout.payment');

    if (!$customerInfo || !$delivery || !$payment) {
        return redirect()->route('checkout.index')
            ->with('error', 'Please complete all checkout steps first.');
    }

    try {
        // Debug logs
        Log::info('Attempting to create order', [
            'customerInfo' => $customerInfo, 
            'delivery' => $delivery, 
            'payment' => $payment
        ]);
        
        // Calculate cart total
        $cart = $this->cartService->getCart();
        
        // Periksa apakah keranjang kosong
        if (!$cart || !$cart->cartItems || $cart->cartItems->isEmpty()) {
            Log::error('Cart is empty or items missing', ['cart' => $cart]);
            return redirect()->route('cart.index')
                ->with('error', 'Your cart is empty. Please add items before checkout.');
        }
        
        $subtotal = $this->cartService->calculateCartTotal();
        $deliveryCost = $delivery['delivery_method'] === 'express' ? 15.00 : 5.00;
        $total = $subtotal + $deliveryCost;
        
        // Get address
        $address = Address::find($customerInfo['address_id']);
        if (!$address) {
            throw new \Exception('Delivery address not found');
        }
        
        // Buat transaksi database untuk memastikan integritas data
        \DB::beginTransaction();
        
        // Create the order
        $order = new Order([
            'user_id' => Auth::id(),
            'address_id' => $customerInfo['address_id'],
            'total_amount' => $total,
            'status' => 'pending',
            'shipping_name' => $customerInfo['first_name'] . ' ' . $customerInfo['last_name'],
            'shipping_address' => $address->street_address,
            'shipping_city' => $address->city,
            'shipping_state' => $address->state,
            'shipping_postal_code' => $address->postal_code,
            'shipping_country' => $address->country,
            'payment_method' => $payment['payment_method'],
            'order_number' => 'ORD-' . strtoupper(substr(md5(uniqid()), 0, 8))
        ]);
        $order->save();
        
        // Logging untuk debugging
        Log::info('Order created', ['order_id' => $order->id]);
        
        // Create order items - pastikan ini berjalan
        foreach ($cart->cartItems as $cartItem) {
            Log::info('Processing cart item', ['cart_item_id' => $cartItem->id, 'product' => $cartItem->product->name]);
            
            $orderItem = new OrderItem([
                'order_id' => $order->id,
                'product_id' => $cartItem->product_id,
                'quantity' => $cartItem->quantity,
                'price' => $cartItem->product->price,
                'subtotal' => $cartItem->quantity * $cartItem->product->price,
                'product_name' => $cartItem->product->name
            ]);
            $orderItem->save();
            
            Log::info('Order item created', ['order_item_id' => $orderItem->id]);
        }
        
        // Create payment record
        $paymentRecord = new \App\Models\Payment([
            'order_id' => $order->id,
            'payment_method' => $payment['payment_method'],
            'amount' => $total,
            'status' => 'pending',
            'transaction_id' => 'TXN-' . strtoupper(substr(md5(uniqid()), 0, 12))
        ]);
        $paymentRecord->save();
        
        // Commit transaksi
        \DB::commit();
        
        Log::info('Order creation completed successfully', ['order_id' => $order->id]);

        // Clear checkout session data
        session()->forget(['checkout.customer_info', 'checkout.delivery', 'checkout.payment']);
        
        // Clear the cart
        $this->cartService->clearCart();

        // Redirect to success page with order
        return redirect()->route('checkout.success', ['order' => $order->id]);
        
    } catch (\Exception $e) {
        // Rollback transaksi jika ada error
        \DB::rollBack();
        
        Log::error('Order creation failed', [
            'error' => $e->getMessage(), 
            'trace' => $e->getTraceAsString()
        ]);
        
        return back()->with('error', 'Order creation failed: ' . $e->getMessage());
    }
}
}