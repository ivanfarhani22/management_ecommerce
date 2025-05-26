@extends('layouts.app')
@section('show_back_button')
@endsection

@section('content')
<div class="min-h-screen bg-white">
    <div class="max-w-7xl mx-auto px-4 py-8">
        <!-- Breadcrumb -->
        <nav class="mb-12">
            <div class="flex items-center space-x-2 text-sm text-gray-500">
                <a href="{{ route('home') }}" class="hover:text-black transition-colors">Home</a>
                <span>/</span>
                <a href="{{ route('products.index') }}" class="hover:text-black transition-colors">Products</a>
                <span>/</span>
                <span class="text-black">{{ $product->name }}</span>
            </div>
        </nav>

        <!-- Product Section -->
        <div class="grid lg:grid-cols-2 gap-16 mb-20">
            <!-- Product Image -->
            <div class="aspect-square bg-gray-50 rounded-lg overflow-hidden">
                <img 
                    src="{{ $product->image ? asset('storage/' . $product->image) : asset('images/placeholder-product.png') }}" 
                    alt="{{ $product->name }}" 
                    class="w-full h-full object-cover transition-transform duration-500 hover:scale-105"
                >
            </div>

            <!-- Product Details -->
            <div class="flex flex-col justify-center space-y-8">
                <!-- Title & Category -->
                <div>
                    <h1 class="text-4xl font-light text-black mb-4">{{ $product->name }}</h1>
                    @if($product->category)
                        <p class="text-gray-500 uppercase tracking-wide text-sm">{{ $product->category->name }}</p>
                    @endif
                </div>

                <!-- Description -->
                <div class="text-gray-700 leading-relaxed">
                    {{ $product->description }}
                </div>

                <!-- Price -->
                <div class="text-3xl font-light text-black">
                    Rp {{ number_format($product->price, 0, ',', '.') }}
                </div>

                <!-- Stock -->
                <div class="text-sm text-gray-500">
                    @if($product->stock > 0)
                        {{ $product->stock }} items in stock
                    @else
                        Out of stock
                    @endif
                </div>

                <!-- Add to Cart -->
                @if($product->stock > 0)
                    <form action="{{ route('cart.add') }}" method="POST" class="space-y-6">
                        @csrf
                        <input type="hidden" name="product_id" value="{{ $product->id }}">
                        
                        <!-- Quantity -->
                        <div class="flex items-center space-x-4">
                            <label class="text-sm text-gray-700">Quantity:</label>
                            <div class="flex items-center border border-gray-300 rounded">
                                <button type="button" class="px-3 py-2 hover:bg-gray-50" onclick="decreaseQuantity()">−</button>
                                <input type="number" name="quantity" id="quantity" value="1" min="1" max="{{ $product->stock }}" 
                                       class="w-16 py-2 text-center border-0 focus:ring-0">
                                <button type="button" class="px-3 py-2 hover:bg-gray-50" onclick="increaseQuantity()">+</button>
                            </div>
                        </div>

                        <!-- Add to Cart Button -->
                        <button type="submit" class="w-full bg-black text-white py-4 hover:bg-gray-800 transition-colors duration-300">
                            Add to Cart
                        </button>
                    </form>
                @else
                    <button disabled class="w-full bg-gray-300 text-gray-500 py-4 cursor-not-allowed">
                        Out of Stock
                    </button>
                @endif
            </div>
        </div>

        <!-- Similar Products -->
        @if(count($similarProducts) > 0)
        <div class="border-t border-gray-200 pt-20">
            <h2 class="text-2xl font-light text-black mb-12 text-center">Similar Products</h2>
            
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-8">
                @foreach($similarProducts as $similarProduct)
                    <div class="group">
                        <a href="{{ route('products.show', $similarProduct->id) }}" class="block">
                            <!-- Product Image -->
                            <div class="aspect-square bg-gray-50 rounded-lg overflow-hidden mb-4">
                                <img 
                                    src="{{ $similarProduct->image ? asset('storage/' . $similarProduct->image) : asset('images/placeholder-product.png') }}" 
                                    alt="{{ $similarProduct->name }}" 
                                    class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
                                >
                            </div>
                            
                            <!-- Product Info -->
                            <div class="space-y-2">
                                <h3 class="font-light text-black group-hover:text-gray-600 transition-colors">
                                    {{ $similarProduct->name }}
                                </h3>
                                <p class="text-gray-700">
                                    Rp {{ number_format($similarProduct->price, 0, ',', '.') }}
                                </p>
                            </div>
                        </a>
                    </div>
                @endforeach
            </div>
        </div>
        @endif
    </div>
</div>

<script>
function increaseQuantity() {
    const quantityInput = document.getElementById('quantity');
    const currentValue = parseInt(quantityInput.value);
    const maxValue = parseInt(quantityInput.max);
    
    if (currentValue < maxValue) {
        quantityInput.value = currentValue + 1;
    }
}

function decreaseQuantity() {
    const quantityInput = document.getElementById('quantity');
    const currentValue = parseInt(quantityInput.value);
    const minValue = parseInt(quantityInput.min);
    
    if (currentValue > minValue) {
        quantityInput.value = currentValue - 1;
    }
}
</script>
@endsection