<?php

namespace App\Services;

use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Product;
use Illuminate\Support\Facades\Auth;

class CartService
{
    public function getCart()
    {
        $user = Auth::user();
        
        if (!$user) {
            abort(403, 'User must be logged in to use cart');
        }
        
        // Ambil cart berdasarkan user_id
        $cart = Cart::firstOrCreate(['user_id' => $user->id]);
        
        return $cart;
    }

    public function addToCart(Product $product, int $quantity = 1)
    {
        $cart = $this->getCart();

        // Cek apakah produk sudah ada di cart
        $cartItem = $cart->cartItems()->where('product_id', $product->id)->first();

        if ($cartItem) {
            // Update quantity jika sudah ada
            $cartItem->increment('quantity', $quantity);
        } else {
            // Buat cart item baru jika belum ada
            $cart->cartItems()->create([
                'cart_id' => $cart->id, // tambahkan ini secara eksplisit
                'product_id' => $product->id,
                'quantity' => $quantity
            ]);            
        }

        return $cart->refresh();
    }

    public function calculateCartTotal()
    {
        $cart = $this->getCart();
        
        $total = 0;
        foreach ($cart->cartItems as $item) {
            if ($item->product) {
                $total += $item->product->price * $item->quantity;
            }
        }
        
        return $total;
    }
    public function clearCart()
{
    $cart = $this->getCart();
    $cart->cartItems()->delete();
    return true;
}

/**
 * Check if the cart is valid (not empty and has items)
 *
 * @param mixed $cart
 * @return bool
 */
public function isCartValid($cart): bool
{
    return $cart && 
           isset($cart->cartItems) && 
           $cart->cartItems->isNotEmpty();
}
}