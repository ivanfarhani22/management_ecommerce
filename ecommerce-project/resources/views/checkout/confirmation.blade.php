@extends('layouts.app')
@section('show_back_button')
@endsection
@section('content')
<div class="container mx-auto px-4 py-8">
    <h1 class="text-3xl font-bold mb-6">Confirm Your Order</h1>
    <div class="grid md:grid-cols-3 gap-6">
        {{-- Checkout Steps Navigation --}}
        <div class="md:col-span-1 bg-white shadow-md rounded-lg p-4">
            <h3 class="text-xl font-bold mb-4">Checkout Progress</h3>
            <ul class="space-y-2">
                <li class="text-gray-600">1. Customer Information</li>
                <li class="text-gray-600">2. Delivery Method</li>
                <li class="text-gray-600">3. Payment</li>
                <li class="text-blue-500 font-semibold">4. Confirmation</li>
            </ul>
        </div>
        {{-- Order Confirmation --}}
        <div class="md:col-span-2 bg-white shadow-md rounded-lg p-6">
            <h2 class="text-2xl font-bold mb-4">Order Summary</h2>
            
            <div class="grid md:grid-cols-2 gap-4 mb-6">
                {{-- Customer Details --}}
                <div class="bg-gray-50 p-4 rounded-md">
                    <h3 class="font-semibold mb-2">Customer Information</h3>
                    <p>
                        {{ $customerInfo['first_name'] }} {{ $customerInfo['last_name'] }}<br>
                        {{ $customerInfo['email'] }}<br>
                        {{ $customerInfo['phone'] }}
                    </p>
                </div>
                
                {{-- Shipping Details --}}
                <div class="bg-gray-50 p-4 rounded-md">
                    <h3 class="font-semibold mb-2">Shipping Address</h3>
                    <p>
                        {{ $address->street_address }}<br>
                        {{ $address->city }}, {{ $address->state }} {{ $address->postal_code }}<br>
                        {{ $address->country }}
                    </p>
                </div>
            </div>
            
            {{-- Delivery Method --}}
            <div class="bg-gray-50 p-4 rounded-md mb-4">
                <h3 class="font-semibold mb-2">Delivery Method</h3>
                <p>
                    {{ $deliveryMethods[$delivery['delivery_method']]['name'] }} ({{ $deliveryMethods[$delivery['delivery_method']]['days'] }} business days)
                </p>
            </div>
            
            {{-- Payment Method --}}
            <div class="bg-gray-50 p-4 rounded-md mb-4">
                <h3 class="font-semibold mb-2">Payment Method</h3>
                <p>
                    {{ $paymentMethods[$payment['payment_method']] }}
                </p>
            </div>
            
            {{-- Order Items --}}
            <div class="border rounded-md mb-4">
                <h3 class="font-semibold p-4 border-b">Order Items</h3>
                <div class="divide-y">
                    @foreach($cart->cartItems as $item)
                        <div class="p-4 flex justify-between items-center">
                            <div class="flex items-center">
                                @if($item->product->image)
                                    <img src="{{ asset('storage/'.$item->product->image) }}" alt="{{ $item->product->name }}" class="w-16 h-16 object-cover rounded mr-4">
                                @else
                                    <div class="w-16 h-16 bg-gray-200 rounded mr-4 flex items-center justify-center">
                                        <span class="text-gray-500">No Image</span>
                                    </div>
                                @endif
                                <div>
                                    <p class="font-semibold">{{ $item->product->name }}</p>
                                    <p class="text-sm text-gray-500">Quantity: {{ $item->quantity }}</p>
                                </div>
                            </div>
                            <div class="text-right">
                                <p>{{ number_format($item->product->price, 0, ',', '.') }} IDR</p>
                                <p class="font-semibold">{{ number_format($item->product->price * $item->quantity, 0, ',', '.') }} IDR</p>
                            </div>
                        </div>
                    @endforeach
                </div>
            </div>
            
            {{-- Order Totals --}}
            <div class="bg-gray-50 p-4 rounded-md mb-6">
                <div class="flex justify-between mb-2">
                    <span>Subtotal:</span>
                    <span>{{ number_format($subtotal, 0, ',', '.') }} IDR</span>
                </div>
                <div class="flex justify-between mb-2">
                    <span>Shipping:</span>
                    <span>{{ number_format($deliveryCost, 0, ',', '.') }} IDR</span>
                </div>
                <div class="flex justify-between font-bold text-lg">
                    <span>Total:</span>
                    <span>{{ number_format($total, 0, ',', '.') }} IDR</span>
                </div>
            </div>
            
            {{-- Action Buttons --}}
            <div class="flex justify-between">
                <a href="{{ route('checkout.payment') }}" class="bg-gray-300 text-gray-800 py-2 px-6 rounded hover:bg-gray-400">
                    Back to Payment
                </a>
                <form action="{{ route('checkout.complete') }}" method="POST">
                    @csrf
                    <button type="submit" class="bg-blue-600 text-white py-2 px-6 rounded hover:bg-blue-700">
                        Place Order
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection