<?php

namespace App\Services;

use Midtrans\Config;
use Midtrans\Snap;
use Midtrans\Transaction;
use App\Models\Order;
use App\Models\Payment;
use Illuminate\Support\Facades\Log;

class MidtransService
{
    public function __construct()
    {
        // Configuration will be set when methods are called
    }

    private function setMidtransConfig()
    {
        $serverKey = config('midtrans.server_key');
        $clientKey = config('midtrans.client_key');
        
        // Debug: Check if keys exist
        if (empty($serverKey)) {
            Log::error('Midtrans server key is not configured', [
                'server_key' => $serverKey,
                'config_exists' => config('midtrans') !== null
            ]);
            throw new \Exception('Midtrans server key is not configured. Please check your .env file.');
        }

        if (empty($clientKey)) {
            Log::error('Midtrans client key is not configured');
            throw new \Exception('Midtrans client key is not configured. Please check your .env file.');
        }

        // Set configuration
        Config::$serverKey = $serverKey;
        Config::$clientKey = $clientKey;
        Config::$isProduction = config('midtrans.is_production', false);
        Config::$isSanitized = config('midtrans.is_sanitized', true);
        Config::$is3ds = config('midtrans.is_3ds', true);

        // Verify configuration was set
        if (empty(Config::$serverKey)) {
            Log::error('Failed to set Midtrans server key', [
                'original_key' => $serverKey,
                'config_key' => Config::$serverKey
            ]);
            throw new \Exception('Failed to set Midtrans configuration');
        }

        Log::info('Midtrans configuration set successfully', [
            'server_key_prefix' => substr($serverKey, 0, 10) . '...',
            'client_key_prefix' => substr($clientKey, 0, 10) . '...',
            'is_production' => Config::$isProduction,
            'config_server_key_set' => !empty(Config::$serverKey)
        ]);
    }

    public function testConfiguration()
    {
        try {
            $this->setMidtransConfig();
            
            return [
                'status' => 'success',
                'server_key_set' => !empty(Config::$serverKey),
                'client_key_set' => !empty(Config::$clientKey),
                'is_production' => Config::$isProduction,
                'server_key_prefix' => substr(Config::$serverKey, 0, 10) . '...'
            ];
        } catch (\Exception $e) {
            return [
                'status' => 'error',
                'message' => $e->getMessage()
            ];
        }
    }

