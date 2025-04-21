@extends('layouts.app')
@section('show_back_button')
@endsection

@section('content')
<div class="container mx-auto">
    <div class="flex">
        <!-- Sidebar Categories -->
        <div class="w-1/4 pr-4">
            <h2 class="text-2xl font-bold mb-4">Categories</h2>
            <ul>
                @foreach($categories as $category)
                    <li class="mb-2">
                        <a href="{{ route('catalog.category', $category->slug) }}" 
                           class="text-gray-700 hover:text-blue-600 
                           {{ request()->is('catalog/category/' . $category->slug) ? 'font-bold text-blue-600' : '' }}">
                            {{ $category->name }}
                        </a>
                    </li>
                @endforeach
            </ul>
        </div>

        <!-- Product Grid -->
        <div class="w-3/4">
            <div class="flex justify-between items-center mb-6">
                <h1 class="text-3xl font-bold">All Products</h1>
                
                <div class="flex space-x-4">
                    <select name="sort" class="border rounded px-2 py-1">
                        <option>Sort by Price: Low to High</option>
                        <option>Sort by Price: High to Low</option>
                        <option>Sort by Newest</option>
                    </select>
                </div>
            </div>

            <div class="grid grid-cols-3 gap-6">
                @foreach($products as $product)
                    <div class="bg-white shadow-md rounded-lg overflow-hidden">
                        <img src="{{ $product->image ? asset('storage/' . $product->image) : asset('images/placeholder-product.png') }}" alt="{{ $product->name }}" class="w-full h-48 object-cover">
                        <div class="p-4">
                            <h3 class="text-xl font-semibold mb-2">{{ $product->name }}</h3>
                            <p class="text-gray-600 mb-2">{{ Str::limit($product->description, 100) }}</p>
                            <div class="flex justify-between items-center">
                                <span class="text-lg font-bold text-blue-600">Rp{{ number_format($product->price, 2) }}</span>
                                <a href="{{ route('products.detail', ['id' => $product->id]) }}" 
                                   class="bg-blue-500 text-white px-3 py-1 rounded hover:bg-blue-600">
                                    View Details
                                </a>
                            </div>
                        </div>
                    </div>
                @endforeach
            </div>

            <!-- Pagination -->
            <div class="mt-6">
                {{ $products->links() }}
            </div>
        </div>
    </div>
</div>
@endsection