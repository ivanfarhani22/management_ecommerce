@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-8">
    <div class="grid md:grid-cols-2 gap-8">
        {{-- Product Image Gallery --}}
        <div>
            <div class="mb-4">
                <img src="{{ $product->primary_image }}" alt="{{ $product->name }}" 
                     class="w-full h-96 object-contain rounded-lg" id="main-product-image">
            </div>
            
            <div class="grid grid-cols-4 gap-4">
                @foreach($product->images as $image)
                    <img src="{{ $image->url }}" alt="{{ $product->name }}"
                         class="w-full h-24 object-contain rounded-lg cursor-pointer thumbnail-image"
                         onclick="changeMainImage(this)">
                @endforeach
            </div>
        </div>

        {{-- Product Details --}}
        <div>
            <h1 class="text-3xl font-bold mb-2">{{ $product->name }}</h1>
            
            <div class="flex items-center mb-4">
                <div class="text-yellow-500 mr-2">
                    @for($i = 1; $i <= 5; $i++)
                        <span class="{{ $i <= $product->average_rating ? 'text-yellow-500' : 'text-gray-300' }}">★</span>
                    @endfor
                </div>
                <span class="text-gray-600 ml-2">({{ $product->total_reviews }} reviews)</span>
            </div>

            <p class="text-2xl font-semibold text-blue-600 mb-4">
                {{ number_format($product->price, 2) }} IDR
            </p>

            <div class="mb-4">
                <h3 class="font-bold mb-2">Description</h3>
                <p class="text-gray-700">{{ $product->description }}</p>
            </div>

            <div class="mb-4">
                <h3 class="font-bold mb-2">Specifications</h3>
                <ul class="list-disc list-inside text-gray-700">
                    @foreach($product->specifications as $spec)
                        <li>{{ $spec }}</li>
                    @endforeach
                </ul>
            </div>

            <div class="mb-4">
                <label for="quantity" class="block font-bold mb-2">Quantity</label>
                <div class="flex items-center">
                    <button onclick="changeQuantity(-1)" class="bg-gray-200 px-3 py-1 rounded-l">-</button>
                    <input type="number" id="quantity" value="1" min="1" max="{{ $product->stock }}" 
                           class="w-16 text-center border-t border-b py-1">
                    <button onclick="changeQuantity(1)" class="bg-gray-200 px-3 py-1 rounded-r">+</button>
                </div>
                <p class="text-sm text-gray-600 mt-1">{{ $product->stock }} items in stock</p>
            </div>

            <div class="flex space-x-4">
                <button class="flex-1 bg-blue-500 text-white py-3 rounded-md hover:bg-blue-600">
                    Add to Cart
                </button>
                <button class="flex-1 bg-green-500 text-white py-3 rounded-md hover:bg-green-600">
                    Buy Now
                </button>
            </div>
        </div>
    </div>

    {{-- Product Reviews Section --}}
    <div class="mt-12">
        <h2 class="text-2xl font-bold mb-6">Customer Reviews</h2>
        
        @forelse($product->reviews as $review)
            <div class="bg-white shadow-md rounded-lg p-4 mb-4">
                <div class="flex justify-between items-center mb-2">
                    <div class="text-yellow-500">
                        @for($i = 1; $i <= 5; $i++)
                            <span class="{{ $i <= $review->rating ? 'text-yellow-500' : 'text-gray-300' }}">★</span>
                        @endfor
                    </div>
                    <span class="text-gray-600 text-sm">{{ $review->created_at->diffForHumans() }}</span>
                </div>
                <p class="font-semibold">{{ $review->user->name }}</p>
                <p class="text-gray-700">{{ $review->comment }}</p>
            </div>
        @empty
            <p class="text-gray-600">No reviews yet. Be the first to review this product!</p>
        @endforelse
    </div>
</div>
@endsection

@push('scripts')
<script>
    function changeMainImage(thumbnailImage) {
        const mainImage = document.getElementById('main-product-image');
        mainImage.src = thumbnailImage.src;
    }

    function changeQuantity(change) {
        const quantityInput = document.getElementById('quantity');
        let currentValue = parseInt(quantityInput.value);
        let newValue = currentValue + change;
        
        if (newValue >= 1 && newValue <= {{ $product->stock }}) {
            quantityInput.value = newValue;
        }
    }
</script>
@endpush