@extends('layouts.app')
@section('show_back_button')
@endsection

@section('content')
<div class="min-h-screen bg-gray-50 py-8 px-4 sm:px-6 lg:px-8">
    <div class="max-w-7xl mx-auto">
        <!-- Header Section -->
        <div class="text-center mb-12">
            <h1 class="text-3xl md:text-4xl font-light text-gray-900 mb-4">Katalog Produk</h1>
            <div class="w-16 h-0.5 bg-gray-900 mx-auto"></div>
        </div>

        <div class="grid lg:grid-cols-5 gap-8">
            <!-- Sidebar Categories -->
            <div class="lg:col-span-1">
                <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden sticky top-8">
                    <!-- Categories Header -->
                    <div class="p-6 border-b border-gray-50">
                        <h2 class="text-lg font-medium text-gray-900">Kategori</h2>
                    </div>
                    
                    <!-- Categories List -->
                    <nav class="p-6">
                        <div class="space-y-1">
                            <a href="{{ route('catalog.index') }}" 
                               class="flex items-center px-4 py-3 text-sm rounded-xl transition-all duration-200 group
                               {{ !request()->route()->parameter('slug') ? 'text-gray-900 bg-gray-50' : 'text-gray-600 hover:text-gray-900 hover:bg-gray-50' }}"
                            >
                                <span class="w-2 h-2 rounded-full mr-3 {{ !request()->route()->parameter('slug') ? 'bg-gray-900' : 'bg-gray-300 group-hover:bg-gray-400' }}"></span>
                                Semua Produk
                            </a>
                            
                            @foreach($categories as $category)
                                <a href="{{ route('catalog.category', $category->slug) }}" 
                                   class="flex items-center px-4 py-3 text-sm rounded-xl transition-all duration-200 group
                                   {{ request()->is('catalog/category/' . $category->slug) ? 'text-gray-900 bg-gray-50' : 'text-gray-600 hover:text-gray-900 hover:bg-gray-50' }}"
                                >
                                    <span class="w-2 h-2 rounded-full mr-3 {{ request()->is('catalog/category/' . $category->slug) ? 'bg-gray-900' : 'bg-gray-300 group-hover:bg-gray-400' }}"></span>
                                    {{ $category->name }}
                                </a>
                            @endforeach
                        </div>
                    </nav>
                </div>
            </div>

            <!-- Main Content -->
            <div class="lg:col-span-4">
                <!-- Filter & Sort Bar -->
                <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 mb-8">
                    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                        <div>
                            <p class="text-sm text-gray-500 font-light">
                                Menampilkan {{ $products->count() }} dari {{ $products->total() }} produk
                            </p>
                        </div>
                        
                        <div class="flex items-center space-x-4">
                            <label class="text-sm text-gray-600 font-light">Urutkan:</label>
                            <select name="sort" class="bg-gray-50 border-0 rounded-xl px-4 py-2 text-sm font-light focus:ring-2 focus:ring-gray-200 focus:bg-white transition-all duration-200">
                                <option>Harga: Rendah ke Tinggi</option>
                                <option>Harga: Tinggi ke Rendah</option>
                                <option>Terbaru</option>
                                <option>Terpopuler</option>
                            </select>
                        </div>
                    </div>
                </div>

                <!-- Products Grid -->
                @if($products->count() > 0)
                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6 mb-8">
                        @foreach($products as $product)
                            <div class="bg-white rounded-lg overflow-hidden shadow-sm hover:shadow-md transition-shadow duration-300 group">
                                <!-- Product Image -->
                                <div class="aspect-square overflow-hidden bg-gray-100">
                                    <img 
                                        src="{{ $product->image ? asset('storage/' . $product->image) : asset('images/placeholder-product.png') }}" 
                                        alt="{{ $product->name }}" 
                                        class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                                    >
                                </div>
                                
                                <!-- Product Info -->
                                <div class="p-6">
                                    <h3 class="font-medium text-gray-900 mb-2 leading-tight">{{ $product->name }}</h3>
                                    <p class="text-sm text-gray-600 mb-4 line-clamp-2">{{ $product->description }}</p>
                                    
                                    <div class="flex items-center justify-between">
                                        <div>
                                            <span class="text-lg font-semibold text-gray-900">
                                                Rp{{ number_format($product->price, 0, ',', '.') }}
                                            </span>
                                            <div class="text-xs text-gray-500 mt-1">
                                                Stock: {{ $product->stock ?? 0 }}
                                            </div>
                                        </div>
                                        
                                        <a href="{{ route('products.detail', ['id' => $product->id]) }}" 
                                           class="px-4 py-2 bg-gray-900 text-white text-sm font-medium hover:bg-gray-800 transition-colors duration-200 rounded"
                                        >
                                            View
                                        </a>
                                    </div>
                                </div>
                            </div>
                        @endforeach
                    </div>
                @else
                    <!-- Empty State -->
                    <div class="text-center py-20">
                        <div class="text-gray-400 mb-4">
                            <svg class="w-16 h-16 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"></path>
                            </svg>
                        </div>
                        <h3 class="text-xl font-light text-gray-900 mb-2">Tidak Ada Produk</h3>
                        <p class="text-gray-600 mb-6">Belum ada produk dalam kategori ini.</p>
                        <a href="{{ route('catalog.index') }}" 
                           class="inline-flex items-center px-6 py-2.5 bg-gray-900 text-white text-sm font-medium rounded-xl hover:bg-gray-800 transition-colors duration-200"
                        >
                            Lihat Semua Produk
                        </a>
                    </div>
                @endif

                <!-- Pagination -->
                @if($products->hasPages())
                    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
                        <div class="flex items-center justify-between">
                            <div class="flex items-center space-x-2">
                                @if($products->onFirstPage())
                                    <span class="inline-flex items-center px-4 py-2 text-sm font-medium text-gray-400 bg-gray-50 rounded-xl cursor-not-allowed">
                                        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5L8.25 12l7.5-7.5" />
                                        </svg>
                                        Sebelumnya
                                    </span>
                                @else
                                    <a href="{{ $products->previousPageUrl() }}" 
                                       class="inline-flex items-center px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors duration-200"
                                    >
                                        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5L8.25 12l7.5-7.5" />
                                        </svg>
                                        Sebelumnya
                                    </a>
                                @endif
                            </div>

                            <div class="flex items-center space-x-1">
                                @foreach($products->getUrlRange(1, $products->lastPage()) as $page => $url)
                                    @if($page == $products->currentPage())
                                        <span class="inline-flex items-center justify-center w-10 h-10 text-sm font-medium text-white bg-gray-900 rounded-xl">
                                            {{ $page }}
                                        </span>
                                    @else
                                        <a href="{{ $url }}" 
                                           class="inline-flex items-center justify-center w-10 h-10 text-sm font-medium text-gray-700 bg-white border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors duration-200"
                                        >
                                            {{ $page }}
                                        </a>
                                    @endif
                                @endforeach
                            </div>

                            <div class="flex items-center space-x-2">
                                @if($products->hasMorePages())
                                    <a href="{{ $products->nextPageUrl() }}" 
                                       class="inline-flex items-center px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors duration-200"
                                    >
                                        Selanjutnya
                                        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 ml-1" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 4.5l7.5 7.5-7.5 7.5" />
                                        </svg>
                                    </a>
                                @else
                                    <span class="inline-flex items-center px-4 py-2 text-sm font-medium text-gray-400 bg-gray-50 rounded-xl cursor-not-allowed">
                                        Selanjutnya
                                        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 ml-1" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 4.5l7.5 7.5-7.5 7.5" />
                                        </svg>
                                    </span>
                                @endif
                            </div>
                        </div>
                    </div>
                @endif
            </div>
        </div>
    </div>
</div>

<style>
.line-clamp-2 {
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}
</style>
@endsection