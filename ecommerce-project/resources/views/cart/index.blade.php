@extends('layouts.app')
@section('show_back_button')
@endsection

@section('content')
<div class="min-h-screen bg-gray-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <!-- Header -->
        <div class="text-center mb-12">
            <h1 class="text-4xl font-light text-gray-900 tracking-tight">Shopping Cart</h1>
            <div class="w-24 h-0.5 bg-gray-900 mx-auto mt-4"></div>
        </div>
        
        @if(session('success'))
            <div class="max-w-md mx-auto mb-8">
                <div class="bg-green-50 border border-green-200 text-green-800 px-6 py-4 rounded-lg text-center">
                    {{ session('success') }}
                </div>
            </div>
        @endif
 
        @if(auth()->check() && isset($cartItems) && count($cartItems) > 0)
            <div class="grid lg:grid-cols-12 gap-12">
                <!-- Cart Items Section -->
                <div class="lg:col-span-8">
                    <div class="space-y-6">
                        @foreach($cartItems as $item)
                            <div class="group bg-white rounded-xl shadow-sm hover:shadow-md transition-all duration-300 overflow-hidden">
                                @if($item->product)
                                    <div class="p-8">
                                        <div class="flex flex-col sm:flex-row gap-6">
                                            <!-- Product Image -->
                                            <div class="flex-shrink-0">
                                                <div class="w-32 h-32 sm:w-40 sm:h-40 mx-auto sm:mx-0 relative overflow-hidden rounded-lg bg-gray-50">
                                                    <img src="{{ asset($item->product->image ? 'storage/' . $item->product->image : 'images/placeholder-product.png') }}"
                                                         alt="{{ $item->product->name }}"
                                                         class="w-full h-full object-contain transition-transform duration-300 group-hover:scale-105">
                                                </div>
                                            </div>
                                            
                                            <!-- Product Details -->
                                            <div class="flex-grow space-y-4">
                                                <div>
                                                    <h3 class="text-xl font-light text-gray-900 mb-2">{{ $item->product->name }}</h3>
                                                    <p class="text-lg text-gray-600 font-light">IDR {{ number_format($item->product->price, 0, ',', '.') }}</p>
                                                </div>
                                                
                                                <!-- Quantity Controls -->
                                                <div class="flex items-center space-x-4">
                                                    <form action="{{ route('cart.update', $item->id) }}" method="POST" class="flex items-center space-x-3">
                                                        @csrf
                                                        @method('PUT')
                                                        <label class="text-sm font-light text-gray-600 uppercase tracking-wide">Quantity</label>
                                                        <div class="flex items-center border border-gray-200 rounded-lg overflow-hidden">
                                                            <input type="number" name="quantity" value="{{ $item->quantity }}" 
                                                                   min="1" class="w-16 px-3 py-2 text-center border-0 focus:ring-0 focus:outline-none text-gray-900">
                                                        </div>
                                                        <button type="submit" class="px-4 py-2 text-sm font-light text-gray-600 hover:text-gray-900 border border-gray-200 rounded-lg hover:border-gray-300 transition-colors duration-200">
                                                            Update
                                                        </button>
                                                    </form>
                                                </div>
                                                
                                                <!-- Subtotal and Remove -->
                                                <div class="flex items-center justify-between pt-4 border-t border-gray-100">
                                                    <p class="text-xl font-light text-gray-900">IDR {{ number_format($item->product->price * $item->quantity, 0, ',', '.') }}</p>
                                                    
                                                    <form action="{{ route('cart.destroy', $item->id) }}" method="POST">
                                                        @csrf
                                                        @method('DELETE')
                                                        <button type="submit" class="text-sm font-light text-gray-400 hover:text-red-500 transition-colors duration-200 uppercase tracking-wide">
                                                            Remove
                                                        </button>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                @else
                                    <div class="p-8 text-center">
                                        <p class="text-red-500 font-light">Product not found</p>
                                    </div>
                                @endif
                            </div>
                        @endforeach
                    </div>
                </div>

                <!-- Cart Summary -->
                <div class="lg:col-span-4">
                    <div class="sticky top-8">
                        <div class="bg-white rounded-xl shadow-sm p-8">
                            <h2 class="text-2xl font-light text-gray-900 mb-6 text-center">Order Summary</h2>
                            
                            <div class="space-y-4 mb-8">
                                <div class="flex justify-between items-center py-3 border-b border-gray-100">
                                    <span class="text-gray-600 font-light">Subtotal</span>
                                    <span class="text-gray-900 font-light">IDR {{ number_format($total ?? 0, 0, ',', '.') }}</span>
                                </div>
                                <div class="flex justify-between items-center py-3 border-b border-gray-100">
                                    <span class="text-gray-600 font-light">Shipping</span>
                                    <span class="text-gray-900 font-light">Calculated at checkout</span>
                                </div>
                                <div class="flex justify-between items-center py-4 border-t-2 border-gray-900">
                                    <span class="text-xl font-light text-gray-900">Total</span>
                                    <span class="text-2xl font-light text-gray-900">IDR {{ number_format($total ?? 0, 0, ',', '.') }}</span>
                                </div>
                            </div>
                            
                            <a href="{{ route('checkout.index') }}" 
                               class="block w-full bg-gray-900 text-white py-4 text-center font-light uppercase tracking-wide hover:bg-gray-800 transition-colors duration-300 rounded-lg">
                                Proceed to Checkout
                            </a>
                            
                            <a href="{{ route('products.index') }}" 
                               class="block w-full mt-4 text-center py-4 text-gray-600 font-light uppercase tracking-wide hover:text-gray-900 transition-colors duration-300 border border-gray-200 rounded-lg hover:border-gray-300">
                                Continue Shopping
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        @else
            <!-- Empty Cart State -->
            <div class="max-w-lg mx-auto text-center">
                <div class="bg-white rounded-xl shadow-sm p-12">
                    <div class="w-24 h-24 mx-auto mb-6 bg-gray-100 rounded-full flex items-center justify-center">
                        <svg class="w-10 h-10 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"/>
                        </svg>
                    </div>
                    <h3 class="text-xl font-light text-gray-900 mb-4">Your cart is empty</h3>
                    <p class="text-gray-600 font-light mb-8 leading-relaxed">Looks like you haven't added any items to your cart yet. Start shopping to fill it up!</p>
                    <a href="{{ route('products.index') }}" 
                       class="inline-block bg-gray-900 text-white px-8 py-3 font-light uppercase tracking-wide hover:bg-gray-800 transition-colors duration-300 rounded-lg">
                        Start Shopping
                    </a>
                </div>
            </div>
        @endif
    </div>
</div>

<style>
/* Custom styles untuk enhanced experience */
.group:hover .group-hover\:scale-105 {
    transform: scale(1.02);
}

/* Smooth focus states */
input[type="number"]:focus {
    outline: none;
    box-shadow: 0 0 0 1px #374151;
}

/* Custom scrollbar untuk desktop */
@media (min-width: 1024px) {
    .sticky {
        position: -webkit-sticky;
        position: sticky;
    }
}

/* Enhanced mobile responsiveness */
@media (max-width: 640px) {
    .max-w-7xl {
        padding-left: 1rem;
        padding-right: 1rem;
    }
    
    .bg-white.rounded-xl {
        border-radius: 0.5rem;
    }
    
    .p-8 {
        padding: 1.5rem;
    }
}
</style>
@endsection