<?php
namespace App\Http\Controllers;

use App\Models\Order;
use App\Services\OrderService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class OrderController extends Controller
{
    protected $orderService;

    public function __construct(OrderService $orderService)
    {
        $this->orderService = $orderService;
        $this->middleware('auth'); // Ensure only authenticated users can access these methods
    }

    /**
     * Display a listing of the user's orders
     */
    public function index()
    {
        $orders = $this->orderService->getUserOrders(Auth::id());
        return view('orders.index', compact('orders'));
    }

    /**
     * Show the form for creating a new order
     */
    public function create()
    {
        $cartItems = $this->orderService->getUserCartItems(Auth::id());
        return view('orders.create', compact('cartItems'));
    }

    /**
     * Store a newly created order in storage
     */
    public function store(Request $request)
    {
        $validatedData = $request->validate([
            'shipping_address' => 'required|string|max:255',
            'payment_method' => 'required|string|in:credit_card,paypal,bank_transfer',
            'cart_items' => 'required|array',
            'cart_items.*.product_id' => 'exists:products,id',
            'cart_items.*.quantity' => 'integer|min:1'
        ]);

        try {
            $order = $this->orderService->createOrder(
                Auth::id(), 
                $validatedData['shipping_address'], 
                $validatedData['payment_method'], 
                $validatedData['cart_items']
            );

            return redirect()->route('orders.show', $order)->with('success', 'Order created successfully');
        } catch (\Exception $e) {
            return back()->with('error', 'Failed to create order: ' . $e->getMessage());
        }
    }

    /**
     * Display the specified order
     */
    public function show(Order $order)
    {
        // Ensure the user can only view their own orders
        $this->authorize('view', $order);

        $orderDetails = $this->orderService->getOrderDetails($order->id);
        return view('orders.show', compact('orderDetails'));
    }

    /**
     * Show the form for editing an existing order
     */
    public function edit(Order $order)
    {
        $this->authorize('update', $order);

        // Only allow editing of pending orders
        if (!$order->isPending()) {
            return back()->with('error', 'This order can no longer be modified');
        }

        $cartItems = $this->orderService->getOrderItems($order->id);
        return view('orders.edit', compact('order', 'cartItems'));
    }

    /**
     * Update the specified order in storage
     */
    public function update(Request $request, Order $order)
    {
        $this->authorize('update', $order);

        $validatedData = $request->validate([
            'shipping_address' => 'sometimes|string|max:255',
            'payment_method' => 'sometimes|string|in:credit_card,paypal,bank_transfer',
            'cart_items' => 'sometimes|array',
            'cart_items.*.product_id' => 'exists:products,id',
            'cart_items.*.quantity' => 'integer|min:1'
        ]);

        try {
            $updatedOrder = $this->orderService->updateOrder(
                $order->id, 
                $validatedData
            );

            return redirect()->route('orders.show', $updatedOrder)
                ->with('success', 'Order updated successfully');
        } catch (\Exception $e) {
            return back()->with('error', 'Failed to update order: ' . $e->getMessage());
        }
    }

    /**
     * Cancel the specified order
     */
    public function cancel(Order $order)
    {
        $this->authorize('cancel', $order);

        try {
            $this->orderService->cancelOrder($order->id);
            return redirect()->route('orders.index')
                ->with('success', 'Order cancelled successfully');
        } catch (\Exception $e) {
            return back()->with('error', 'Failed to cancel order: ' . $e->getMessage());
        }
    }
}