<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Services\OrderService;
use App\Services\CartService;
use App\Services\MidtransService;
use App\Models\Address;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Payment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class CheckoutController extends Controller
{
    protected $orderService;
    protected $cartService;
    protected $midtransService;

    public function __construct(OrderService $orderService, CartService $cartService, MidtransService $midtransService)
    {
        $this->orderService = $orderService;
        $this->cartService = $cartService;
        $this->midtransService = $midtransService;
    }

    public function index()
    {
        try {
            $cart = $this->cartService->getCart();
            
            // Check if cart is empty
            if (!$cart || !$cart->cartItems || $cart->cartItems->isEmpty()) {
                return redirect()->route('cart.index')
                    ->with('error', 'Your cart is empty. Please add items before checkout.');
            }
            
            $total = $this->cartService->calculateCartTotal();
            $addresses = Auth::user()->addresses;

            return view('checkout.index', compact('cart', 'total', 'addresses'));
        } catch (\Exception $e) {
            Log::error('Checkout index error: ' . $e->getMessage());
            return redirect()->route('cart.index')
                ->with('error', 'Unable to load checkout page. Please try again.');
        }
    }

    public function processCustomerInfo(Request $request)
    {
        try {
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
        } catch (\Exception $e) {
            Log::error('Process customer info error: ' . $e->getMessage());
            return back()->withErrors(['error' => 'Failed to process customer information.']);
        }
    }

    public function delivery()
    {
        try {
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
        } catch (\Exception $e) {
            Log::error('Checkout delivery error: ' . $e->getMessage());
            return redirect()->route('checkout.index')
                ->with('error', 'Unable to load delivery page.');
        }
    }

    public function storeDelivery(Request $request)
    {
        try {
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
        } catch (\Exception $e) {
            Log::error('Store delivery error: ' . $e->getMessage());
            return back()->withErrors(['error' => 'Failed to save delivery information.']);
        }
    }

    public function payment()
    {
        try {
            $customerInfo = session('checkout.customer_info');
            $delivery = session('checkout.delivery');

            if (!$customerInfo || !$delivery) {
                return redirect()->route('checkout.index')
                    ->with('error', 'Please complete previous steps first.');
            }

            $cart = $this->cartService->getCart();
            
            // Check if cart is still valid
            if (!$cart || !$cart->cartItems || $cart->cartItems->isEmpty()) {
                return redirect()->route('cart.index')
                    ->with('error', 'Your cart is empty. Please add items before checkout.');
            }
            
            $subtotal = $this->cartService->calculateCartTotal();
            
            // Calculate delivery cost based on selected method
            $deliveryCost = $delivery['delivery_method'] === 'express' ? 15.00 : 5.00;
            $total = $subtotal + $deliveryCost;

            $paymentMethods = [
                'midtrans' => 'Midtrans Payment Gateway',
                'bank_transfer' => 'Manual Bank Transfer',
            ];

            return view('checkout.payment', compact(
                'customerInfo', 'delivery', 'cart', 'subtotal', 'deliveryCost', 'total', 'paymentMethods'
            ));
        } catch (\Exception $e) {
            Log::error('Checkout payment page error: ' . $e->getMessage());
            return redirect()->route('checkout.index')
                ->with('error', 'Unable to load payment page.');
        }
    }

    public function storePayment(Request $request)
    {
        try {
            Log::info('Store payment method called', ['request_data' => $request->all()]);

            $request->validate([
                'payment_method' => 'required|string|in:midtrans,bank_transfer',
                'payment_details' => 'nullable|string',
                'total' => 'required|numeric|min:0',
            ]);

            $customerInfo = session('checkout.customer_info');
            $delivery = session('checkout.delivery');

            if (!$customerInfo || !$delivery) {
                Log::error('Session data missing', [
                    'customer_info' => $customerInfo,
                    'delivery' => $delivery
                ]);
                
                if ($request->ajax()) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Session expired. Please complete previous steps first.',
                        'redirect' => route('checkout.index')
                    ], 400);
                }
                
                return redirect()->route('checkout.index')
                    ->with('error', 'Please complete previous steps first.');
            }

            // Verify cart is still valid
            $cart = $this->cartService->getCart();
            if (!$cart || !$cart->cartItems || $cart->cartItems->isEmpty()) {
                Log::error('Cart is empty during payment processing');
                
                if ($request->ajax()) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Your cart is empty. Please add items before checkout.',
                        'redirect' => route('cart.index')
                    ], 400);
                }
                
                return redirect()->route('cart.index')
                    ->with('error', 'Your cart is empty. Please add items before checkout.');
            }

            // Verify total amount matches calculated total
            $subtotal = $this->cartService->calculateCartTotal();
            $deliveryCost = $delivery['delivery_method'] === 'express' ? 15.00 : 5.00;
            $expectedTotal = $subtotal + $deliveryCost;

            if (abs($request->total - $expectedTotal) > 0.01) {
                Log::error('Total amount mismatch', [
                    'expected' => $expectedTotal,
                    'received' => $request->total
                ]);
                
                if ($request->ajax()) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Total amount mismatch. Please refresh and try again.'
                    ], 400);
                }
                
                return back()->with('error', 'Total amount mismatch. Please refresh and try again.');
            }

            // Store payment info in session
            session()->put('checkout.payment', $request->only(['payment_method', 'payment_details']));

            Log::info('Payment method selected', ['method' => $request->payment_method]);

            // If midtrans payment, create order and redirect to payment process
            if ($request->payment_method === 'midtrans') {
                return $this->processMidtransPayment($request);
            }

            // For manual bank transfer, go to confirmation
            if ($request->ajax()) {
                return response()->json([
                    'success' => true,
                    'redirect' => route('checkout.confirmation')
                ]);
            }

            return redirect()->route('checkout.confirmation');
            
        } catch (\Illuminate\Validation\ValidationException $e) {
            Log::error('Validation error in store payment', ['errors' => $e->errors()]);
            
            if ($request->ajax()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $e->errors()
                ], 422);
            }
            
            return back()->withErrors($e->errors());
            
        } catch (\Exception $e) {
            Log::error('Store payment error: ' . $e->getMessage(), [
                'trace' => $e->getTraceAsString()
            ]);
            
            if ($request->ajax()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Payment processing failed: ' . $e->getMessage()
                ], 500);
            }
            
            return back()->with('error', 'Payment processing failed: ' . $e->getMessage());
        }
    }

    protected function processMidtransPayment($request = null)
    {
        $customerInfo = session('checkout.customer_info');
        $delivery = session('checkout.delivery');
        $payment = session('checkout.payment');

        try {
            Log::info('Starting Midtrans payment process');

            // Calculate totals
            $cart = $this->cartService->getCart();
            
            // Double check cart validity
            if (!$cart || !$cart->cartItems || $cart->cartItems->isEmpty()) {
                throw new \Exception('Cart is empty or invalid');
            }
            
            $subtotal = $this->cartService->calculateCartTotal();
            $deliveryCost = $delivery['delivery_method'] === 'express' ? 15.00 : 5.00;
            $total = $subtotal + $deliveryCost;

            // Get address
            $address = Address::find($customerInfo['address_id']);
            if (!$address) {
                throw new \Exception('Delivery address not found');
            }

            // Start database transaction
            DB::beginTransaction();

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

            Log::info('Order created for Midtrans payment', ['order_id' => $order->id]);

            // Create order items
            foreach ($cart->cartItems as $cartItem) {
                if (!$cartItem->product) {
                    throw new \Exception('Product not found for cart item: ' . $cartItem->id);
                }
                
                $orderItem = new OrderItem([
                    'order_id' => $order->id,
                    'product_id' => $cartItem->product_id,
                    'quantity' => $cartItem->quantity,
                    'price' => $cartItem->product->price,
                    'subtotal' => $cartItem->quantity * $cartItem->product->price,
                    'product_name' => $cartItem->product->name
                ]);
                $orderItem->save();
            }

            // Create payment record
            $paymentRecord = new Payment([
                'order_id' => $order->id,
                'payment_method' => $payment['payment_method'],
                'amount' => $total,
                'status' => 'pending',
                'transaction_id' => 'TXN-' . strtoupper(substr(md5(uniqid()), 0, 12))
            ]);
            $paymentRecord->save();

            // Create Midtrans Snap Token
            $snapToken = $this->midtransService->createSnapToken($order, $paymentRecord);

            if (!$snapToken) {
                throw new \Exception('Failed to create Midtrans snap token');
            }

            // Commit transaction
            DB::commit();

            Log::info('Midtrans payment process initiated successfully', [
                'order_id' => $order->id, 
                'snap_token' => $snapToken
            ]);

            // Clear checkout session data
            session()->forget(['checkout.customer_info', 'checkout.delivery', 'checkout.payment']);
            
            // Clear the cart
            $this->cartService->clearCart();

            // Return JSON response for AJAX requests
            if ($request && $request->ajax()) {
                return response()->json([
                    'success' => true,
                    'redirect' => route('midtrans.payment.process', [
                        'order' => $order->id,
                        'snap_token' => $snapToken
                    ])
                ]);
            }

            // Redirect to Midtrans payment process
            return redirect()->route('midtrans.payment.process', [
                'order' => $order->id,
                'snap_token' => $snapToken
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            
            Log::error('Midtrans payment process failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            // Return JSON response for AJAX requests
            if ($request && $request->ajax()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Payment process failed: ' . $e->getMessage()
                ], 500);
            }
            
            return back()->with('error', 'Payment process failed: ' . $e->getMessage());
        }
    }

    public function confirmation()
    {
        try {
            $customerInfo = session('checkout.customer_info');
            $delivery = session('checkout.delivery');
            $payment = session('checkout.payment');

            if (!$customerInfo || !$delivery || !$payment) {
                return redirect()->route('checkout.index')
                    ->with('error', 'Please complete previous steps first.');
            }

            $cart = $this->cartService->getCart();
            
            // Check if cart is still valid
            if (!$cart || !$cart->cartItems || $cart->cartItems->isEmpty()) {
                return redirect()->route('cart.index')
                    ->with('error', 'Your cart is empty. Please add items before checkout.');
            }
            
            $subtotal = $this->cartService->calculateCartTotal();
            
            // Calculate delivery cost based on selected method
            $deliveryCost = $delivery['delivery_method'] === 'express' ? 15.00 : 5.00;
            $total = $subtotal + $deliveryCost;

            // Get address details
            $address = Address::find($customerInfo['address_id']);
            
            if (!$address) {
                return redirect()->route('checkout.index')
                    ->with('error', 'Delivery address not found. Please select an address.');
            }

            $deliveryMethods = [
                'standard' => ['name' => 'Standard Delivery', 'price' => 5.00, 'days' => '3-5'],
                'express' => ['name' => 'Express Delivery', 'price' => 15.00, 'days' => '1-2'],
            ];

            $paymentMethods = [
                'midtrans' => 'Midtrans Payment Gateway',
                'bank_transfer' => 'Manual Bank Transfer',
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
        } catch (\Exception $e) {
            Log::error('Checkout confirmation error: ' . $e->getMessage());
            return redirect()->route('checkout.index')
                ->with('error', 'Unable to load confirmation page.');
        }
    }

    public function success($orderId)
    {
        try {
            // Find order and ensure it belongs to logged in user
            $order = Order::where('id', $orderId)
                          ->where('user_id', Auth::id())
                          ->firstOrFail();
            
            // Load order items
            $order->load('items');
            
            // Log for debugging
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

        // Only handle manual bank transfer here (Midtrans is handled in storePayment)
        if ($payment['payment_method'] !== 'bank_transfer') {
            return redirect()->route('checkout.index')
                ->with('error', 'Invalid payment method for this process.');
        }

        try {
            // Debug logs
            Log::info('Attempting to create order for bank transfer', [
                'customerInfo' => $customerInfo, 
                'delivery' => $delivery, 
                'payment' => $payment
            ]);
            
            // Calculate cart total
            $cart = $this->cartService->getCart();
            
            // Check if cart is empty
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
            
            // Start database transaction to ensure data integrity
            DB::beginTransaction();
            
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
            
            // Logging for debugging
            Log::info('Order created', ['order_id' => $order->id]);
            
            // Create order items
            foreach ($cart->cartItems as $cartItem) {
                if (!$cartItem->product) {
                    throw new \Exception('Product not found for cart item: ' . $cartItem->id);
                }
                
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
            $paymentRecord = new Payment([
                'order_id' => $order->id,
                'payment_method' => $payment['payment_method'],
                'amount' => $total,
                'status' => 'pending',
                'transaction_id' => 'TXN-' . strtoupper(substr(md5(uniqid()), 0, 12))
            ]);
            $paymentRecord->save();

            // Commit transaction
            DB::commit();

            Log::info('Order creation completed successfully', ['order_id' => $order->id]);

            // Clear checkout session data
            session()->forget(['checkout.customer_info', 'checkout.delivery', 'checkout.payment']);
            
            // Clear the cart
            $this->cartService->clearCart();

            // Redirect to success page for bank transfer
            return redirect()->route('checkout.success', ['order' => $order->id]);
            
        } catch (\Exception $e) {
            // Rollback transaction if error occurs
            DB::rollBack();
            
            Log::error('Order creation failed', [
                'error' => $e->getMessage(), 
                'trace' => $e->getTraceAsString()
            ]);
            
            return back()->with('error', 'Order creation failed: ' . $e->getMessage());
        }
    }
}