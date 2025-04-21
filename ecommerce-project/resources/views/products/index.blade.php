@extends('layouts.app')
@section('show_back_button')
@endsection

@section('content')
<div class="container mx-auto px-4 py-8">
    <h1 class="text-3xl font-bold mb-6">Our Products</h1>

    <div class="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-6">
        @forelse($products as $product)
            <div class="bg-white shadow-md rounded-lg overflow-hidden">
                <img 
                    src="{{ $product->image ? asset('storage/' . $product->image) : asset('images/placeholder-product.png') }}" 
                    alt="{{ $product->name }}" 
                    class="w-full h-48 object-cover"
                >
                <div class="p-4">
                    <h2 class="text-xl font-semibold mb-2">{{ $product->name }}</h2>
                    <p class="text-gray-600 mb-2">{{ Str::limit($product->description, 100) }}</p>
                    <div class="flex justify-between items-center">
                        <span class="text-lg font-bold text-green-600">
                            Rp {{ number_format($product->price, 0, ',', '.') }}
                        </span>
                        <div class="flex items-center">
                            <span class="mr-2 text-sm text-gray-500">
                                Stock: {{ $product->stock }}
                            </span>
                            <a href="{{ route('products.show', $product->id) }}" 
                               class="bg-blue-500 text-white px-3 py-1 rounded hover:bg-blue-600 transition">
                                View
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        @empty
            <div class="col-span-full text-center py-8">
                <p class="text-gray-600">No products available.</p>
            </div>
        @endforelse
    </div>

    @if($products->hasPages())
        <div class="mt-6">
            {{ $products->links() }}
        </div>
    @endif
</div>
@endsection