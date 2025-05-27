<?php

namespace App\Services;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Payment;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class OrderService
{
    protected $midtransService;

    public function __construct(MidtransService $midtransService)
    {
        $this->midtransService = $midtransService;
    }

    public function createOrder(array $orderData): Order
    {
        return DB::transaction(function () use ($orderData) {
            // Generate unique order number
            $orderNumber = $this->generateOrderNumber();
            
            // Create the order
            $order = Order::create([
                'user_id' => $orderData['user_id'],
                'address_id' => $orderData['address_id'],
                'total_amount' => $orderData['total_amount'],
                'status' => $orderData['status'],
                'shipping_name' => $orderData['shipping_name'],
                'shipping_address' => $orderData['shipping_address'],
                'shipping_city' => $orderData['shipping_city'],
                'shipping_state' => $orderData['shipping_state'],
                'shipping_postal_code' => $orderData['shipping_postal_code'],
                'shipping_country' => $orderData['shipping_country'],
                'payment_method' => $orderData['payment_method'],
                'order_number' => $orderNumber,
                'delivery_method' => $orderData['delivery_method'] ?? 'standard',
                'subtotal' => $orderData['subtotal'] ?? 0,
                'delivery_cost' => $orderData['delivery_cost'] ?? 0,
            ]);

            Log::info('Order created', ['order_id' => $order->id, 'order_number' => $orderNumber]);

            // Create order items
            foreach ($orderData['cart_items'] as $cartItem) {
                if (!$cartItem->product) {
                    throw new \Exception('Product not found for cart item: ' . $cartItem->id);
                }
                
                OrderItem::create([
                    'order_id' => $order->id,
                    'product_id' => $cartItem->product_id,
                    'quantity' => $cartItem->quantity,
                    'price' => $cartItem->product->price,
                    'subtotal' => $cartItem->quantity * $cartItem->product->price,
                    'product_name' => $cartItem->product->name
                ]);
            }

            // Create payment record
            $payment = Payment::create([
                'order_id' => $order->id,
                'payment_method' => $orderData['payment_method'],
                'amount' => $orderData['total_amount'],
                'status' => 'pending',
                'transaction_id' => $orderNumber
            ]);

            // Load relationships
            $order->load(['items', 'payment']);

            Log::info('Order and payment created successfully', [
                'order_id' => $order->id,
                'payment_id' => $payment->id
            ]);

            return $order;
        });
    }

    public function validateOrderOwnership(Order $order): void
    {
        if ($order->user_id !== Auth::id()) {
            throw new \Exception('Unauthorized access to order.');
        }
    }

    public function validateRetryability(Order $order): void
    {
        if (!in_array($order->status, ['pending', 'failed'])) {
            throw new \Exception('This order cannot be retried.');
        }
        
        if ($order->payment_method !== 'midtrans') {
            throw new \Exception('Payment retry is only available for Midtrans payments.');
        }
    }

    public function retryPayment(Order $order): string
    {
        Log::info('Retrying payment for order', ['order_id' => $order->id]);
        
        $payment = $order->payment;
        if (!$payment) {
            $payment = Payment::create([
                'order_id' => $order->id,
                'payment_method' => 'midtrans',
                'amount' => $order->total_amount,
                'status' => 'pending',
                'transaction_id' => $order->order_number
            ]);
        }
        
        // Generate new snap token
        $snapToken = $this->midtransService->createSnapToken($order, $payment);
        
        if (!$snapToken) {
            throw new \Exception('Failed to create payment token');
        }
        
        // Update payment status to pending
        $payment->update(['status' => 'pending']);
        
        return $snapToken;
    }

    public function cancelOrder(Order $order): void
    {
        if (!in_array($order->status, ['pending', 'failed'])) {
            throw new \Exception('This order cannot be cancelled.');
        }
        
        DB::transaction(function () use ($order) {
            $order->update(['status' => 'cancelled']);
            
            if ($order->payment) {
                $order->payment->update(['status' => 'cancelled']);
            }
        });
        
        Log::info('Order cancelled by user', [
            'order_id' => $order->id,
            'user_id' => Auth::id()
        ]);
    }

    private function generateOrderNumber(): string
    {
        return 'ORD-' . date('Ymd') . '-' . strtoupper(substr(md5(uniqid(rand(), true)), 0, 8));
    }
}