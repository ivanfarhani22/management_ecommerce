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
        return Cart::firstOrCreate(['user_id' => $user->id]);
    }

    public function addToCart(Product $product, int $quantity = 1)
    {
        $cart = $this->getCart();

        $cartItem = $cart->cartItems()->where('product_id', $product->id)->first();

        if ($cartItem) {
            $cartItem->increment('quantity', $quantity);
        } else {
            $cart->cartItems()->create([
                'product_id' => $product->id,
                'quantity' => $quantity
            ]);
        }

        return $cart->refresh();
    }

    public function removeFromCart(Product $product)
    {
        $cart = $this->getCart();
        $cart->cartItems()->where('product_id', $product->id)->delete();

        return $cart->refresh();
    }

    public function updateCartItemQuantity(Product $product, int $quantity)
    {
        $cart = $this->getCart();
        $cartItem = $cart->cartItems()->where('product_id', $product->id)->first();

        if ($cartItem) {
            if ($quantity <= 0) {
                $cartItem->delete();
            } else {
                $cartItem->update(['quantity' => $quantity]);
            }
        }

        return $cart->refresh();
    }

    public function clearCart()
    {
        $cart = $this->getCart();
        $cart->cartItems()->delete();

        return $cart;
    }

    public function calculateCartTotal()
    {
        $cart = $this->getCart();
        return $cart->cartItems->sum(function ($item) {
            return $item->product->price * $item->quantity;
        });
    }
}