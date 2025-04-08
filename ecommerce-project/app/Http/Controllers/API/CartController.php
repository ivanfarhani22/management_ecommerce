<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Services\CartService;
use App\Models\Product;
use Illuminate\Http\Request;

class CartController extends Controller
{
    protected $cartService;

    public function __construct(CartService $cartService)
    {
        $this->middleware('auth:sanctum');
        $this->cartService = $cartService;
    }

    public function index()
    {
        $cart = $this->cartService->getCart();
        return response()->json([
            'cart' => $cart->load('cartItems.product'),
            'total' => $this->cartService->calculateCartTotal()
        ]);
    }

    public function addToCart(Request $request)
    {
        $request->validate([
            'product_id' => 'required|exists:products,id',
            'quantity' => 'integer|min:1|default:1'
        ]);

        $product = Product::findOrFail($request->product_id);
        $quantity = $request->input('quantity', 1);

        $cart = $this->cartService->addToCart($product, $quantity);

        return response()->json([
            'message' => 'Product added to cart',
            'cart' => $cart->load('cartItems.product')
        ]);
    }

    public function removeFromCart(Request $request)
    {
        $request->validate([
            'product_id' => 'required|exists:products,id'
        ]);

        $product = Product::findOrFail($request->product_id);
        $cart = $this->cartService->removeFromCart($product);

        return response()->json([
            'message' => 'Product removed from cart',
            'cart' => $cart->load('cartItems.product')
        ]);
    }

    public function updateQuantity(Request $request)
    {
        $request->validate([
            'product_id' => 'required|exists:products,id',
            'quantity' => 'required|integer|min:0'
        ]);

        $product = Product::findOrFail($request->product_id);
        $cart = $this->cartService->updateCartItemQuantity($product, $request->quantity);

        return response()->json([
            'message' => 'Cart updated',
            'cart' => $cart->load('cartItems.product')
        ]);
    }

    public function clearCart()
    {
        $cart = $this->cartService->clearCart();

        return response()->json([
            'message' => 'Cart cleared',
            'cart' => $cart
        ]);
    }
}