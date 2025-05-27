<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Services\OrderService;
use App\Services\CartService;
use App\Services\MidtransService;
use App\Services\CheckoutService;
use App\Models\Address;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class CheckoutController extends Controller
{
    protected $checkoutService;
    protected $cartService;
    protected $orderService;
    protected $midtransService;

    public function __construct(
        CheckoutService $checkoutService,
        CartService $cartService,
        OrderService $orderService,
        MidtransService $midtransService
    ) {
        $this->checkoutService = $checkoutService;
        $this->cartService = $cartService;
        $this->orderService = $orderService;
        $this->midtransService = $midtransService;
    }

    public function index()
    {
        try {
            $cart = $this->cartService->getCart();
            
            if (!$this->cartService->isCartValid($cart)) {
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
            $validatedData = $this->checkoutService->validateCustomerInfo($request);
            $this->checkoutService->storeCustomerInfo($validatedData);

            return redirect()->route('checkout.delivery');
        } catch (\Exception $e) {
            Log::error('Process customer info error: ' . $e->getMessage());
            return back()->withErrors(['error' => 'Failed to process customer information.']);
        }
    }

    public function delivery()
    {
        try {
            if (!$this->checkoutService->hasCustomerInfo()) {
                return redirect()->route('checkout.index')
                    ->with('error', 'Please complete customer information first.');
            }

            $data = $this->checkoutService->getDeliveryPageData();
            return view('checkout.delivery', $data);
        } catch (\Exception $e) {
            Log::error('Checkout delivery error: ' . $e->getMessage());
            return redirect()->route('checkout.index')
                ->with('error', 'Unable to load delivery page.');
        }
    }

    public function storeDelivery(Request $request)
    {
        try {
            $validatedData = $this->checkoutService->validateDeliveryInfo($request);
            $this->checkoutService->storeDeliveryInfo($validatedData);

            return redirect()->route('checkout.payment');
        } catch (\Exception $e) {
            Log::error('Store delivery error: ' . $e->getMessage());
            return back()->withErrors(['error' => 'Failed to save delivery information.']);
        }
    }

    public function payment()
    {
        try {
            if (!$this->checkoutService->hasRequiredSessionData()) {
                return redirect()->route('checkout.index')
                    ->with('error', 'Please complete previous steps first.');
            }

            $data = $this->checkoutService->getPaymentPageData();
            return view('checkout.payment', $data);
        } catch (\Exception $e) {
            Log::error('Checkout payment page error: ' . $e->getMessage());
            return redirect()->route('checkout.index')
                ->with('error', 'Unable to load payment page.');
        }
    }

    public function storePayment(Request $request)
    {
        try {
            $validatedData = $this->checkoutService->validatePaymentInfo($request);
            $this->checkoutService->storePaymentInfo($validatedData);

            if ($validatedData['payment_method'] === 'midtrans') {
                return $this->processMidtransPayment($request);
            }

            if ($request->ajax()) {
                return response()->json([
                    'success' => true,
                    'redirect' => route('checkout.confirmation')
                ]);
            }

            return redirect()->route('checkout.confirmation');
            
        } catch (\Exception $e) {
            Log::error('Store payment error: ' . $e->getMessage());
            
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
        try {
            $orderData = $this->checkoutService->prepareOrderData();
            $order = $this->orderService->createOrder($orderData);
            
            $snapToken = $this->midtransService->createSnapToken($order, $order->payment);
            
            if (!$snapToken) {
                throw new \Exception('Failed to create Midtrans snap token');
            }

            $this->checkoutService->clearSession();
            $this->cartService->clearCart();

            if ($request && $request->ajax()) {
                return response()->json([
                    'success' => true,
                    'snap_token' => $snapToken,
                    'order_id' => $order->id,
                    'redirect' => route('midtrans.payment.process', [
                        'order' => $order->id,
                        'snap_token' => $snapToken
                    ])
                ]);
            }

            return redirect()->route('midtrans.payment.process', [
                'order' => $order->id,
                'snap_token' => $snapToken
            ]);

        } catch (\Exception $e) {
            Log::error('Midtrans payment process failed: ' . $e->getMessage());
            
            if ($request && $request->ajax()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Payment process failed: ' . $e->getMessage()
                ], 500);
            }
            
            return back()->with('error', 'Payment process failed: ' . $e->getMessage());
        }
    }

    public function midtransPaymentProcess(Request $request)
    {
        try {
            $orderId = $request->route('order');
            $snapToken = $request->route('snap_token');

            if (!$orderId || !$snapToken) {
                throw new \Exception('Missing order ID or snap token');
            }

            $order = Order::where('id', $orderId)
                         ->where('user_id', Auth::id())
                         ->with(['items', 'payment'])
                         ->firstOrFail();

            $config = $this->midtransService->getClientConfig();

            return view('checkout.midtrans-payment', compact(
                'order', 'snapToken'
            ) + $config);

        } catch (\Exception $e) {
            Log::error('Error loading Midtrans payment page: ' . $e->getMessage());
            return redirect()->route('checkout.index')
                ->with('error', 'Unable to load payment page: ' . $e->getMessage());
        }
    }

    public function confirmation()
    {
        try {
            if (!$this->checkoutService->hasCompleteSessionData()) {
                return redirect()->route('checkout.index')
                    ->with('error', 'Please complete previous steps first.');
            }

            $data = $this->checkoutService->getConfirmationPageData();
            return view('checkout.confirmation', $data);
        } catch (\Exception $e) {
            Log::error('Checkout confirmation error: ' . $e->getMessage());
            return redirect()->route('checkout.index')
                ->with('error', 'Unable to load confirmation page.');
        }
    }

    public function complete(Request $request)
    {
        try {
            if (!$this->checkoutService->canCompleteOrder()) {
                return redirect()->route('checkout.index')
                    ->with('error', 'Please complete all checkout steps first.');
            }

            $orderData = $this->checkoutService->prepareOrderData();
            $order = $this->orderService->createOrder($orderData);

            $this->checkoutService->clearSession();
            $this->cartService->clearCart();

            return redirect()->route('checkout.success', $order->id)
                ->with('success', 'Order placed successfully! Please complete your bank transfer payment.');
                
        } catch (\Exception $e) {
            Log::error('Complete order error: ' . $e->getMessage());
            return back()->with('error', 'Failed to complete order: ' . $e->getMessage());
        }
    }

    public function success($orderId)
    {
        try {
            $order = Order::where('id', $orderId)
                          ->where('user_id', Auth::id())
                          ->with(['items', 'payment'])
                          ->firstOrFail();
            
            return view('checkout.success', compact('order'));
        } catch (\Exception $e) {
            Log::error('Error viewing success page: ' . $e->getMessage());
            return redirect()->route('orders.index')->with('error', 'Order not found');
        }
    }

    // Payment callback handlers
    public function midtransCallback(Request $request)
    {
        try {
            Log::info('Midtrans callback received', ['payload' => $request->all()]);
            
            $result = $this->midtransService->handleNotification($request->all());
            
            return $result 
                ? response('OK', 200)
                : response('Error processing notification', 500);
                
        } catch (\Exception $e) {
            Log::error('Midtrans callback error: ' . $e->getMessage());
            return response('Error processing callback', 500);
        }
    }

    public function midtransFinish(Request $request)
    {
        return $this->handleMidtransRedirect($request, 'finish');
    }

    public function midtransUnfinish(Request $request)
    {
        return $this->handleMidtransRedirect($request, 'unfinish');
    }

    public function midtransError(Request $request)
    {
        return $this->handleMidtransRedirect($request, 'error');
    }

    private function handleMidtransRedirect(Request $request, string $type)
    {
        try {
            $orderId = $request->query('order_id');
            $redirectService = new \App\Services\MidtransRedirectService();
            
            return $redirectService->handle($type, $orderId, $request->all());
            
        } catch (\Exception $e) {
            Log::error("Midtrans {$type} redirect error: " . $e->getMessage());
            return redirect()->route('cart.index')
                ->with('error', 'Error processing payment redirect.');
        }
    }

    // Order management
    public function retryPayment(Order $order)
    {
        try {
            $this->orderService->validateOrderOwnership($order);
            $this->orderService->validateRetryability($order);
            
            $snapToken = $this->orderService->retryPayment($order);
            
            return redirect()->route('midtrans.payment.process', [
                'order' => $order->id,
                'snap_token' => $snapToken
            ]);
            
        } catch (\Exception $e) {
            Log::error('Retry payment error: ' . $e->getMessage());
            return redirect()->route('orders.show', $order->id)
                ->with('error', 'Failed to retry payment: ' . $e->getMessage());
        }
    }

    public function cancelOrder(Order $order)
    {
        try {
            $this->orderService->validateOrderOwnership($order);
            $this->orderService->cancelOrder($order);
            
            return redirect()->route('orders.index')
                ->with('success', 'Order has been cancelled successfully.');
                
        } catch (\Exception $e) {
            Log::error('Cancel order error: ' . $e->getMessage());
            return redirect()->route('orders.show', $order->id)
                ->with('error', 'Failed to cancel order: ' . $e->getMessage());
        }
    }

    // AJAX endpoints
    public function getProgress()
    {
        return response()->json($this->checkoutService->getProgress());
    }

    public function clearSession()
    {
        try {
            $this->checkoutService->clearSession();
            
            return response()->json([
                'success' => true,
                'message' => 'Checkout session cleared successfully'
            ]);
            
        } catch (\Exception $e) {
            Log::error('Clear checkout session error: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Failed to clear session'
            ], 500);
        }
    }
}