@extends('layouts.app')
@section('show_back_button')
@endsection

@section('content')
<div class="container mx-auto px-4 py-8">
    <div class="grid md:grid-cols-2 gap-8">
        <div>
            <img 
                src="{{ $product->image ? asset('storage/' . $product->image) : asset('images/placeholder-product.png') }}" 
                alt="{{ $product->name }}" 
                class="w-full rounded-lg shadow-md"
            >
        </div>
        <div>
            <h1 class="text-3xl font-bold mb-4">{{ $product->name }}</h1>
            
            <div class="mb-4">
                <span class="text-2xl font-bold text-green-600">
                    Rp {{ number_format($product->price, 0, ',', '.') }}
                </span>
            </div>

            <div class="mb-4">
                <p class="text-gray-700">{{ $product->description }}</p>
            </div>

            <div class="mb-4">
                <strong>Category:</strong> 
                {{ $product->category ? $product->category->name : 'Uncategorized' }}
            </div>

            <div class="mb-4">
                <strong>Stock:</strong> 
                <span class="{{ $product->stock > 10 ? 'text-green-600' : 'text-red-600' }}">
                    {{ $product->stock }} available
                </span>
            </div>

            <div class="flex space-x-4">
            <form action="{{ route('cart.add') }}" method="POST">
                @csrf
                <input type="hidden" name="product_id" value="{{ $product->id }}">
                <input type="number" name="quantity" value="1" min="1" class="border rounded px-2 py-1 w-16 text-center">
                <button type="submit" class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
                    Add to Cart
                </button>
            </form>
                <button class="bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600">
                    Buy Now
                </button>
            </div>
        </div>
    </div>

    @if(count($similarProducts) > 0)
    <div class="mt-12">
        <h2 class="text-2xl font-bold mb-6">Similar Products</h2>
        <div class="grid grid-cols-4 gap-6">
            @foreach($similarProducts as $similarProduct)
                <div class="bg-white shadow-md rounded-lg overflow-hidden">
                    <img 
                        src="{{ $similarProduct->image ? asset('storage/' . $similarProduct->image) : asset('images/placeholder-product.png') }}" 
                        alt="{{ $similarProduct->name }}" 
                        class="w-full h-48 object-cover"
                    >
                    <div class="p-4">
                        <h3 class="text-lg font-semibold">{{ $similarProduct->name }}</h3>
                        <p class="text-green-600 font-bold">
                            Rp {{ number_format($similarProduct->price, 0, ',', '.') }}
                        </p>
                        <a href="{{ route('products.show', $similarProduct->id) }}" 
                           class="block mt-2 text-blue-500 hover:underline">
                            View Details
                        </a>
                    </div>
                </div>
            @endforeach
        </div>
    </div>
    @endif
</div>
@endsection