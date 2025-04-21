<?php

namespace App\Http\Controllers;

use App\Services\CartService;
use App\Models\Product;
use App\Models\CartItem;
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
        $cartItems = $cart->cartItems()->with('product')->get(); // Pastikan relasi product dimuat
        $total = $this->cartService->calculateCartTotal();

        return view('cart.index', compact('cartItems', 'total'));
    }

    // Method untuk menangani route cart.add
    public function add(Request $request)
    {
        $request->validate([
            'product_id' => 'required|exists:products,id',
            'quantity' => 'integer|min:1'
        ]);

        $product = Product::findOrFail($request->product_id);
        $quantity = $request->quantity ?? 1;
        
        $this->cartService->addToCart($product, $quantity);

        return redirect()->route('cart.index')
            ->with('success', 'Product added to cart');
    }

    // Method untuk menangani route cart.store (alternatif untuk add)
    public function store(Request $request)
    {
        return $this->add($request); // Redirect ke method add
    }

    // Method untuk update quantity
    public function update(Request $request, CartItem $cartItem)
    {
        $request->validate([
            'quantity' => 'required|integer|min:0'
        ]);

        if ($request->quantity == 0) {
            $cartItem->delete();
        } else {
            $cartItem->update(['quantity' => $request->quantity]);
        }

        return redirect()->route('cart.index')
            ->with('success', 'Cart updated');
    }

    // Method untuk remove item
    public function destroy(CartItem $cartItem)
    {
        $cartItem->delete();

        return redirect()->route('cart.index')
            ->with('success', 'Item removed from cart');
    }
    // Tambahkan method debug ini untuk pengujian
public function debug()
{
    $user = Auth::user();
    $cart = Cart::where('user_id', $user->id)->first();
    
    dd([
        'user_id' => $user->id,
        'cart' => $cart,
        'cart_items' => $cart ? $cart->cartItems()->with('product')->get() : 'No cart found'
    ]);
}
}