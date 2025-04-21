<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\OrderService;
use App\Models\Order;
use Illuminate\Support\Facades\Auth;

class OrderController extends Controller
{
    protected $orderService;
 
    public function __construct(OrderService $orderService)
    {
        // Remove this line:
        // $this->middleware('auth');
        $this->orderService = $orderService;
    }
 
    public function index()
    {
        $orders = $this->orderService->getOrderHistory(); // Changed from getOrdersByUser(Auth::id())
        return view('orders.index', compact('orders'));
    }
    
    public function show(Order $order)
    {
        // Check if the order belongs to the authenticated user
        if ($order->user_id !== Auth::id()) {
            abort(403, 'Unauthorized action.');
        }
        
        return view('orders.show', compact('order'));
    }
    
    public function cancel(Order $order)
    {
        // Check if the order belongs to the authenticated user
        if ($order->user_id !== Auth::id()) {
            return back()->with('error', 'You are not authorized to cancel this order.');
        }
        
        try {
            $this->orderService->cancelOrder($order);
            return redirect()->route('orders.index')->with('success', 'Order cancelled successfully.');
        } catch (\Exception $e) {
            return back()->with('error', 'Failed to cancel order: ' . $e->getMessage());
        }
    }
    
    public function sendConfirmation(Order $order)
    {
        // Check if the order belongs to the authenticated user
        if ($order->user_id !== Auth::id()) {
            return back()->with('error', 'You are not authorized to resend confirmation for this order.');
        }
        
        try {
            // Logic to send confirmation email
            // You might want to implement this in your OrderService
            
            return redirect()->route('orders.show', $order)->with('success', 'Order confirmation sent.');
        } catch (\Exception $e) {
            return back()->with('error', 'Failed to send confirmation: ' . $e->getMessage());
        }
    }
}