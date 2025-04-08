@extends('layouts.app')

@section('content')
<div class="container mx-auto">
    <div class="bg-white shadow-md rounded-lg overflow-hidden">
        <div class="p-6">
            <h1 class="text-4xl font-bold mb-4 text-gray-800">Welcome to Our Store</h1>
            
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div class="bg-blue-100 p-4 rounded-lg">
                    <h2 class="text-2xl font-semibold mb-2 text-blue-800">Latest Products</h2>
                    <p class="text-blue-600">Check out our newest arrivals and trending items.</p>
                    <a href="{{ route('catalog.index') }}" class="mt-4 inline-block bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
                        Browse Catalog
                    </a>
                </div>
                
                <div class="bg-green-100 p-4 rounded-lg">
                    <h2 class="text-2xl font-semibold mb-2 text-green-800">Special Offers</h2>
                    <p class="text-green-600">Don't miss out on our amazing discounts!</p>
                    <a href="{{ route('catalog.index') }}" class="mt-4 inline-block bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600">
                        View Offers
                    </a>
                </div>
                
                <div class="bg-purple-100 p-4 rounded-lg">
                    <h2 class="text-2xl font-semibold mb-2 text-purple-800">Customer Support</h2>
                    <p class="text-purple-600">Need help? Our support team is here for you.</p>
                    <a href="{{ route('catalog.index') }}" class="mt-4 inline-block bg-purple-500 text-white px-4 py-2 rounded hover:bg-purple-600">
                        Help Center
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection