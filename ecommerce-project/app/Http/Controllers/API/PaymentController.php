<?php

namespace App\Http\Controllers\API;

use App\Models\Order;
use App\Models\Payment;
use App\Services\PaymentService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

use App\Http\Controllers\Controller;

class PaymentController extends Controller
{
    protected $paymentService;

    /**
     * Create a new controller instance.
     *
     * @param PaymentService $paymentService
     */
    public function __construct(PaymentService $paymentService)
    {
        $this->paymentService = $paymentService;
    }

    /**
     * Display a listing of payments.
     *
     * @return JsonResponse
     */
    public function index(): JsonResponse
    {
        try {
            $payments = Payment::with('order')->get();
            return response()->json([
                'success' => true,
                'data' => $payments
            ], 200);
        } catch (\Exception $e) {
            Log::error('Failed to retrieve payments: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve payments',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Display the specified payment.
     *
     * @param int $id
     * @return JsonResponse
     */
    public function show($id): JsonResponse
    {
        try {
            $payment = Payment::with('order')->findOrFail($id);
            return response()->json([
                'success' => true,
                'data' => $payment
            ], 200);
        } catch (\Exception $e) {
            Log::error('Failed to retrieve payment: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Payment not found',
                'error' => $e->getMessage()
            ], 404);
        }
    }

    /**
     * Process a new payment.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function process(Request $request): JsonResponse
    {
        // Log incoming request for debugging
        Log::info('Payment process request received', [
            'request_data' => $request->all(),
            'headers' => $request->headers->all()
        ]);
        
        // Updated validator to include additional payment methods from the app
        $validator = Validator::make($request->all(), [
            'order_id' => 'required|exists:orders,id',
            'payment_method' => 'required|string|in:stripe,paypal,bank_transfer,cash,credit_card',
            'stripe_token' => 'required_if:payment_method,stripe',
        ]);

        if ($validator->fails()) {
            Log::warning('Payment validation failed', ['errors' => $validator->errors()]);
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $order = Order::findOrFail($request->order_id);
            $payment = $this->paymentService->processPayment($order, $request->payment_method);

            Log::info('Payment processed successfully', ['payment_id' => $payment->id]);
            return response()->json([
                'success' => true,
                'message' => 'Payment processed successfully',
                'data' => $payment
            ], 201);
        } catch (\Exception $e) {
            Log::error('Payment processing failed: ' . $e->getMessage(), [
                'exception' => $e
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Payment processing failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Process an offline payment.
     * This is a new method to handle offline payment methods from the app.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function processOffline(Request $request): JsonResponse
    {
        // Log incoming request for debugging
        Log::info('Offline payment process request received', [
            'request_data' => $request->all()
        ]);
        
        $validator = Validator::make($request->all(), [
            'order_id' => 'required|exists:orders,id',
            'payment_method' => 'required|string|in:bank_transfer,cash,credit_card',
            'amount' => 'required|numeric|min:0',
            'transaction_id' => 'nullable|string',
            'reference' => 'nullable|string',
            'transaction_date' => 'nullable|date',
        ]);

        if ($validator->fails()) {
            Log::warning('Offline payment validation failed', ['errors' => $validator->errors()]);
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $order = Order::findOrFail($request->order_id);
            
            // Create a new payment record
            $payment = new Payment();
            $payment->order_id = $order->id;
            $payment->amount = $request->amount;
            $payment->payment_method = $request->payment_method;
            $payment->status = 'completed';
            $payment->transaction_id = $request->transaction_id ?? 'OFFLINE-' . time();
            $payment->reference = $request->reference;
            $payment->transaction_date = $request->transaction_date ?? now();
            $payment->save();

            // Update order status if necessary
            $order->payment_status = 'paid';
            $order->save();

            Log::info('Offline payment processed successfully', ['payment_id' => $payment->id]);
            return response()->json([
                'success' => true,
                'message' => 'Offline payment processed successfully',
                'data' => $payment
            ], 201);
        } catch (\Exception $e) {
            Log::error('Offline payment processing failed: ' . $e->getMessage(), [
                'exception' => $e
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Payment processing failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Refund a payment.
     *
     * @param int $id
     * @return JsonResponse
     */
    public function refund($id): JsonResponse
    {
        try {
            $payment = Payment::findOrFail($id);
            $refundedPayment = $this->paymentService->refundPayment($payment);

            return response()->json([
                'success' => true,
                'message' => 'Payment refunded successfully',
                'data' => $refundedPayment
            ], 200);
        } catch (\Exception $e) {
            Log::error('Payment refund failed: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Payment refund failed',
                'error' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Get payments by order ID.
     *
     * @param int $orderId
     * @return JsonResponse
     */
    public function getByOrder($orderId): JsonResponse
    {
        try {
            $payments = Payment::where('order_id', $orderId)->get();
            return response()->json([
                'success' => true,
                'data' => $payments
            ], 200);
        } catch (\Exception $e) {
            Log::error('Failed to retrieve payments for order: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve payments for this order',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get payments by status.
     *
     * @param string $status
     * @return JsonResponse
     */
    public function getByStatus($status): JsonResponse
    {
        $validator = Validator::make(['status' => $status], [
            'status' => 'required|in:pending,completed,failed,refunded',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid status',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $payments = Payment::where('status', $status)->with('order')->get();
            return response()->json([
                'success' => true,
                'data' => $payments
            ], 200);
        } catch (\Exception $e) {
            Log::error('Failed to retrieve payments by status: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve payments',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}