@extends('layouts.app')
@section('show_back_button')
@endsection

@section('content')
<div class="min-h-screen bg-gray-50">
    <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8 lg:py-12">
        <!-- Header -->
        <div class="text-center mb-12">
            <h1 class="text-2xl sm:text-3xl lg:text-4xl font-light text-gray-900 tracking-tight">
                Delivery Method
            </h1>
            <p class="mt-2 text-sm text-gray-500 font-light">
                Choose your preferred delivery option
            </p>
        </div>

        <div class="grid lg:grid-cols-5 gap-8 lg:gap-12">
            <!-- Progress Steps - Sidebar -->
            <div class="lg:col-span-2">
                <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 lg:p-8 sticky top-8">
                    <h2 class="text-lg font-medium text-gray-900 mb-8">
                        Progress
                    </h2>
                    
                    <div class="space-y-6">
                        <!-- Step 1 - Completed -->
                        <div class="flex items-center space-x-4">
                            <div class="bg-green-100 text-green-600 w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium">
                                ✓
                            </div>
                            <div class="flex-1">
                                <p class="text-gray-500 text-sm line-through">
                                    Customer Information
                                </p>
                                <p class="text-xs text-green-600 mt-1">
                                    Completed
                                </p>
                            </div>
                        </div>

                        <!-- Step 2 - Current -->
                        <div class="flex items-center space-x-4">
                            <div class="bg-black text-white w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium">
                                2
                            </div>
                            <div class="flex-1">
                                <p class="text-gray-900 font-medium text-sm">
                                    Delivery Method
                                </p>
                                <p class="text-xs text-gray-400 mt-1">
                                    Shipping options
                                </p>
                            </div>
                        </div>

                        <!-- Step 3 -->
                        <div class="flex items-center space-x-4">
                            <div class="bg-gray-100 text-gray-400 w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium">
                                3
                            </div>
                            <div class="flex-1">
                                <p class="text-gray-500 text-sm">
                                    Payment
                                </p>
                                <p class="text-xs text-gray-400 mt-1">
                                    Payment method
                                </p>
                            </div>
                        </div>

                        <!-- Step 4 -->
                        <div class="flex items-center space-x-4">
                            <div class="bg-gray-100 text-gray-400 w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium">
                                4
                            </div>
                            <div class="flex-1">
                                <p class="text-gray-500 text-sm">
                                    Confirmation
                                </p>
                                <p class="text-xs text-gray-400 mt-1">
                                    Order summary
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Main Form -->
            <div class="lg:col-span-3">
                <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 lg:p-8">
                    <form action="{{ route('checkout.delivery') }}" method="POST" class="space-y-8">
                        @csrf

                        <!-- Form Header -->
                        <div class="border-b border-gray-100 pb-6">
                            <h2 class="text-xl font-medium text-gray-900">
                                Select Delivery Method
                            </h2>
                            <p class="mt-1 text-sm text-gray-500 font-light">
                                Choose your preferred shipping option
                            </p>
                        </div>

                        <!-- Delivery Options -->
                        <div class="space-y-4">
                            <!-- Standard Delivery -->
                            <div class="relative">
                                <input type="radio" 
                                       name="delivery_method" 
                                       id="standard_delivery" 
                                       value="standard" 
                                       class="peer sr-only" 
                                       required 
                                       checked>
                                <label for="standard_delivery" 
                                       class="block p-6 border border-gray-200 rounded-lg cursor-pointer 
                                              transition-all duration-300 hover:border-gray-300 hover:shadow-sm
                                              peer-checked:border-gray-900 peer-checked:bg-gray-50">
                                    <div class="flex items-center justify-between">
                                        <div class="flex items-center space-x-4">
                                            <div class="w-4 h-4 border border-gray-300 rounded-full relative
                                                        peer-checked:border-gray-900 peer-checked:bg-gray-900
                                                        transition-all duration-300">
                                            </div>
                                            <div>
                                                <h3 class="text-base font-medium text-gray-900">Standard Delivery</h3>
                                                <p class="text-sm text-gray-500 mt-1">3-5 Business Days</p>
                                                <div class="flex items-center mt-2 text-xs text-gray-400">
                                                    <svg class="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"></path>
                                                    </svg>
                                                    Standard shipping via courier
                                                </div>
                                            </div>
                                        </div>
                                        <div class="text-right">
                                            <span class="text-lg font-medium text-gray-900">IDR 5.00</span>
                                            <p class="text-xs text-gray-500">Shipping fee</p>
                                        </div>
                                    </div>
                                </label>
                            </div>

                            <!-- Express Delivery -->
                            <div class="relative">
                                <input type="radio" 
                                       name="delivery_method" 
                                       id="express_delivery" 
                                       value="express" 
                                       class="peer sr-only">
                                <label for="express_delivery" 
                                       class="block p-6 border border-gray-200 rounded-lg cursor-pointer 
                                              transition-all duration-300 hover:border-gray-300 hover:shadow-sm
                                              peer-checked:border-gray-900 peer-checked:bg-gray-50">
                                    <div class="flex items-center justify-between">
                                        <div class="flex items-center space-x-4">
                                            <div class="w-4 h-4 border border-gray-300 rounded-full relative
                                                        peer-checked:border-gray-900 peer-checked:bg-gray-900
                                                        transition-all duration-300">
                                            </div>
                                            <div>
                                                <div class="flex items-center space-x-2">
                                                    <h3 class="text-base font-medium text-gray-900">Express Delivery</h3>
                                                    <span class="px-2 py-1 bg-orange-100 text-orange-600 text-xs font-medium rounded-full">
                                                        Fast
                                                    </span>
                                                </div>
                                                <p class="text-sm text-gray-500 mt-1">1-2 Business Days</p>
                                                <div class="flex items-center mt-2 text-xs text-gray-400">
                                                    <svg class="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
                                                    </svg>
                                                    Priority handling & shipping
                                                </div>
                                            </div>
                                        </div>
                                        <div class="text-right">
                                            <span class="text-lg font-medium text-gray-900">IDR 15.00</span>
                                            <p class="text-xs text-gray-500">Shipping fee</p>
                                        </div>
                                    </div>
                                </label>
                            </div>
                        </div>

                        @php
                            $customerInfo = session('checkout.customer_info');
                            $address = isset($customerInfo['address_id']) ? App\Models\Address::find($customerInfo['address_id']) : null;
                        @endphp

                        <!-- Address Section -->
                        @if(!$address)
                            <div class="space-y-6 border-t border-gray-100 pt-8">
                                <div>
                                    <h3 class="text-lg font-medium text-gray-900 mb-2">
                                        Shipping Address
                                    </h3>
                                    <p class="text-sm text-gray-500 font-light">
                                        Enter your complete shipping address
                                    </p>
                                </div>

                                <div class="space-y-6">
                                    <div class="space-y-2">
                                        <label for="address" class="block text-sm font-medium text-gray-700">
                                            Street Address
                                        </label>
                                        <textarea name="address" 
                                                  id="address" 
                                                  rows="3"
                                                  class="w-full px-4 py-3 border border-gray-200 rounded-lg text-sm 
                                                         focus:outline-none focus:ring-2 focus:ring-gray-900 focus:border-transparent
                                                         transition-all duration-300 hover:border-gray-300 resize-none"
                                                  placeholder="Enter your complete street address"
                                                  required>{{ old('address') }}</textarea>
                                    </div>

                                    <div class="grid sm:grid-cols-2 gap-6">
                                        <div class="space-y-2">
                                            <label for="city" class="block text-sm font-medium text-gray-700">
                                                City
                                            </label>
                                            <input type="text" 
                                                   name="city" 
                                                   id="city"
                                                   class="w-full px-4 py-3 border border-gray-200 rounded-lg text-sm 
                                                          focus:outline-none focus:ring-2 focus:ring-gray-900 focus:border-transparent
                                                          transition-all duration-300 hover:border-gray-300"
                                                   value="{{ old('city') }}" 
                                                   required>
                                        </div>

                                        <div class="space-y-2">
                                            <label for="state" class="block text-sm font-medium text-gray-700">
                                                State/Province
                                            </label>
                                            <input type="text" 
                                                   name="state" 
                                                   id="state"
                                                   class="w-full px-4 py-3 border border-gray-200 rounded-lg text-sm 
                                                          focus:outline-none focus:ring-2 focus:ring-gray-900 focus:border-transparent
                                                          transition-all duration-300 hover:border-gray-300"
                                                   value="{{ old('state') }}" 
                                                   required>
                                        </div>
                                    </div>

                                    <div class="grid sm:grid-cols-2 gap-6">
                                        <div class="space-y-2">
                                            <label for="postal_code" class="block text-sm font-medium text-gray-700">
                                                Postal Code
                                            </label>
                                            <input type="text" 
                                                   name="postal_code" 
                                                   id="postal_code"
                                                   class="w-full px-4 py-3 border border-gray-200 rounded-lg text-sm 
                                                          focus:outline-none focus:ring-2 focus:ring-gray-900 focus:border-transparent
                                                          transition-all duration-300 hover:border-gray-300"
                                                   value="{{ old('postal_code') }}" 
                                                   required>
                                        </div>

                                        <div class="space-y-2">
                                            <label for="country" class="block text-sm font-medium text-gray-700">
                                                Country
                                            </label>
                                            <input type="text" 
                                                   name="country" 
                                                   id="country"
                                                   class="w-full px-4 py-3 border border-gray-200 rounded-lg text-sm 
                                                          focus:outline-none focus:ring-2 focus:ring-gray-900 focus:border-transparent
                                                          transition-all duration-300 hover:border-gray-300"
                                                   value="{{ old('country', 'Indonesia') }}" 
                                                   required>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        @else
                            <div class="border-t border-gray-100 pt-8">
                                <div class="bg-green-50 border border-green-200 rounded-lg p-6">
                                    <div class="flex items-start space-x-3">
                                        <div class="flex-shrink-0">
                                            <svg class="w-5 h-5 text-green-600 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                            </svg>
                                        </div>
                                        <div class="flex-1">
                                            <h3 class="text-sm font-medium text-green-900 mb-2">
                                                Selected Shipping Address
                                            </h3>
                                            <div class="text-sm text-green-800 space-y-1">
                                                <p>{{ $address->street_address }}</p>
                                                <p>{{ $address->city }}, {{ $address->state }} {{ $address->postal_code }}</p>
                                                <p>{{ $address->country }}</p>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <!-- Hidden fields -->
                                    <input type="hidden" name="address" value="{{ $address->street_address }}">
                                    <input type="hidden" name="city" value="{{ $address->city }}">
                                    <input type="hidden" name="state" value="{{ $address->state }}">
                                    <input type="hidden" name="postal_code" value="{{ $address->postal_code }}">
                                    <input type="hidden" name="country" value="{{ $address->country }}">
                                </div>
                            </div>
                        @endif

                        <!-- Submit Button -->
                        <div class="border-t border-gray-100 pt-8">
                            <button type="submit" 
                                    class="w-full bg-gray-900 text-white py-4 px-6 rounded-lg text-sm font-medium
                                           hover:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-gray-900 focus:ring-offset-2
                                           transition-all duration-300 hover:shadow-lg transform hover:-translate-y-0.5">
                                Continue to Payment
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
/* Custom radio button styling */
input[type="radio"]:checked + label .w-4.h-4 {
    background-color: #111827;
    border-color: #111827;
}

input[type="radio"]:checked + label .w-4.h-4::after {
    content: '';
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 6px;
    height: 6px;
    background-color: white;
    border-radius: 50%;
}

/* Smooth transitions for all interactive elements */
* {
    transition-property: color, background-color, border-color, text-decoration-color, fill, stroke, opacity, box-shadow, transform, filter, backdrop-filter;
    transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
    transition-duration: 300ms;
}

/* Custom focus styles */
input:focus,
textarea:focus,
button:focus {
    box-shadow: 0 0 0 3px rgba(17, 24, 39, 0.1);
}

/* Subtle hover effects */
.hover\:shadow-lg:hover {
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
}

/* Enhanced radio button selection styling */
input[type="radio"]:checked + label {
    background-color: rgba(249, 250, 251, 1);
    border-color: #111827;
}

/* Address card styling */
.bg-green-50 {
    background-color: rgba(240, 253, 244, 1);
}
</style>
@endsection