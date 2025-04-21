@extends('layouts.app')
@section('show_back_button')
@endsection

@section('content')
<div class="container mx-auto px-4 py-8">
    <h1 class="text-3xl font-bold mb-6">Your Shopping Cart</h1>
    
    @if(session('success'))
        <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
            {{ session('success') }}
        </div>
    @endif
 
    @if(auth()->check() && isset($cartItems) && count($cartItems) > 0)
        <div class="grid md:grid-cols-3 gap-6">
            {{-- Cart Items --}}
            <div class="md:col-span-2 space-y-4">
                @foreach($cartItems as $item)
                    <div class="bg-white shadow-md rounded-lg p-4 flex items-center">
                        @if($item->product)
                        <img src="{{ asset($item->product->image ? 'storage/' . $item->product->image : 'images/placeholder-product.png') }}"
                                alt="{{ $item->product->name }}"
                                class="w-24 h-24 object-contain mr-4">

                            
                            <div class="flex-grow">
                                <h3 class="font-semibold">{{ $item->product->name }}</h3>
                                <p class="text-gray-600">Price: {{ number_format($item->product->price, 2) }}</p>
                                
                                <form action="{{ route('cart.update', $item->id) }}" method="POST" class="flex items-center mt-2">
                                    @csrf
                                    @method('PUT')
                                    <label for="quantity" class="mr-2">Qty:</label>
                                    <input type="number" name="quantity" value="{{ $item->quantity }}" 
                                           min="1" class="border rounded px-2 py-1 w-16 text-center">
                                    <button type="submit" class="ml-2 px-2 py-1 bg-gray-200 rounded hover:bg-gray-300">
                                        Update
                                    </button>
                                </form>
                                
                                <p class="font-bold mt-2">Subtotal: {{ number_format($item->product->price * $item->quantity, 2) }}</p>
                                
                                <form action="{{ route('cart.destroy', $item->id) }}" method="POST" class="mt-2">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="text-red-500 hover:text-red-700">
                                        Remove
                                    </button>
                                </form>
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
                    <p class="text-lg">Total: {{ number_format($total ?? 0, 2) }}</p>
                    <a href="{{ route('checkout.index') }}" class="mt-4 block w-full bg-blue-500 text-white py-2 rounded text-center hover:bg-blue-600">
                        Proceed to Checkout
                    </a>
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