    public function createSnapToken(Order $order, Payment $payment)
    {
        try {
            Log::info('Starting createSnapToken', [
                'order_id' => $order->id,
                'payment_id' => $payment->id,
                'transaction_id' => $payment->transaction_id
            ]);

            // Ensure config is set
            $this->setMidtransConfig();
            
            // Double check config after setting
            if (empty(\Midtrans\Config::$serverKey)) {
                throw new \Exception('Server key is still null after configuration');
            }

            Log::info('Config verified, proceeding with snap token creation');

            // Prepare transaction details
            $transactionDetails = [
                'order_id' => $payment->transaction_id,
                'gross_amount' => (int) $order->total_amount,
            ];

            // Prepare item details
            $itemDetails = [];
            foreach ($order->items as $item) {
                $itemDetails[] = [
                    'id' => $item->product_id,
                    'price' => (int) $item->price,
                    'quantity' => $item->quantity,
                    'name' => $item->product_name,
                ];
            }

            // Add shipping cost if exists
            $shippingCost = $order->total_amount - $order->items->sum('subtotal');
            if ($shippingCost > 0) {
                $itemDetails[] = [
                    'id' => 'shipping',
                    'price' => (int) $shippingCost,
                    'quantity' => 1,
                    'name' => 'Shipping Cost',
                ];
            }

            // Prepare customer details
            $nameParts = explode(' ', $order->shipping_name);
            $firstName = $nameParts[0] ?? '';
            $lastName = count($nameParts) > 1 ? implode(' ', array_slice($nameParts, 1)) : '';

            $customerDetails = [
                'first_name' => $firstName,
                'last_name' => $lastName,
                'email' => $order->user->email,
                'phone' => $order->user->phone ?? '',
                'billing_address' => [
                    'first_name' => $firstName,
                    'last_name' => $lastName,
                    'address' => $order->shipping_address,
                    'city' => $order->shipping_city,
                    'postal_code' => $order->shipping_postal_code,
                    'country_code' => 'IDN'
                ],
                'shipping_address' => [
                    'first_name' => $firstName,
                    'last_name' => $lastName,
                    'address' => $order->shipping_address,
                    'city' => $order->shipping_city,
                    'postal_code' => $order->shipping_postal_code,
                    'country_code' => 'IDN'
                ]
            ];

            // Enable payment methods
            $enabledPayments = [
                'credit_card',
                'bca_va',
                'bni_va', 
                'bri_va',
                'mandiri_va',
                'permata_va',
                'other_va',
                'gopay',
                'shopeepay',
                'dana',
                'ovo',
                'qris'
            ];

            // Build transaction data
            $transactionData = [
                'transaction_details' => $transactionDetails,
                'item_details' => $itemDetails,
                'customer_details' => $customerDetails,
                'enabled_payments' => $enabledPayments,
                'callbacks' => [
                    'finish' => route('midtrans.finish'),
                ]
            ];

            Log::info('Creating Snap token with data', [
                'transaction_details' => $transactionDetails,
                'customer_email' => $customerDetails['email']
            ]);

            // Create Snap Token
            $snapToken = Snap::getSnapToken($transactionData);
            
            // Update payment with snap token
            $payment->update([
                'snap_token' => $snapToken
            ]);

            Log::info('Snap token created successfully', [
                'order_id' => $order->id,
                'payment_id' => $payment->id,
                'snap_token' => $snapToken
            ]);

            return $snapToken;

        } catch (\Exception $e) {
            Log::error('Failed to create snap token', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'order_id' => $order->id ?? null,
                'payment_id' => $payment->id ?? null
            ]);
            throw $e;
        }
    }

    public function getTransactionStatus($transactionId)
    {
        try {
            $this->setMidtransConfig();
            return Transaction::status($transactionId);
        } catch (\Exception $e) {
            Log::error('Failed to get transaction status', [
                'transaction_id' => $transactionId,
                'error' => $e->getMessage()
            ]);
            throw $e;
        }
    }

    public function handleNotification($notification)
    {
        try {
            $this->setMidtransConfig();
            
            $transactionId = $notification['order_id'];
            $transactionStatus = $notification['transaction_status'];

            // Find payment by transaction ID
            $payment = Payment::where('transaction_id', $transactionId)->first();
            
            if (!$payment) {
                Log::warning('Payment not found for transaction', ['transaction_id' => $transactionId]);
                return false;
            }

            // Update payment based on status
            $this->updatePaymentStatus($payment, $notification);

            return true;

        } catch (\Exception $e) {
            Log::error('Failed to handle notification', [
                'error' => $e->getMessage(),
                'notification' => $notification
            ]);
            return false;
        }
    }

    private function updatePaymentStatus(Payment $payment, $notification)
    {
        $transactionStatus = $notification['transaction_status'];
        $fraudStatus = $notification['fraud_status'] ?? null;

        // Update payment fields
        $payment->midtrans_transaction_id = $notification['transaction_id'];
        $payment->midtrans_status = $transactionStatus;
        $payment->midtrans_response = json_encode($notification);

        // Determine payment status
        switch ($transactionStatus) {
            case 'capture':
                if ($fraudStatus == 'challenge') {
                    $payment->status = 'challenge';
                } else if ($fraudStatus == 'accept') {
                    $payment->status = 'success';
                    $payment->paid_at = now();
                    $payment->order->update(['status' => 'paid']);
                }
                break;
                
            case 'settlement':
                $payment->status = 'success';
                $payment->paid_at = now();
                $payment->order->update(['status' => 'paid']);
                break;
                
            case 'pending':
                $payment->status = 'pending';
                break;
                
            case 'deny':
                $payment->status = 'failed';
                $payment->order->update(['status' => 'cancelled']);
                break;
                
            case 'expire':
                $payment->status = 'expired';
                $payment->order->update(['status' => 'cancelled']);
                break;
                
            case 'cancel':
                $payment->status = 'cancelled';
                $payment->order->update(['status' => 'cancelled']);
                break;
        }

        $payment->save();

        Log::info('Payment status updated', [
            'payment_id' => $payment->id,
            'status' => $payment->status,
            'transaction_status' => $transactionStatus
        ]);
    }
}