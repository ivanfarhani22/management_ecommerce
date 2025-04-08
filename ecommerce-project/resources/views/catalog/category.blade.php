@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-8">
    <div class="mb-6">
        <h1 class="text-3xl font-bold">{{ $category->name }}</h1>
        <p class="text-gray-600 mt-2">{{ $category->description }}</p>
    </div>

    <div class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-4">
        @forelse($products as $product)
            <div class="bg-white shadow-md rounded-lg p-4 text-center hover:shadow-lg transition-shadow">
                <a href="{{ route('catalog.product', $product->slug) }}">
                    <img src="{{ $product->primary_image }}" alt="{{ $product->name }}" 
                         class="mx-auto mb-4 w-full h-48 object-contain">
                    <h3 class="font-semibold">{{ $product->name }}</h3>
                    <p class="text-gray-600">{{ number_format($product->price, 2) }} IDR</p>
                </a>
                <button class="mt-4 w-full bg-blue-500 text-white py-2 rounded-md hover:bg-blue-600">
                    Add to Cart
                </button>
            </div>
        @empty
            <div class="col-span-full text-center py-8">
                <p class="text-gray-600">No products found in this category.</p>
            </div>
        @endforelse
    </div>

    {{-- Pagination --}}
    <div class="mt-8 flex justify-center">
        {{ $products->links() }}
    </div>
</div>
@endsection