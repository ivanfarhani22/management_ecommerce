@extends('layouts.app')

@section('content')
<div class="min-h-screen bg-gradient-to-r from-blue-50 to-indigo-50 py-12">
    <div class="container mx-auto px-4">
        <!-- Hero Section -->
        <div class="bg-white rounded-2xl shadow-xl overflow-hidden mb-12">
            <div class="flex flex-col md:flex-row">
                <div class="md:w-1/2 p-8 md:p-12">
                    <h1 class="text-4xl md:text-5xl font-bold text-gray-800 mb-6">Welcome to <span class="text-indigo-600">Our Store</span></h1>
                    <p class="text-lg text-gray-600 mb-8">Discover amazing products curated just for you. Quality, style, and satisfaction guaranteed with every purchase.</p>
                    <a href="{{ route('catalog.index') }}" class="inline-block bg-indigo-600 text-white font-semibold px-6 py-3 rounded-lg hover:bg-indigo-700 transition duration-300 transform hover:-translate-y-1 shadow-md">
                        Explore Collection
                    </a>
                </div>
                <div class="md:w-1/2 bg-indigo-600">
                    <div class="h-64 md:h-full w-full bg-cover bg-center" style="background-image: url('https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8M3x8c2hvcHBpbmd8ZW58MHx8MHx8&auto=format&fit=crop&w=800&q=60');"></div>
                </div>
            </div>
        </div>

        <!-- Features Section -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8 mb-12">
            <div class="bg-white p-8 rounded-2xl shadow-lg transform transition duration-300 hover:scale-105">
                <div class="w-14 h-14 mb-6 rounded-full bg-blue-100 flex items-center justify-center">
                    <svg class="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                    </svg>
                </div>
                <h2 class="text-2xl font-bold text-gray-800 mb-4">Latest Products</h2>
                <p class="text-gray-600 mb-6">Explore our newest arrivals and trending items. Stay ahead with the latest trends in the market.</p>
                <a href="{{ route('catalog.index') }}" class="inline-flex items-center text-blue-600 font-medium hover:text-blue-800">
                    Browse Catalog
                    <svg class="w-4 h-4 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3"></path>
                    </svg>
                </a>
            </div>
            
            <div class="bg-white p-8 rounded-2xl shadow-lg transform transition duration-300 hover:scale-105">
                <div class="w-14 h-14 mb-6 rounded-full bg-green-100 flex items-center justify-center">
                    <svg class="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                    </svg>
                </div>
                <h2 class="text-2xl font-bold text-gray-800 mb-4">Special Offers</h2>
                <p class="text-gray-600 mb-6">Exclusive deals and limited-time promotions. Save big on your favorite products with our special discounts.</p>
                <a href="{{ route('catalog.index') }}" class="inline-flex items-center text-green-600 font-medium hover:text-green-800">
                    View Offers
                    <svg class="w-4 h-4 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3"></path>
                    </svg>
                </a>
            </div>
            
            <div class="bg-white p-8 rounded-2xl shadow-lg transform transition duration-300 hover:scale-105">
                <div class="w-14 h-14 mb-6 rounded-full bg-purple-100 flex items-center justify-center">
                    <svg class="w-8 h-8 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8h2a2 2 0 012 2v6a2 2 0 01-2 2h-2v4l-4-4H9a1.994 1.994 0 01-1.414-.586m0 0L11 14h4a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2v4l.586-.586z"></path>
                    </svg>
                </div>
                <h2 class="text-2xl font-bold text-gray-800 mb-4">Customer Support</h2>
                <p class="text-gray-600 mb-6">Our dedicated team is here to help. Get assistance with orders, returns, and any questions you might have.</p>
                <a href="{{ route('catalog.index') }}" class="inline-flex items-center text-purple-600 font-medium hover:text-purple-800">
                    Help Center
                    <svg class="w-4 h-4 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3"></path>
                    </svg>
                </a>
            </div>
        </div>

        <!-- Categories Section -->
        <div class="bg-white rounded-2xl shadow-xl overflow-hidden mb-12">
            <div class="p-8 md:p-12">
                <h2 class="text-3xl font-bold text-gray-800 mb-8 text-center">Popular Categories</h2>
                <div class="grid grid-cols-2 md:grid-cols-4 gap-6">
                    <a href="{{ route('catalog.index') }}" class="group">
                        <div class="bg-indigo-100 rounded-xl p-6 text-center transition duration-300 group-hover:bg-indigo-200">
                            <div class="w-12 h-12 mx-auto mb-4 rounded-full bg-indigo-500 flex items-center justify-center">
                                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
                                </svg>
                            </div>
                            <h3 class="font-semibold text-gray-800">Electronics</h3>
                        </div>
                    </a>
                    
                    <a href="{{ route('catalog.index') }}" class="group">
                        <div class="bg-red-100 rounded-xl p-6 text-center transition duration-300 group-hover:bg-red-200">
                            <div class="w-12 h-12 mx-auto mb-4 rounded-full bg-red-500 flex items-center justify-center">
                                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"></path>
                                </svg>
                            </div>
                            <h3 class="font-semibold text-gray-800">Fashion</h3>
                        </div>
                    </a>
                    
                    <a href="{{ route('catalog.index') }}" class="group">
                        <div class="bg-green-100 rounded-xl p-6 text-center transition duration-300 group-hover:bg-green-200">
                            <div class="w-12 h-12 mx-auto mb-4 rounded-full bg-green-500 flex items-center justify-center">
                                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path>
                                </svg>
                            </div>
                            <h3 class="font-semibold text-gray-800">Home</h3>
                        </div>
                    </a>
                    
                    <a href="{{ route('catalog.index') }}" class="group">
                        <div class="bg-yellow-100 rounded-xl p-6 text-center transition duration-300 group-hover:bg-yellow-200">
                            <div class="w-12 h-12 mx-auto mb-4 rounded-full bg-yellow-500 flex items-center justify-center">
                                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v13m0-13V6a2 2 0 112 2h-2zm0 0V5.5A2.5 2.5 0 109.5 8H12zm-7 4h14M5 12a2 2 0 110-4h14a2 2 0 110 4M5 12v7a2 2 0 002 2h10a2 2 0 002-2v-7"></path>
                                </svg>
                            </div>
                            <h3 class="font-semibold text-gray-800">Gifts</h3>
                        </div>
                    </a>
                </div>
            </div>
        </div>

        <!-- Newsletter Section -->
        <div class="bg-indigo-600 rounded-2xl shadow-xl overflow-hidden">
            <div class="p-8 md:p-12 text-center">
                <h2 class="text-3xl font-bold text-white mb-4">Stay Updated</h2>
                <p class="text-indigo-100 mb-8 max-w-xl mx-auto">Subscribe to our newsletter and be the first to know about new products, special offers, and exclusive events.</p>
                <form class="flex flex-col md:flex-row max-w-md mx-auto gap-4">
                    <input type="email" class="flex-grow px-4 py-3 rounded-lg focus:outline-none" placeholder="Your email address">
                    <button type="submit" class="bg-white text-indigo-600 font-semibold px-6 py-3 rounded-lg hover:bg-indigo-50 transition duration-300">
                        Subscribe
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection