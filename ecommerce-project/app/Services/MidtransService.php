<?php

namespace App\Services;

use App\Models\Order;
use App\Models\Payment;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Config;

class MidtransService
{
    private $serverKey;
    private $clientKey;
    private $isProduction;
    private $apiUrl;
    private $snapUrl;

    public function __construct()
    {
        $this->serverKey = config('midtrans.server_key');
        $this->clientKey = config('midtrans.client_key');
        $this->isProduction = config('midtrans.is_production', false);
        
        // Set API URL based on environment
        $this->apiUrl = $this->isProduction 
            ? 'https://api.midtrans.com/v2' 
            : 'https://api.stg.midtrans.com/v2';

        // Set Snap API URL for token creation
        $this->snapUrl = $this->isProduction 
            ? 'https://app.midtrans.com/snap/v1/transactions' 
            : 'https://app.stg.midtrans.com/snap/v1/transactions';
            
        Log::info('MidtransService initialized', [
            'is_production' => $this->isProduction,
            'api_url' => $this->apiUrl,
            'snap_url' => $this->snapUrl,
            'has_server_key' => !empty($this->serverKey),
            'has_client_key' => !empty($this->clientKey)
        ]);
    }

    public function createSnapToken($order, $payment)
    {
        try {
            Log::info('Creating Midtrans Snap Token', [
                'order_id' => $order->id,
                'order_number' => $order->order_number,
                'payment_id' => $payment->id,
                'amount' => $payment->amount
            ]);

            // Validate required data
            if (!$this->serverKey) {
                throw new \Exception('Midtrans server key not configured');
            }

            if (!$order || !$payment) {
                throw new \Exception('Order or payment data is missing');
            }

            // Ensure order_number exists and is not empty
            if (empty($order->order_number)) {
                throw new \Exception('Order number is required but empty');
            }

            // Load order items and user relationship
            $order->load(['items', 'user']);

            // Validate that order has items
            if ($order->items->isEmpty()) {
                throw new \Exception('Order must have at least one item');
            }

            // Prepare item details first to calculate total
            $itemDetails = [];
            $totalItemAmount = 0;

            foreach ($order->items as $item) {
                // Ensure product name is not empty
                $productName = !empty($item->product_name) ? $item->product_name : 'Product';
                
                $itemPrice = (int) round($item->price);
                $itemDetails[] = [
                    'id' => (string) $item->product_id,
                    'price' => $itemPrice,
                    'quantity' => $item->quantity,
                    'name' => substr($productName, 0, 50) // Ensure name is not empty and within limit
                ];
                $totalItemAmount += $itemPrice * $item->quantity;
            }

            // Add shipping cost if any
            $paymentAmount = (int) round($payment->amount);
            $shippingCost = $paymentAmount - $totalItemAmount;
            
            if ($shippingCost > 0) {
                $itemDetails[] = [
                    'id' => 'shipping',
                    'price' => $shippingCost,
                    'quantity' => 1,
                    'name' => 'Shipping Cost'
                ];
                $totalItemAmount += $shippingCost;
            } elseif ($shippingCost < 0) {
                // If there's a discount, add it as negative amount
                $itemDetails[] = [
                    'id' => 'discount',
                    'price' => $shippingCost, // This will be negative
                    'quantity' => 1,
                    'name' => 'Discount'
                ];
                $totalItemAmount += $shippingCost;
            }

            // Ensure gross_amount matches sum of item_details
            if ($totalItemAmount !== $paymentAmount) {
                Log::warning('Amount mismatch detected, adjusting', [
                    'payment_amount' => $paymentAmount,
                    'calculated_total' => $totalItemAmount,
                    'difference' => $paymentAmount - $totalItemAmount
                ]);
                
                // Add adjustment item if there's still a difference
                $difference = $paymentAmount - $totalItemAmount;
                if ($difference !== 0) {
                    $itemDetails[] = [
                        'id' => 'adjustment',
                        'price' => $difference,
                        'quantity' => 1,
                        'name' => $difference > 0 ? 'Additional Fee' : 'Adjustment'
                    ];
                }
            }

            // Prepare transaction details
            $transactionDetails = [
                'order_id' => $order->order_number, // Ensure this is not empty
                'gross_amount' => $paymentAmount // Use payment amount as gross amount
            ];

            // Prepare customer details
            $firstName = '';
            $lastName = '';
            
            if (!empty($order->shipping_name)) {
                $nameParts = explode(' ', trim($order->shipping_name));
                $firstName = $nameParts[0] ?? '';
                $lastName = implode(' ', array_slice($nameParts, 1)) ?: '';
            }
            
            // Ensure required fields are not empty
            $firstName = !empty($firstName) ? substr($firstName, 0, 20) : 'Customer';
            $lastName = !empty($lastName) ? substr($lastName, 0, 20) : '';
            
            $customerDetails = [
                'first_name' => $firstName,
                'last_name' => $lastName,
                'email' => $order->user->email ?? 'customer@example.com',
                'phone' => $order->user->phone ?? '',
                'billing_address' => [
                    'first_name' => $firstName,
                    'last_name' => $lastName,
                    'address' => !empty($order->shipping_address) ? substr($order->shipping_address, 0, 200) : 'Address not provided',
                    'city' => !empty($order->shipping_city) ? substr($order->shipping_city, 0, 20) : 'City',
                    'postal_code' => !empty($order->shipping_postal_code) ? substr($order->shipping_postal_code, 0, 10) : '12345',
                    'phone' => $order->user->phone ?? '',
                    'country_code' => 'IDN'
                ],
                'shipping_address' => [
                    'first_name' => $firstName,
                    'last_name' => $lastName,
                    'address' => !empty($order->shipping_address) ? substr($order->shipping_address, 0, 200) : 'Address not provided',
                    'city' => !empty($order->shipping_city) ? substr($order->shipping_city, 0, 20) : 'City',
                    'postal_code' => !empty($order->shipping_postal_code) ? substr($order->shipping_postal_code, 0, 10) : '12345',
                    'phone' => $order->user->phone ?? '',
                    'country_code' => 'IDN'
                ]
            ];

            // Prepare callbacks - using the routes defined in CheckoutController
            $callbacks = [
                'finish' => route('midtrans.finish') . '?order_id=' . $order->id,
                'unfinish' => route('midtrans.unfinish') . '?order_id=' . $order->id,
                'error' => route('midtrans.error') . '?order_id=' . $order->id
            ];

            // Prepare the request payload
            $payload = [
                'transaction_details' => $transactionDetails,
                'item_details' => $itemDetails,
                'customer_details' => $customerDetails,
                'enabled_payments' => [
                    'credit_card', 'bca_va', 'bni_va', 'bri_va', 'permata_va', 
                    'other_va', 'gopay', 'shopeepay', 'indomaret', 'alfamart'
                ],
                'callbacks' => $callbacks,
                'expiry' => [
                    'start_time' => date('Y-m-d H:i:s O'),
                    'unit' => 'hours',
                    'duration' => 24
                ]
            ];

            // Validate payload before sending
            $this->validatePayload($payload);

            Log::info('Midtrans payload prepared', [
                'order_number' => $transactionDetails['order_id'],
                'gross_amount' => $transactionDetails['gross_amount'],
                'items_count' => count($itemDetails),
                'total_item_amount' => array_sum(array_map(function($item) {
                    return $item['price'] * $item['quantity'];
                }, $itemDetails)),
                'customer_email' => $customerDetails['email']
            ]);

            // Make API request to Midtrans Snap
            $response = Http::withHeaders([
                'Accept' => 'application/json',
                'Content-Type' => 'application/json',
                'Authorization' => 'Basic ' . base64_encode($this->serverKey . ':')
            ])->post($this->snapUrl, $payload);

            Log::info('Midtrans Snap API Response', [
                'status' => $response->status(),
                'response_body' => $response->successful() ? 'Success' : $response->body()
            ]);

            if (!$response->successful()) {
                Log::error('Midtrans Snap API Error', [
                    'status' => $response->status(),
                    'response' => $response->body(),
                    'payload' => $payload
                ]);
                throw new \Exception('Midtrans API request failed: ' . $response->body());
            }

            $responseData = $response->json();

            if (!isset($responseData['token'])) {
                Log::error('Midtrans token not found in response', ['response' => $responseData]);
                throw new \Exception('Snap token not found in Midtrans response');
            }

            // Update payment with snap token and redirect URL
            $payment->update([
                'snap_token' => $responseData['token'],
                'redirect_url' => $responseData['redirect_url'] ?? null,
                'midtrans_transaction_id' => $order->order_number // Store order number as transaction ID initially
            ]);

            Log::info('Snap token created successfully', [
                'token' => substr($responseData['token'], 0, 20) . '...',
                'order_id' => $order->id,
                'order_number' => $order->order_number
            ]);

            return $responseData['token'];

        } catch (\Exception $e) {
            Log::error('Error creating Midtrans snap token', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'order_id' => $order->id ?? null,
                'order_number' => $order->order_number ?? null
            ]);
            throw $e;
        }
    }

    /**
     * Validate payload before sending to Midtrans
     */
    private function validatePayload($payload)
    {
        // Check transaction_details
        if (empty($payload['transaction_details']['order_id'])) {
            throw new \Exception('Transaction order_id is required');
        }

        if (!isset($payload['transaction_details']['gross_amount']) || $payload['transaction_details']['gross_amount'] <= 0) {
            throw new \Exception('Transaction gross_amount is required and must be greater than 0');
        }

        // Check item_details
        if (empty($payload['item_details'])) {
            throw new \Exception('Item details are required');
        }

        $totalItemAmount = 0;
        foreach ($payload['item_details'] as $item) {
            if (empty($item['name'])) {
                throw new \Exception('Item name is required for all items');
            }
            if (!isset($item['price']) || !isset($item['quantity'])) {
                throw new \Exception('Item price and quantity are required');
            }
            $totalItemAmount += $item['price'] * $item['quantity'];
        }

        // Check if gross_amount equals sum of item_details
        if ($totalItemAmount !== $payload['transaction_details']['gross_amount']) {
            throw new \Exception(
                'Transaction gross_amount (' . $payload['transaction_details']['gross_amount'] . 
                ') must equal sum of item_details (' . $totalItemAmount . ')'
            );
        }

        Log::info('Payload validation passed', [
            'gross_amount' => $payload['transaction_details']['gross_amount'],
            'total_items' => $totalItemAmount,
            'items_count' => count($payload['item_details'])
        ]);
    }

    public function handleNotification($notification)
    {
        try {
            Log::info('Midtrans notification received', $notification);

            // Extract notification data
            $orderId = $notification['order_id'] ?? null;
            $statusCode = $notification['status_code'] ?? null;
            $grossAmount = $notification['gross_amount'] ?? null;
            $transactionStatus = $notification['transaction_status'] ?? '';
            $transactionId = $notification['transaction_id'] ?? null;
            $fraudStatus = $notification['fraud_status'] ?? '';
            
            // Verify notification authenticity
            $serverKey = $this->serverKey;
            $signatureKey = hash('sha512', $orderId . $statusCode . $grossAmount . $serverKey);
            
            if ($signatureKey !== ($notification['signature_key'] ?? '')) {
                Log::error('Invalid signature in Midtrans notification', [
                    'expected' => $signatureKey,
                    'received' => $notification['signature_key'] ?? 'not_provided'
                ]);
                throw new \Exception('Invalid signature');
            }

            Log::info('Midtrans notification signature verified', ['order_id' => $orderId]);

            // Find order by order_number (which is used as order_id in Midtrans)
            $order = Order::where('order_number', $orderId)->first();
            if (!$order) {
                Log::error('Order not found for notification', ['order_number' => $orderId]);
                throw new \Exception('Order not found');
            }

            // Find payment for this order
            $payment = Payment::where('order_id', $order->id)->first();
            if (!$payment) {
                Log::error('Payment not found for order', ['order_id' => $order->id]);
                throw new \Exception('Payment not found');
            }

            Log::info('Processing payment status update', [
                'order_id' => $order->id,
                'order_number' => $order->order_number,
                'transaction_status' => $transactionStatus,
                'fraud_status' => $fraudStatus,
                'current_payment_status' => $payment->status,
                'current_order_status' => $order->status
            ]);

            // Update payment and order status based on transaction status
            $oldPaymentStatus = $payment->status;
            $oldOrderStatus = $order->status;

            switch ($transactionStatus) {
                case 'capture':
                    if ($fraudStatus == 'challenge') {
                        $payment->status = 'challenge';
                        $order->status = 'pending';
                    } else if ($fraudStatus == 'accept') {
                        $payment->status = 'settlement';
                        $order->status = 'processing';
                    }
                    break;
                    
                case 'settlement':
                    $payment->status = 'settlement';
                    $order->status = 'processing';
                    break;
                    
                case 'pending':
                    $payment->status = 'pending';
                    $order->status = 'pending';
                    break;
                    
                case 'deny':
                    $payment->status = 'failed';
                    $order->status = 'failed';
                    break;
                    
                case 'expire':
                    $payment->status = 'expired';
                    $order->status = 'failed';
                    break;
                    
                case 'cancel':
                    $payment->status = 'cancelled';
                    $order->status = 'cancelled';
                    break;

                case 'refund':
                    $payment->status = 'refunded';
                    $order->status = 'refunded';
                    break;

                default:
                    Log::warning('Unknown transaction status', [
                        'transaction_status' => $transactionStatus,
                        'order_id' => $order->id
                    ]);
                    break;
            }

            // Update transaction ID and timestamps
            if ($transactionId) {
                $payment->midtrans_transaction_id = $transactionId;
            }

            // Set paid_at timestamp for successful payments
            if (in_array($payment->status, ['settlement', 'capture']) && !$payment->paid_at) {
                $payment->paid_at = now();
            }

            // Save changes
            $payment->save();
            $order->save();

            Log::info('Payment and order status updated successfully', [
                'order_id' => $order->id,
                'order_number' => $order->order_number,
                'payment_status_change' => $oldPaymentStatus . ' -> ' . $payment->status,
                'order_status_change' => $oldOrderStatus . ' -> ' . $order->status,
                'transaction_id' => $transactionId,
                'paid_at' => $payment->paid_at
            ]);

            return true;

        } catch (\Exception $e) {
            Log::error('Error handling Midtrans notification', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'notification' => $notification
            ]);
            throw $e;
        }
    }

    /**
     * Get payment status from Midtrans API
     */
    public function getPaymentStatus($orderNumber)
    {
        try {
            $response = Http::withHeaders([
                'Accept' => 'application/json',
                'Content-Type' => 'application/json',
                'Authorization' => 'Basic ' . base64_encode($this->serverKey . ':')
            ])->get($this->apiUrl . '/' . $orderNumber . '/status');

            if ($response->successful()) {
                return $response->json();
            }

            Log::error('Failed to get payment status from Midtrans', [
                'order_number' => $orderNumber,
                'status' => $response->status(),
                'response' => $response->body()
            ]);

            return null;

        } catch (\Exception $e) {
            Log::error('Error getting payment status', [
                'error' => $e->getMessage(),
                'order_number' => $orderNumber
            ]);
            return null;
        }
    }

    /**
     * Cancel transaction
     */
    public function cancelTransaction($orderNumber)
    {
        try {
            $response = Http::withHeaders([
                'Accept' => 'application/json',
                'Content-Type' => 'application/json',
                'Authorization' => 'Basic ' . base64_encode($this->serverKey . ':')
            ])->post($this->apiUrl . '/' . $orderNumber . '/cancel');

            if ($response->successful()) {
                Log::info('Transaction cancelled successfully', ['order_number' => $orderNumber]);
                return $response->json();
            }

            Log::error('Failed to cancel transaction', [
                'order_number' => $orderNumber,
                'status' => $response->status(),
                'response' => $response->body()
            ]);

            return null;

        } catch (\Exception $e) {
            Log::error('Error cancelling transaction', [
                'error' => $e->getMessage(),
                'order_number' => $orderNumber
            ]);
            return null;
        }
    }

    /**
     * Get client key for frontend
     */
    public function getClientKey()
    {
        return $this->clientKey;
    }

    /**
     * Get Snap.js URL for frontend
     */
    public function getSnapUrl()
    {
        return $this->isProduction 
            ? 'https://app.midtrans.com/snap/snap.js' 
            : 'https://app.stg.midtrans.com/snap/snap.js';
    }

    /**
     * Check if service is in production mode
     */
    public function isProduction()
    {
        return $this->isProduction;
    }

    /**
     * Get server key (for internal use)
     */
    public function getServerKey()
    {
        return $this->serverKey;
    }

    /**
     * Validate Midtrans configuration
     */
    public function validateConfiguration()
    {
        $errors = [];

        if (empty($this->serverKey)) {
            $errors[] = 'Midtrans server key is not configured';
        }

        if (empty($this->clientKey)) {
            $errors[] = 'Midtrans client key is not configured';
        }

        if (!empty($errors)) {
            Log::error('Midtrans configuration validation failed', ['errors' => $errors]);
            throw new \Exception('Midtrans configuration is incomplete: ' . implode(', ', $errors));
        }

        Log::info('Midtrans configuration validated successfully');
        return true;
    }
}