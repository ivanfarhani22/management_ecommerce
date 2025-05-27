@extends('layouts.app')
@section('show_back_button')
@endsection

@section('content')
<div class="min-h-screen bg-gray-50">
    <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8 lg:py-12">
        <!-- Header -->
        <div class="text-center mb-12">
            <h1 class="text-2xl sm:text-3xl lg:text-4xl font-light text-gray-900 tracking-tight">
                Checkout
            </h1>
            <p class="mt-2 text-sm text-gray-500 font-light">
                Complete your purchase in a few simple steps
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
                        <!-- Step 1 -->
                        <div class="flex items-center space-x-4">
                            <div class="{{ request()->routeIs('checkout.index') ? 'bg-black text-white' : 'bg-gray-100 text-gray-400' }} 
                                        w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium transition-colors duration-300">
                                1
                            </div>
                            <div class="flex-1">
                                <p class="{{ request()->routeIs('checkout.index') ? 'text-gray-900 font-medium' : 'text-gray-500' }} 
                                          text-sm transition-colors duration-300">
                                    Customer Information
                                </p>
                                <p class="text-xs text-gray-400 mt-1">
                                    Personal details
                                </p>
                            </div>
                        </div>

                        <!-- Step 2 -->
                        <div class="flex items-center space-x-4">
                            <div class="{{ request()->routeIs('checkout.delivery') ? 'bg-black text-white' : 'bg-gray-100 text-gray-400' }} 
                                        w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium transition-colors duration-300">
                                2
                            </div>
                            <div class="flex-1">
                                <p class="{{ request()->routeIs('checkout.delivery') ? 'text-gray-900 font-medium' : 'text-gray-500' }} 
                                          text-sm transition-colors duration-300">
                                    Delivery Method
                                </p>
                                <p class="text-xs text-gray-400 mt-1">
                                    Shipping options
                                </p>
                            </div>
                        </div>

                        <!-- Step 3 -->
                        <div class="flex items-center space-x-4">
                            <div class="{{ request()->routeIs('checkout.payment') ? 'bg-black text-white' : 'bg-gray-100 text-gray-400' }} 
                                        w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium transition-colors duration-300">
                                3
                            </div>
                            <div class="flex-1">
                                <p class="{{ request()->routeIs('checkout.payment') ? 'text-gray-900 font-medium' : 'text-gray-500' }} 
                                          text-sm transition-colors duration-300">
                                    Payment
                                </p>
                                <p class="text-xs text-gray-400 mt-1">
                                    Payment method
                                </p>
                            </div>
                        </div>

                        <!-- Step 4 -->
                        <div class="flex items-center space-x-4">
                            <div class="{{ request()->routeIs('checkout.confirmation') ? 'bg-black text-white' : 'bg-gray-100 text-gray-400' }} 
                                        w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium transition-colors duration-300">
                                4
                            </div>
                            <div class="flex-1">
                                <p class="{{ request()->routeIs('checkout.confirmation') ? 'text-gray-900 font-medium' : 'text-gray-500' }} 
                                          text-sm transition-colors duration-300">
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
                    <form action="{{ route('checkout.customer-info') }}" method="POST" class="space-y-8">
                        @csrf

                        <!-- Form Header -->
                        <div class="border-b border-gray-100 pb-6">
                            <h2 class="text-xl font-medium text-gray-900">
                                Customer Information
                            </h2>
                            <p class="mt-1 text-sm text-gray-500 font-light">
                                Please provide your contact details
                            </p>
                        </div>

                        <!-- Personal Information -->
                        <div class="space-y-6">
                            <div class="grid sm:grid-cols-2 gap-6">
                                <div class="space-y-2">
                                    <label for="first_name" class="block text-sm font-medium text-gray-700">
                                        First Name
                                    </label>
                                    <input type="text" 
                                           name="first_name" 
                                           id="first_name"
                                           class="w-full px-4 py-3 border border-gray-200 rounded-lg text-sm 
                                                  focus:outline-none focus:ring-2 focus:ring-gray-900 focus:border-transparent
                                                  transition-all duration-300 hover:border-gray-300"
                                           value="{{ old('first_name', auth()->user()->first_name ?? '') }}" 
                                           required>
                                </div>

                                <div class="space-y-2">
                                    <label for="last_name" class="block text-sm font-medium text-gray-700">
                                        Last Name
                                    </label>
                                    <input type="text" 
                                           name="last_name" 
                                           id="last_name"
                                           class="w-full px-4 py-3 border border-gray-200 rounded-lg text-sm 
                                                  focus:outline-none focus:ring-2 focus:ring-gray-900 focus:border-transparent
                                                  transition-all duration-300 hover:border-gray-300"
                                           value="{{ old('last_name', auth()->user()->last_name ?? '') }}" 
                                           required>
                                </div>
                            </div>

                            <div class="space-y-2">
                                <label for="email" class="block text-sm font-medium text-gray-700">
                                    Email Address
                                </label>
                                <input type="email" 
                                       name="email" 
                                       id="email"
                                       class="w-full px-4 py-3 border border-gray-200 rounded-lg text-sm 
                                              focus:outline-none focus:ring-2 focus:ring-gray-900 focus:border-transparent
                                              transition-all duration-300 hover:border-gray-300"
                                       value="{{ old('email', auth()->user()->email ?? '') }}" 
                                       required>
                            </div>

                            <div class="space-y-2">
                                <label for="phone" class="block text-sm font-medium text-gray-700">
                                    Phone Number
                                </label>
                                <input type="tel" 
                                       name="phone" 
                                       id="phone"
                                       class="w-full px-4 py-3 border border-gray-200 rounded-lg text-sm 
                                              focus:outline-none focus:ring-2 focus:ring-gray-900 focus:border-transparent
                                              transition-all duration-300 hover:border-gray-300"
                                       value="{{ old('phone', auth()->user()->phone ?? '') }}" 
                                       required>
                            </div>
                        </div>

                        <!-- Address Selection -->
                        @if(isset($addresses) && count($addresses) > 0)
                            <div class="space-y-6 border-t border-gray-100 pt-8">
                                <div>
                                    <h3 class="text-lg font-medium text-gray-900 mb-2">
                                        Shipping Address
                                    </h3>
                                    <p class="text-sm text-gray-500 font-light">
                                        Choose an existing address or add a new one
                                    </p>
                                </div>

                                <div class="grid sm:grid-cols-2 gap-4">
                                    @foreach($addresses as $address)
                                        <div class="relative">
                                            <input type="radio" 
                                                   name="address_id" 
                                                   id="address_{{ $address->id }}" 
                                                   value="{{ $address->id }}" 
                                                   class="peer sr-only" 
                                                   {{ old('address_id') == $address->id ? 'checked' : '' }}>
                                            <label for="address_{{ $address->id }}" 
                                                   class="block p-6 border border-gray-200 rounded-lg cursor-pointer 
                                                          transition-all duration-300 hover:border-gray-300 hover:shadow-sm
                                                          peer-checked:border-gray-900 peer-checked:bg-gray-50">
                                                <div class="space-y-2">
                                                    <div class="flex items-center justify-between">
                                                        <span class="text-sm font-medium text-gray-900">
                                                            {{ $address->is_default ? 'Default Address' : 'Address ' . $loop->iteration }}
                                                        </span>
                                                        <div class="w-4 h-4 border border-gray-300 rounded-full 
                                                                    peer-checked:border-gray-900 peer-checked:bg-gray-900
                                                                    transition-all duration-300"></div>
                                                    </div>
                                                    <div class="text-sm text-gray-600 space-y-1">
                                                        <p>{{ $address->street_address }}</p>
                                                        <p>{{ $address->city }}, {{ $address->state }} {{ $address->postal_code }}</p>
                                                        <p>{{ $address->country }}</p>
                                                    </div>
                                                </div>
                                            </label>
                                        </div>
                                    @endforeach
                                    
                                    <!-- New Address Option -->
                                    <div class="relative">
                                        <input type="radio" 
                                               name="address_id" 
                                               id="address_new" 
                                               value="" 
                                               class="peer sr-only" 
                                               {{ old('address_id') === null ? 'checked' : '' }}>
                                        <label for="address_new" 
                                               class="block p-6 border-2 border-dashed border-gray-200 rounded-lg cursor-pointer 
                                                      transition-all duration-300 hover:border-gray-300 hover:bg-gray-50
                                                      peer-checked:border-gray-900 peer-checked:bg-gray-50 text-center">
                                            <div class="space-y-2">
                                                <div class="w-8 h-8 mx-auto bg-gray-100 rounded-full flex items-center justify-center">
                                                    <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
                                                    </svg>
                                                </div>
                                                <div>
                                                    <p class="text-sm font-medium text-gray-900">Add New Address</p>
                                                    <p class="text-xs text-gray-500">Enter a new shipping address</p>
                                                </div>
                                            </div>
                                        </label>
                                    </div>
                                </div>
                            </div>
                        @endif

                        <!-- Submit Button -->
                        <div class="border-t border-gray-100 pt-8">
                            <button type="submit" 
                                    class="w-full bg-gray-900 text-white py-4 px-6 rounded-lg text-sm font-medium
                                           hover:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-gray-900 focus:ring-offset-2
                                           transition-all duration-300 hover:shadow-lg transform hover:-translate-y-0.5">
                                Continue to Delivery
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
button:focus {
    box-shadow: 0 0 0 3px rgba(17, 24, 39, 0.1);
}

/* Subtle hover effects */
.hover\:shadow-lg:hover {
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
}
</style>
@endsection