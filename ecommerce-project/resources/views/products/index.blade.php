@extends('layouts.app')

@section('show_back_button')
@endsection

@section('content')
<div class="bg-gray-50 min-h-screen">
    <!-- Header -->
    <div class="bg-white border-b border-gray-100">
        <div class="container mx-auto px-6 py-12">
            <h1 class="text-4xl font-light text-gray-900 text-center">Products</h1>
        </div>
    </div>

    <!-- Products Grid -->
    <div class="container mx-auto px-6 py-12">
        @forelse($products as $product)
            @if($loop->first)
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-8">
            @endif
            
            <div class="bg-white rounded-lg overflow-hidden shadow-sm hover:shadow-md transition-shadow duration-300 group">
                <!-- Image -->
                <div class="aspect-square overflow-hidden bg-gray-100">
                    <img 
                        src="{{ $product->image ? asset('storage/' . $product->image) : asset('images/placeholder-product.png') }}" 
                        alt="{{ $product->name }}"
                        class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                    >
                </div>

                <!-- Content -->
                <div class="p-6">
                    <h3 class="font-medium text-gray-900 mb-2 leading-tight">
                        {{ $product->name }}
                    </h3>
                    
                    <p class="text-sm text-gray-600 mb-4 line-clamp-2">
                        {{ $product->description }}
                    </p>
                    
                    <div class="flex items-center justify-between">
                        <div>
                            <span class="text-lg font-semibold text-gray-900">
                                Rp {{ number_format($product->price, 0, ',', '.') }}
                            </span>
                            <div class="text-xs text-gray-500 mt-1">
                                Stock: {{ $product->stock }}
                            </div>
                        </div>
                        
                        <a href="{{ route('products.show', $product->id) }}" 
                           class="px-4 py-2 bg-gray-900 text-white text-sm font-medium hover:bg-gray-800 transition-colors duration-200 rounded">
                            View
                        </a>
                    </div>
                </div>
            </div>
            
            @if($loop->last)
                </div>
            @endif
        @empty
            <div class="text-center py-20">
                <div class="text-gray-400 mb-4">
                    <svg class="w-16 h-16 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"></path>
                    </svg>
                </div>
                <h3 class="text-xl font-light text-gray-900 mb-2">No products available</h3>
                <p class="text-gray-600">Check back later for new items</p>
            </div>
        @endforelse

        <!-- Pagination -->
        @if($products->hasPages())
            <div class="mt-16 flex justify-center">
                {{ $products->links() }}
            </div>
        @endif
    </div>
</div>

<style>
.line-clamp-2 {
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

/* Custom pagination */
.pagination {
    @apply flex items-center space-x-2;
}

.pagination a,
.pagination span {
    @apply px-3 py-2 text-sm border border-gray-200 hover:border-gray-300 transition-colors duration-200;
}

.pagination a {
    @apply text-gray-700 hover:text-gray-900;
}

.pagination .active span {
    @apply bg-gray-900 text-white border-gray-900;
}

.pagination .disabled span {
    @apply text-gray-400 cursor-not-allowed;
}
</style>
@endsection