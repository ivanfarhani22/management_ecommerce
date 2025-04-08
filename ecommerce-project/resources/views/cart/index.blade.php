@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-8">
    <h1 class="text-3xl font-bold mb-6">Your Shopping Cart</h1>
 
    @if(auth()->check() && $cartItems && $cartItems->count() > 0)
        <div class="grid md:grid-cols-3 gap-6">
            {{-- Cart Items --}}
            <div class="md:col-span-2 space-y-4">
                @foreach($cartItems as $item)
                    <div class="bg-white shadow-md rounded-lg p-4 flex items-center">
                        @if($item->product)
                            <img src="{{ $item->product->primary_image ?? 'default-image.jpg' }}" 
                                 alt="{{ $item->product->name }}" 
                                 class="w-24 h-24 object-contain mr-4">
                            
                            <div class="flex-grow">
                                <h3 class="font-semibold">{{ $item->product->name }}</h3>
                                <p class="text-gray-600">Price: {{ number_format($item->product->price, 2) }}</p>
                                <p class="text-gray-600">Quantity: {{ $item->quantity }}</p>
                                <p class="font-bold">Subtotal: {{ number_format($item->product->price * $item->quantity, 2) }}</p>
                            </div>
                        @else
                            <p class="text-red-500">Product not found</p>
                        @endif
                    </div>
                @endforeach
            </div>

            {{-- Cart Summary --}}
            <div class="md:col-span-1">
                <div class="bg-white shadow-md rounded-lg p-4">
                    <h2 class="text-xl font-bold mb-4">Cart Total</h2>
                    <p class="text-lg">Total: {{ number_format($total, 2) }}</p>
                    <button class="mt-4 w-full bg-blue-500 text-white py-2 rounded hover:bg-blue-600">
                        Proceed to Checkout
                    </button>
                </div>
            </div>
        </div>
    @else
        <div class="bg-white shadow-md rounded-lg p-4 text-center">
            <p class="text-gray-600">Your cart is empty.</p>
            <a href="{{ route('products.index') }}" class="mt-4 inline-block bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
                Continue Shopping
            </a>
        </div>
    @endif
</div>
@endsection