<?php

namespace App\Http\Controllers;

use App\Services\CartService;
use App\Models\Product;
use Illuminate\Http\Request;

class CartController extends Controller
{
    protected $cartService;

    public function __construct(CartService $cartService)
    {
        $this->cartService = $cartService;
    }

    public function index()
    {
        $cart = $this->cartService->getCart();
        $cartItems = $cart->cartItems; // Assuming this is the correct relationship
        $total = $this->cartService->calculateCartTotal();

        return view('cart.index', compact('cartItems', 'total'));
    }

    public function addToCart(Request $request)
    {
        $request->validate([
            'product_id' => 'required|exists:products,id',
            'quantity' => 'integer|min:1'
        ]);

        $product = Product::findOrFail($request->product_id);
        $this->cartService->addToCart($product, $request->quantity ?? 1);

        return redirect()->route('cart.index')
            ->with('success', 'Product added to cart');
    }

    public function removeFromCart(Request $request)
    {
        $product = Product::findOrFail($request->product_id);
        $this->cartService->removeFromCart($product);

        return redirect()->route('cart.index')
            ->with('success', 'Product removed from cart');
    }

    public function updateQuantity(Request $request)
    {
        $request->validate([
            'product_id' => 'required|exists:products,id',
            'quantity' => 'required|integer|min:0'
        ]);

        $product = Product::findOrFail($request->product_id);
        $this->cartService->updateCartItemQuantity($product, $request->quantity);

        return redirect()->route('cart.index')
            ->with('success', 'Cart updated');
    }
}