<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Services\MidtransService;
use App\Models\Order;
use App\Models\Payment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class MidtransController extends Controller
{
    protected $midtransService;

    public function __construct(MidtransService $midtransService)
    {
        $this->midtransService = $midtransService;
    }

    public function paymentProcess($orderId, $snapToken = null)
    {
        try {
            $order = Order::where('id', $orderId)
                          ->where('user_id', Auth::id())
                          ->with('items')
                          ->firstOrFail();

            $payment = Payment::where('order_id', $order->id)->first();

            // If no snap token provided, try to create one
            if (!$snapToken && $payment && !$payment->snap_token) {
                try {
                    $snapToken = $this->midtransService->createSnapToken($order, $payment);
                } catch (\Exception $e) {
                    Log::error('Failed to create snap token in paymentProcess', [
                        'error' => $e->getMessage(),
                        'order_id' => $orderId
                    ]);
                    return redirect()->route('checkout.index')
                                   ->with('error', 'Failed to initialize payment: ' . $e->getMessage());
                }
            } elseif ($payment && $payment->snap_token) {
                $snapToken = $payment->snap_token;
            }

            return view('checkout.payment-process', compact('order', 'payment', 'snapToken'));

        } catch (\Exception $e) {
            Log::error('Error loading payment process', [
                'error' => $e->getMessage(),
                'order_id' => $orderId
            ]);
            return redirect()->route('checkout.index')->with('error', 'Order not found');
        }
    }

    public function notification(Request $request)
    {
        try {
            $notification = $request->all();
            
            Log::info('Midtrans notification received', $notification);
            
            $result = $this->midtransService->handleNotification($notification);
            
            if ($result) {
                return response()->json(['status' => 'ok']);
            } else {
                return response()->json(['status' => 'error'], 400);
            }

        } catch (\Exception $e) {
            Log::error('Error handling Midtrans notification', [
                'error' => $e->getMessage(),
                'notification' => $request->all()
            ]);
            
            return response()->json(['status' => 'error'], 500);
        }
    }

    public function finish(Request $request)
    {
        try {
            $orderId = $request->get('order_id');
            $transactionStatus = $request->get('transaction_status');
            
            Log::info('Midtrans finish callback', [
                'order_id' => $orderId,
                'transaction_status' => $transactionStatus,
                'all_params' => $request->all()
            ]);
            
            // Redirect based on status
            if (in_array($transactionStatus, ['capture', 'settlement'])) {
                // Parse order ID to get actual order ID (if it contains prefix)
                $actualOrderId = $orderId;
                if (strpos($orderId, '-') !== false) {
                    $parts = explode('-', $orderId);
                    $actualOrderId = end($parts);
                }
                
                return redirect()->route('checkout.success', ['order' => $actualOrderId]);
            } else {
                return redirect()->route('checkout.index')
                               ->with('error', 'Payment was not successful. Status: ' . $transactionStatus);
            }

        } catch (\Exception $e) {
            Log::error('Error in finish callback', [
                'error' => $e->getMessage(),
                'request_data' => $request->all()
            ]);
            return redirect()->route('checkout.index')->with('error', 'Something went wrong');
        }
    }

    public function checkStatus($transactionId)
    {
        try {
            $status = $this->midtransService->getTransactionStatus($transactionId);
            return response()->json($status);

        } catch (\Exception $e) {
            Log::error('Error checking transaction status', [
                'transaction_id' => $transactionId,
                'error' => $e->getMessage()
            ]);
            
            return response()->json(['error' => 'Failed to check status'], 500);
        }
    }

    // Method untuk test konfigurasi
    public function testConfig()
    {
        return response()->json($this->midtransService->testConfiguration());
    }
}