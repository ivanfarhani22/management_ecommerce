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
                <li class="flex items-center text-green-600">
                    <svg class="w-4 h-4 mr-2" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                    </svg>
                    1. Customer Information
                </li>
                <li class="flex items-center text-green-600">
                    <svg class="w-4 h-4 mr-2" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                    </svg>
                    2. Delivery Method
                </li>
                <li class="flex items-center text-green-600">
                    <svg class="w-4 h-4 mr-2" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                    </svg>
                    3. Payment
                </li>
                <li class="flex items-center text-blue-500 font-semibold">
                    <div class="w-4 h-4 mr-2 bg-blue-500 rounded-full flex items-center justify-center">
                        <span class="text-white text-xs">4</span>
                    </div>
                    Confirmation
                </li>
            </ul>
        </div>

        {{-- Order Confirmation --}}
        <div class="md:col-span-2 bg-white shadow-md rounded-lg p-6">
            <div class="flex items-center justify-between mb-6">
                <h2 class="text-2xl font-bold">Order Summary</h2>
                <div class="text-right">
                    <p class="text-sm text-gray-500">Order Number</p>
                    <p class="font-mono font-semibold">{{ $orderPreview->order_number }}</p>
                </div>
            </div>
            
            <div class="grid md:grid-cols-2 gap-4 mb-6">
                {{-- Customer Details --}}
                <div class="bg-gray-50 p-4 rounded-md">
                    <h3 class="font-semibold mb-2 flex items-center">
                        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                        </svg>
                        Customer Information
                    </h3>
                    <p class="text-sm">
                        <strong>{{ $customerInfo['first_name'] }} {{ $customerInfo['last_name'] }}</strong><br>
                        <span class="text-gray-600">{{ $customerInfo['email'] }}</span><br>
                        <span class="text-gray-600">{{ $customerInfo['phone'] }}</span>
                    </p>
                </div>
                
                {{-- Shipping Details --}}
                <div class="bg-gray-50 p-4 rounded-md">
                    <h3 class="font-semibold mb-2 flex items-center">
                        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
                        </svg>
                        Shipping Address
                    </h3>
                    <p class="text-sm">
                        {{ $address->street_address }}<br>
                        {{ $address->city }}, {{ $address->state }} {{ $address->postal_code }}<br>
                        {{ $address->country }}
                    </p>
                </div>
            </div>
            
            <div class="grid md:grid-cols-2 gap-4 mb-6">
                {{-- Delivery Method --}}
                <div class="bg-gray-50 p-4 rounded-md">
                    <h3 class="font-semibold mb-2 flex items-center">
                        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"></path>
                        </svg>
                        Delivery Method
                    </h3>
                    <p class="text-sm">
                        <strong>{{ $deliveryMethods[$delivery['delivery_method']]['name'] }}</strong><br>
                        <span class="text-gray-600">{{ $deliveryMethods[$delivery['delivery_method']]['days'] }} business days</span><br>
                        <span class="text-green-600 font-medium">{{ number_format($deliveryCost, 0, ',', '.') }} IDR</span>
                    </p>
                </div>
                
                {{-- Payment Method --}}
                <div class="bg-gray-50 p-4 rounded-md">
                    <h3 class="font-semibold mb-2 flex items-center">
                        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"></path>
                        </svg>
                        Payment Method
                    </h3>
                    <p class="text-sm">
                        <strong>{{ $paymentMethods[$payment['payment_method']] }}</strong><br>
                        <span class="text-gray-600">Secure payment via Midtrans</span>
                    </p>
                </div>
            </div>
            
            {{-- Order Items --}}
            <div class="border rounded-md mb-6">
                <h3 class="font-semibold p-4 border-b bg-gray-50 flex items-center">
                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"></path>
                    </svg>
                    Order Items ({{ $cart->cartItems->count() }} items)
                </h3>
                <div class="divide-y max-h-96 overflow-y-auto">
                    @foreach($cart->cartItems as $item)
                        <div class="p-4 flex justify-between items-center hover:bg-gray-50">
                            <div class="flex items-center">
                                @if($item->product->image)
                                    <img src="{{ asset('storage/'.$item->product->image) }}" 
                                         alt="{{ $item->product->name }}" 
                                         class="w-16 h-16 object-cover rounded-lg mr-4 border">
                                @else
                                    <div class="w-16 h-16 bg-gray-200 rounded-lg mr-4 flex items-center justify-center border">
                                        <svg class="w-6 h-6 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                                        </svg>
                                    </div>
                                @endif
                                <div>
                                    <p class="font-semibold text-gray-900">{{ $item->product->name }}</p>
                                    <p class="text-sm text-gray-500">Qty: {{ $item->quantity }}</p>
                                    <p class="text-sm text-gray-600">{{ number_format($item->product->price, 0, ',', '.') }} IDR each</p>
                                </div>
                            </div>
                            <div class="text-right">
                                <p class="font-semibold text-lg">{{ number_format($item->product->price * $item->quantity, 0, ',', '.') }} IDR</p>
                            </div>
                        </div>
                    @endforeach
                </div>
            </div>
            
            {{-- Order Totals --}}
            <div class="bg-gradient-to-r from-gray-50 to-gray-100 p-4 rounded-lg mb-6 border">
                <h3 class="font-semibold mb-3 text-gray-800">Payment Summary</h3>
                <div class="space-y-2">
                    <div class="flex justify-between text-gray-600">
                        <span>Subtotal ({{ $cart->cartItems->count() }} items):</span>
                        <span>{{ number_format($subtotal, 0, ',', '.') }} IDR</span>
                    </div>
                    <div class="flex justify-between text-gray-600">
                        <span>Shipping ({{ $deliveryMethods[$delivery['delivery_method']]['name'] }}):</span>
                        <span>{{ number_format($deliveryCost, 0, ',', '.') }} IDR</span>
                    </div>
                    <hr class="my-2 border-gray-300">
                    <div class="flex justify-between font-bold text-lg text-gray-900">
                        <span>Total Amount:</span>
                        <span class="text-blue-600">{{ number_format($total, 0, ',', '.') }} IDR</span>
                    </div>
                </div>
            </div>
            
            {{-- Important Notice --}}
            <div class="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
                <div class="flex items-start">
                    <svg class="w-5 h-5 text-blue-600 mt-0.5 mr-3" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"></path>
                    </svg>
                    <div>
                        <h4 class="font-semibold text-blue-800 mb-1">Important Information</h4>
                        <ul class="text-sm text-blue-700 space-y-1">
                            <li>• Your order will be processed after payment confirmation</li>
                            <li>• You will receive an email confirmation once payment is completed</li>
                            <li>• Delivery will start within 1 business day after payment</li>
                            <li>• You can track your order status in your account dashboard</li>
                        </ul>
                    </div>
                </div>
            </div>
            
            {{-- Action Buttons --}}
            <div class="flex flex-col sm:flex-row justify-between gap-4">
                <a href="{{ route('checkout.payment') }}" 
                   class="bg-gray-500 text-white py-3 px-6 rounded-lg hover:bg-gray-600 transition duration-200 text-center font-medium">
                    <svg class="w-4 h-4 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
                    </svg>
                    Back to Payment
                </a>
                
                <form action="{{ route('checkout.complete') }}" method="POST" class="flex-1">
                    @csrf
                    <button type="submit" 
                            class="w-full bg-gradient-to-r from-blue-600 to-blue-700 text-white py-3 px-8 rounded-lg hover:from-blue-700 hover:to-blue-800 transition duration-200 font-semibold text-lg shadow-lg hover:shadow-xl transform hover:-translate-y-0.5"
                            id="pay-button">
                        <svg class="w-5 h-5 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                        </svg>
                        Pay Now - {{ number_format($total, 0, ',', '.') }} IDR
                    </button>
                </form>
            </div>

            {{-- Security Badge --}}
            <div class="mt-6 text-center">
                <div class="inline-flex items-center text-sm text-gray-500">
                    <svg class="w-4 h-4 mr-2 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clip-rule="evenodd"></path>
                    </svg>
                    Secured by Midtrans - Your payment information is encrypted and secure
                </div>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const payButton = document.getElementById('pay-button');
    const form = payButton.closest('form');
    
    payButton.addEventListener('click', function(e) {
        // Add loading state
        payButton.disabled = true;
        payButton.innerHTML = `
            <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white inline" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            Processing Payment...
        `;
        
        // Submit form after a short delay to show loading state
        setTimeout(() => {
            form.submit();
        }, 500);
    });
});
</script>
@endsection