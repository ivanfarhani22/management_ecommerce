<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Services\OrderService;
use App\Models\Order;
use App\Models\Address;
use Illuminate\Http\Request;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests; // ✅ Tambahkan baris ini

class OrderController extends Controller
{
    use AuthorizesRequests; // ✅ Tambahkan ini di dalam class

    protected $orderService;

    public function __construct(OrderService $orderService)
    {
        $this->orderService = $orderService;
    }

    public function index()
    {
        $orders = $this->orderService->getOrderHistory();
        return response()->json([
            'orders' => $orders
        ]);
    }

    public function create(Request $request)
    {
        $request->validate([
            'shipping_address_id' => 'required|exists:addresses,id',
            'payment_method' => 'required|in:stripe,paypal'
        ]);

        $shippingAddress = Address::findOrFail($request->shipping_address_id);

        try {
            $order = $this->orderService->createOrder(
                $shippingAddress, 
                $request->payment_method
            );

            return response()->json([
                'message' => 'Order created successfully',
                'order' => $order->load('orderItems.product', 'payment')
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Order creation failed',
                'error' => $e->getMessage()
            ], 400);
        }
    }

    public function show(Order $order)
    {
        $this->authorize('view', $order);

        return response()->json([
            'order' => $order->load('orderItems.product', 'payment', 'address')
        ]);
    }

    public function cancel(Order $order)
    {
        $this->authorize('cancel', $order);

        try {
            $cancelledOrder = $this->orderService->cancelOrder($order);
            
            return response()->json([
                'message' => 'Order cancelled successfully',
                'order' => $cancelledOrder
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Order cancellation failed',
                'error' => $e->getMessage()
            ], 400);
        }
    }

    public function updateStatus(Order $order, Request $request)
    {
        $validated = $request->validate([
            'status' => 'required|string|in:pending,processing,shipped,delivered,cancelled',
        ]);
        
        $order->status = $validated['status'];
        $order->save();
        
        return response()->json([
            'message' => 'Order status updated successfully',
            'order' => $order
        ]);
    }
}
