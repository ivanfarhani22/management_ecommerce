@extends('layouts.app')
@section('content')
<div class="container mx-auto px-4 py-8">
    <div class="max-w-2xl mx-auto">
        <div class="bg-white shadow-lg rounded-lg p-6">
            <h1 class="text-2xl font-bold mb-6 text-center">Complete Your Payment</h1>
            
            {{-- Order Details --}}
            <div class="bg-gray-50 p-4 rounded-lg mb-6">
                <h3 class="font-semibold mb-3">Order Details</h3>
                <div class="flex justify-between items-center mb-2">
                    <span>Order Number:</span>
                    <span class="font-mono">{{ $order->order_number }}</span>
                </div>
                <div class="flex justify-between items-center mb-2">
                    <span>Total Amount:</span>
                    <span class="font-semibold text-lg">${{ number_format($order->total_amount, 2) }}</span>
                </div>
                <div class="flex justify-between items-center mb-2">
                    <span>Payment Status:</span>
                    <span class="px-2 py-1 rounded text-sm 
                        @if($order->payment_status === 'pending') bg-yellow-100 text-yellow-800
                        @elseif($order->payment_status === 'completed') bg-green-100 text-green-800
                        @else bg-red-100 text-red-800
                        @endif">
                        {{ ucfirst($order->payment_status) }}
                    </span>
                </div>
            </div>

            {{-- Order Items --}}
            <div class="mb-6">
                <h3 class="font-semibold mb-3">Items</h3>
                <div class="space-y-2">
                    @foreach($order->items as $item)
                    <div class="flex justify-between items-center py-2 border-b border-gray-200">
                        <div>
                            <span class="font-medium">{{ $item->product_name }}</span>
                            <span class="text-gray-500 text-sm ml-2">x{{ $item->quantity }}</span>
                        </div>
                        <span>${{ number_format($item->price * $item->quantity, 2) }}</span>
                    </div>
                    @endforeach
                </div>
            </div>

            {{-- Payment Methods --}}
            @if($order->payment_status === 'pending')
            <form action="{{ route('payment.process', $order->id) }}" method="POST" id="payment-form">
                @csrf
                
                <div class="mb-6">
                    <h3 class="font-semibold mb-4">Select Payment Method</h3>
                    
                    {{-- Credit Card --}}
                    <div class="mb-4">
                        <label class="flex items-center p-4 border rounded-lg cursor-pointer hover:bg-gray-50">
                            <input type="radio" name="payment_method" value="credit_card" class="mr-3" required>
                            <div class="flex items-center">
                                <svg class="w-6 h-6 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"></path>
                                </svg>
                                <span class="font-medium">Credit Card</span>
                            </div>
                        </label>
                        
                        {{-- Credit Card Form --}}
                        <div id="credit-card-form" class="hidden mt-4 p-4 bg-gray-50 rounded-lg">
                            <div class="grid grid-cols-1 gap-4">
                                <div>
                                    <label class="block text-sm font-medium mb-1">Card Number</label>
                                    <input type="text" name="card_number" placeholder="1234 5678 9012 3456" 
                                           class="w-full p-2 border rounded-lg" maxlength="19">
                                </div>
                                <div class="grid grid-cols-2 gap-4">
                                    <div>
                                        <label class="block text-sm font-medium mb-1">Expiry Date</label>
                                        <input type="text" name="expiry_date" placeholder="MM/YY" 
                                               class="w-full p-2 border rounded-lg" maxlength="5">
                                    </div>
                                    <div>
                                        <label class="block text-sm font-medium mb-1">CVV</label>
                                        <input type="text" name="cvv" placeholder="123" 
                                               class="w-full p-2 border rounded-lg" maxlength="4">
                                    </div>
                                </div>
                                <div>
                                    <label class="block text-sm font-medium mb-1">Cardholder Name</label>
                                    <input type="text" name="cardholder_name" placeholder="John Doe" 
                                           class="w-full p-2 border rounded-lg">
                                </div>
                            </div>
                        </div>
                    </div>

                    {{-- PayPal --}}
                    <div class="mb-4">
                        <label class="flex items-center p-4 border rounded-lg cursor-pointer hover:bg-gray-50">
                            <input type="radio" name="payment_method" value="paypal" class="mr-3">
                            <div class="flex items-center">
                                <svg class="w-6 h-6 mr-2 text-blue-600" fill="currentColor" viewBox="0 0 24 24">
                                    <path d="M7.076 21.337H2.47a.641.641 0 0 1-.633-.74L4.944.901C5.026.382 5.474 0 5.998 0h7.46c2.57 0 4.578.543 5.69 1.81 1.01 1.15 1.304 2.42 1.012 4.287-.023.143-.047.288-.077.437-.983 5.05-4.349 6.797-8.647 6.797h-2.19c-.524 0-.968.382-1.05.9l-1.12 7.106zm14.146-14.42a3.35 3.35 0 0 0-.607-.421c-.436-.24-.96-.412-1.571-.51a11.12 11.12 0 0 0-1.879-.16H9.178c-.524 0-.968.382-1.05.9l-.69 4.378-.395 2.505c-.018.114-.006.234.034.344.04.11.108.206.194.274a.653.653 0 0 0 .344.1h2.19c4.298 0 7.664-1.747 8.647-6.797.03-.149.054-.294.077-.437.201-1.284.107-2.338-.302-3.176z"/>
                                </svg>
                                <span class="font-medium">PayPal</span>
                            </div>
                        </label>
                    </div>

                    {{-- Bank Transfer --}}
                    <div class="mb-4">
                        <label class="flex items-center p-4 border rounded-lg cursor-pointer hover:bg-gray-50">
                            <input type="radio" name="payment_method" value="bank_transfer" class="mr-3">
                            <div class="flex items-center">
                                <svg class="w-6 h-6 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path>
                                </svg>
                                <span class="font-medium">Bank Transfer</span>
                            </div>
                        </label>
                    </div>
                </div>

                {{-- Billing Address --}}
                <div class="mb-6">
                    <h3 class="font-semibold mb-4">Billing Address</h3>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-medium mb-1">First Name</label>
                            <input type="text" name="first_name" value="{{ old('first_name', $user->first_name ?? '') }}" 
                                   class="w-full p-2 border rounded-lg" required>
                        </div>
                        <div>
                            <label class="block text-sm font-medium mb-1">Last Name</label>
                            <input type="text" name="last_name" value="{{ old('last_name', $user->last_name ?? '') }}" 
                                   class="w-full p-2 border rounded-lg" required>
                        </div>
                        <div class="md:col-span-2">
                            <label class="block text-sm font-medium mb-1">Address</label>
                            <input type="text" name="address" value="{{ old('address', $user->address ?? '') }}" 
                                   class="w-full p-2 border rounded-lg" required>
                        </div>
                        <div>
                            <label class="block text-sm font-medium mb-1">City</label>
                            <input type="text" name="city" value="{{ old('city', $user->city ?? '') }}" 
                                   class="w-full p-2 border rounded-lg" required>
                        </div>
                        <div>
                            <label class="block text-sm font-medium mb-1">ZIP Code</label>
                            <input type="text" name="zip_code" value="{{ old('zip_code', $user->zip_code ?? '') }}" 
                                   class="w-full p-2 border rounded-lg" required>
                        </div>
                    </div>
                </div>

                {{-- Terms and Conditions --}}
                <div class="mb-6">
                    <label class="flex items-start">
                        <input type="checkbox" name="terms_accepted" class="mt-1 mr-2" required>
                        <span class="text-sm">
                            I agree to the <a href="#" class="text-blue-600 hover:underline">Terms and Conditions</a> 
                            and <a href="#" class="text-blue-600 hover:underline">Privacy Policy</a>
                        </span>
                    </label>
                </div>

                {{-- Submit Button --}}
                <button type="submit" 
                        class="w-full bg-blue-600 text-white py-3 px-4 rounded-lg font-semibold hover:bg-blue-700 transition duration-200">
                    Complete Payment - ${{ number_format($order->total_amount, 2) }}
                </button>
            </form>
            @else
            <div class="text-center py-8">
                <div class="mb-4">
                    @if($order->payment_status === 'completed')
                        <svg class="w-16 h-16 mx-auto text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                        </svg>
                        <h3 class="text-xl font-semibold text-green-600 mt-4">Payment Completed</h3>
                        <p class="text-gray-600 mt-2">Thank you for your purchase!</p>
                    @else
                        <svg class="w-16 h-16 mx-auto text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                        </svg>
                        <h3 class="text-xl font-semibold text-red-600 mt-4">Payment Failed</h3>
                        <p class="text-gray-600 mt-2">Please try again or contact support.</p>
                    @endif
                </div>
                
                <div class="space-x-4">
                    <a href="{{ route('orders.show', $order->id) }}" 
                       class="inline-block bg-blue-600 text-white py-2 px-4 rounded-lg hover:bg-blue-700">
                        View Order Details
                    </a>
                    <a href="{{ route('home') }}" 
                       class="inline-block bg-gray-600 text-white py-2 px-4 rounded-lg hover:bg-gray-700">
                        Continue Shopping
                    </a>
                </div>
            </div>
            @endif
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const paymentMethods = document.querySelectorAll('input[name="payment_method"]');
    const creditCardForm = document.getElementById('credit-card-form');
    
    paymentMethods.forEach(method => {
        method.addEventListener('change', function() {
            if (this.value === 'credit_card') {
                creditCardForm.classList.remove('hidden');
                // Make credit card fields required
                creditCardForm.querySelectorAll('input').forEach(input => {
                    input.setAttribute('required', 'required');
                });
            } else {
                creditCardForm.classList.add('hidden');
                // Remove required attribute from credit card fields
                creditCardForm.querySelectorAll('input').forEach(input => {
                    input.removeAttribute('required');
                });
            }
        });
    });

    // Format card number input
    const cardNumberInput = document.querySelector('input[name="card_number"]');
    if (cardNumberInput) {
        cardNumberInput.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\s/g, '').replace(/[^0-9]/gi, '');
            let formattedValue = value.match(/.{1,4}/g)?.join(' ') || value;
            e.target.value = formattedValue;
        });
    }

    // Format expiry date input
    const expiryInput = document.querySelector('input[name="expiry_date"]');
    if (expiryInput) {
        expiryInput.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '');
            if (value.length >= 2) {
                value = value.substring(0, 2) + '/' + value.substring(2, 4);
            }
            e.target.value = value;
        });
    }

    // CVV input validation
    const cvvInput = document.querySelector('input[name="cvv"]');
    if (cvvInput) {
        cvvInput.addEventListener('input', function(e) {
            e.target.value = e.target.value.replace(/[^0-9]/g, '');
        });
    }
});
</script>
@endsection