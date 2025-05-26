@extends('layouts.app')

@section('content')
<div class="min-h-screen bg-white">
    <!-- Hero Section -->
    <div class="container mx-auto px-6 py-12 md:py-20">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center max-w-7xl mx-auto">
            <div>
                <h1 class="text-5xl md:text-7xl font-light text-gray-900 mb-6 tracking-tight leading-tight">
                    Welcome to<br>
                    <span class="font-normal">Our Store</span>
                </h1>
                <p class="text-xl text-gray-600 mb-8 font-light leading-relaxed max-w-lg">
                    Discover carefully curated products designed for modern living. Quality meets style in every piece we offer.
                </p>
                <div class="flex flex-col sm:flex-row gap-4">
                    <a href="{{ route('catalog.index') }}" 
                       class="inline-block bg-black text-white font-medium px-8 py-4 hover:bg-gray-800 transition-colors duration-300 text-center">
                        Explore Collection
                    </a>
                    <a href="{{ route('catalog.index') }}" 
                       class="inline-block border border-gray-300 text-gray-900 font-medium px-8 py-4 hover:border-gray-900 transition-colors duration-300 text-center">
                        View Catalog
                    </a>
                </div>
            </div>
            <div class="relative">
                <div class="aspect-square bg-gray-100 rounded-lg overflow-hidden">
                    <img src="https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8M3x8c2hvcHBpbmd8ZW58MHx8MHx8&auto=format&fit=crop&w=800&q=60" 
                         alt="Shopping" 
                         class="w-full h-full object-cover hover:scale-105 transition-transform duration-700">
                </div>
            </div>
        </div>
    </div>

    <!-- Stats Section -->
    <div class="bg-gray-50 py-16">
        <div class="container mx-auto px-6">
            <div class="grid grid-cols-2 md:grid-cols-4 gap-8 max-w-4xl mx-auto">
                <div class="text-center">
                    <div class="text-3xl md:text-4xl font-light text-gray-900 mb-2">{{ $stats['happy_customers'] }}</div>
                    <div class="text-gray-600 font-light">Happy Customers</div>
                </div>
                <div class="text-center">
                    <div class="text-3xl md:text-4xl font-light text-gray-900 mb-2">{{ $stats['total_products'] }}+</div>
                    <div class="text-gray-600 font-light">Products</div>
                </div>
                <div class="text-center">
                    <div class="text-3xl md:text-4xl font-light text-gray-900 mb-2">24/7</div>
                    <div class="text-gray-600 font-light">Support</div>
                </div>
                <div class="text-center">
                    <div class="text-3xl md:text-4xl font-light text-gray-900 mb-2">{{ $stats['satisfaction'] }}</div>
                    <div class="text-gray-600 font-light">Satisfaction</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Featured Products Preview -->
    <div class="py-20">
        <div class="container mx-auto px-6">
            <div class="max-w-6xl mx-auto">
                <div class="text-center mb-16">
                    <h2 class="text-3xl md:text-4xl font-light text-gray-900 mb-4">
                        Featured Products
                    </h2>
                    <p class="text-gray-600 font-light max-w-2xl mx-auto">
                        Handpicked items that represent the best of what we offer
                    </p>
                </div>
                
                @if($featuredProducts->count() > 0)
                <div class="grid grid-cols-1 md:grid-cols-3 gap-8 mb-12">
                    @foreach($featuredProducts->take(3) as $product)
                    <div class="group cursor-pointer">
                        <a href="{{ route('products.show', $product->id) }}">
                            <div class="aspect-square bg-gray-100 mb-4 overflow-hidden rounded-lg">
                                @if($product->image)
                                <img src="{{ asset('storage/' . $product->image) }}" 
                                     alt="{{ $product->name }}"
                                     class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500">
                                @else
                                <div class="w-full h-full bg-gradient-to-br from-gray-200 to-gray-300 flex items-center justify-center group-hover:scale-105 transition-transform duration-500">
                                    <svg class="w-12 h-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                                    </svg>
                                </div>
                                @endif
                            </div>
                            <h3 class="font-light text-gray-900 mb-2">{{ $product->name }}</h3>
                            <p class="text-gray-600 text-sm mb-2">{{ Str::limit($product->description, 40) }}</p>
                            <div class="text-gray-900 font-medium">Rp{{ number_format($product->price, 2) }}</div>
                        </a>
                    </div>
                    @endforeach
                </div>
                @else
                <div class="text-center py-12">
                    <p class="text-gray-500 mb-6">No featured products available at the moment.</p>
                    <a href="{{ route('catalog.index') }}" 
                       class="inline-block border border-gray-300 text-gray-900 font-medium px-8 py-3 hover:border-gray-900 transition-colors duration-300">
                        Browse All Products
                    </a>
                </div>
                @endif
                
                <div class="text-center">
                    <a href="{{ route('catalog.index') }}" 
                       class="inline-block border border-gray-300 text-gray-900 font-medium px-8 py-3 hover:border-gray-900 transition-colors duration-300">
                        View All Products
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- Features Section -->
    <div class="bg-gray-50 py-20">
        <div class="container mx-auto px-6">
            <div class="grid grid-cols-1 md:grid-cols-3 gap-12 max-w-6xl mx-auto">
                <div class="text-center group">
                    <div class="w-16 h-16 mx-auto mb-6 bg-white rounded-full shadow-sm flex items-center justify-center group-hover:shadow-md transition-shadow duration-300">
                        <svg class="w-8 h-8 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                        </svg>
                    </div>
                    <h2 class="text-xl font-light text-gray-900 mb-4">Latest Products</h2>
                    <p class="text-gray-600 font-light leading-relaxed mb-6">
                        Explore our newest arrivals and trending items that everyone's talking about
                    </p>
                    <a href="{{ route('catalog.index') }}" 
                       class="text-gray-900 font-medium hover:text-gray-600 transition-colors duration-300 border-b border-gray-300 hover:border-gray-600">
                        Browse Catalog →
                    </a>
                </div>
                
                <div class="text-center group">
                    <div class="w-16 h-16 mx-auto mb-6 bg-white rounded-full shadow-sm flex items-center justify-center group-hover:shadow-md transition-shadow duration-300">
                        <svg class="w-8 h-8 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                        </svg>
                    </div>
                    <h2 class="text-xl font-light text-gray-900 mb-4">Special Offers</h2>
                    <p class="text-gray-600 font-light leading-relaxed mb-6">
                        Exclusive deals and limited-time promotions you won't find anywhere else
                    </p>
                    <a href="{{ route('catalog.index') }}" 
                       class="text-gray-900 font-medium hover:text-gray-600 transition-colors duration-300 border-b border-gray-300 hover:border-gray-600">
                        View Offers →
                    </a>
                </div>
                
                <div class="text-center group">
                    <div class="w-16 h-16 mx-auto mb-6 bg-white rounded-full shadow-sm flex items-center justify-center group-hover:shadow-md transition-shadow duration-300">
                        <svg class="w-8 h-8 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 8h2a2 2 0 012 2v6a2 2 0 01-2 2h-2v4l-4-4H9a1.994 1.994 0 01-1.414-.586m0 0L11 14h4a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2v4l.586-.586z"></path>
                        </svg>
                    </div>
                    <h2 class="text-xl font-light text-gray-900 mb-4">Customer Support</h2>
                    <p class="text-gray-600 font-light leading-relaxed mb-6">
                        Our dedicated team is here to help with orders, returns, and any questions
                    </p>
                    <a href="{{ route('catalog.index') }}" 
                       class="text-gray-900 font-medium hover:text-gray-600 transition-colors duration-300 border-b border-gray-300 hover:border-gray-600">
                        Help Center →
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- Categories Section -->
    <div class="py-20">
        <div class="container mx-auto px-6">
            <div class="max-w-6xl mx-auto">
                <div class="text-center mb-16">
                    <h2 class="text-3xl md:text-4xl font-light text-gray-900 mb-4">
                        Shop by Category
                    </h2>
                    <p class="text-gray-600 font-light max-w-2xl mx-auto">
                        Find exactly what you're looking for in our carefully organized collections
                    </p>
                </div>
                
                @if($categories->count() > 0)
                <div class="grid grid-cols-2 md:grid-cols-4 gap-6">
                    @foreach($categories->take(4) as $category)
                    <a href="{{ route('catalog.category', $category->slug ?? $category->id) }}" class="group">
                        <div class="aspect-square bg-gray-100 mb-4 flex items-center justify-center group-hover:shadow-lg transition-all duration-500 group-hover:scale-105 rounded-lg overflow-hidden">
                            @if($category->image)
                            <img src="{{ asset('storage/' . $category->image) }}" 
                                 alt="{{ $category->name }}"
                                 class="w-full h-full object-cover">
                            @else
                            <svg class="w-10 h-10 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
                            </svg>
                            @endif
                        </div>
                        <h3 class="font-light text-gray-900 text-center mb-1">{{ $category->name }}</h3>
                        <p class="text-sm text-gray-500 text-center">{{ $category->products_count }}+ items</p>
                    </a>
                    @endforeach
                </div>
                @else
                <div class="text-center py-12">
                    <p class="text-gray-500 mb-6">No categories available at the moment.</p>
                    <a href="{{ route('catalog.index') }}" 
                       class="inline-block border border-gray-300 text-gray-900 font-medium px-8 py-3 hover:border-gray-900 transition-colors duration-300">
                        Browse All Products
                    </a>
                </div>
                @endif
            </div>
        </div>
    </div>

    <!-- Newsletter Section -->
    <div class="bg-gray-900 py-20">
        <div class="container mx-auto px-6">
            <div class="max-w-4xl mx-auto text-center">
                <h2 class="text-3xl md:text-4xl font-light text-white mb-6">
                    Stay in the Loop
                </h2>
                <p class="text-gray-300 font-light leading-relaxed mb-12 max-w-2xl mx-auto">
                    Subscribe to our newsletter and be the first to know about new products, exclusive offers, and upcoming events
                </p>
                <form class="flex flex-col md:flex-row gap-4 max-w-lg mx-auto">
                    <input type="email" 
                           class="flex-grow px-6 py-4 bg-white border-0 focus:outline-none focus:ring-2 focus:ring-gray-400 font-light rounded-lg" 
                           placeholder="Enter your email address">
                    <button type="submit" 
                            class="bg-white text-gray-900 font-medium px-8 py-4 hover:bg-gray-100 transition-colors duration-300 whitespace-nowrap rounded-lg">
                        Subscribe Now
                    </button>
                </form>
                <p class="text-sm text-gray-400 mt-6">No spam, unsubscribe at any time</p>
            </div>
        </div>
    </div>
</div>
@endsection