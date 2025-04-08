<?php

namespace App\Http\Controllers;

use App\Services\OrderService;
use App\Services\CartService;
use App\Models\Address;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class CheckoutController extends Controller
{
    protected $orderService;
    protected $cartService;

    public function __construct(OrderService $orderService, CartService $cartService)
    {
        $this->middleware('auth');
        $this->orderService = $orderService;
        $this->cartService = $cartService;
    }

    public function index()
    {
        $cart = $this->cartService->getCart();
        $total = $this->cartService->calculateCartTotal();
        $addresses = Auth::user()->addresses;

        return view('checkout.index', compact('cart', 'total', 'addresses'));
    }

    public function processCheckout(Request $request)
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

            return redirect()->route('orders.show', $order)
                ->with('success', 'Order placed successfully');
        } catch (\Exception $e) {
            return back()->with('error', 'Order creation failed: ' . $e->getMessage());
        }
    }
}