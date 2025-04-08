<?php

namespace App\Services;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Cart;
use App\Models\Address;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;

class OrderService
{
    protected $cartService;
    protected $paymentService;

    public function __construct(CartService $cartService, PaymentService $paymentService)
    {
        $this->cartService = $cartService;
        $this->paymentService = $paymentService;
    }

    public function createOrder(Address $shippingAddress, $paymentMethod)
    {
        return DB::transaction(function () use ($shippingAddress, $paymentMethod) {
            $cart = $this->cartService->getCart();
            $totalAmount = $this->cartService->calculateCartTotal();

            $order = Order::create([
                'user_id' => Auth::id(),
                'address_id' => $shippingAddress->id,
                'total_amount' => $totalAmount,
                'status' => 'pending'
            ]);

            // Create order items from cart items
            foreach ($cart->cartItems as $cartItem) {
                OrderItem::create([
                    'order_id' => $order->id,
                    'product_id' => $cartItem->product_id,
                    'quantity' => $cartItem->quantity,
                    'price' => $cartItem->product->price,
                    'subtotal' => $cartItem->product->price * $cartItem->quantity
                ]);

                // Reduce product stock
                $cartItem->product->decrement('stock', $cartItem->quantity);
            }

            // Process payment
            $payment = $this->paymentService->processPayment($order, $paymentMethod);

            // Clear the cart
            $this->cartService->clearCart();

            return $order;
        });
    }

    public function getOrderHistory()
    {
        return Order::where('user_id', Auth::id())
            ->with(['orderItems.product', 'payment'])
            ->latest()
            ->get();
    }

    public function cancelOrder(Order $order)
    {
        if ($order->status === 'pending') {
            $order->update(['status' => 'cancelled']);

            // Restore product stock
            foreach ($order->orderItems as $orderItem) {
                $orderItem->product->increment('stock', $orderItem->quantity);
            }

            return $order;
        }

        throw new \Exception('Order cannot be cancelled');
    }

    public function updateOrderStatus(Order $order, string $status)
    {
        $validStatuses = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];
        
        if (in_array($status, $validStatuses)) {
            $order->update(['status' => $status]);
            return $order;
        }

        throw new \Exception('Invalid order status');
    }
}