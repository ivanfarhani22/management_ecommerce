@extends('layouts.app')
@section('show_back_button')
@endsection

@section('content')
<div class="container mx-auto px-4 py-8">
    <h1 class="text-3xl font-bold mb-6">Delivery Method</h1>

    <div class="grid md:grid-cols-3 gap-6">
        {{-- Checkout Steps Navigation --}}
        <div class="md:col-span-1 bg-white shadow-md rounded-lg p-4">
            <h3 class="text-xl font-bold mb-4">Checkout Progress</h3>
            <ul class="space-y-2">
                <li class="text-gray-600">1. Customer Information</li>
                <li class="text-blue-500 font-semibold">2. Delivery Method</li>
                <li class="text-gray-600">3. Payment</li>
                <li class="text-gray-600">4. Confirmation</li>
            </ul>
        </div>

        {{-- Delivery Options --}}
        <div class="md:col-span-2 bg-white shadow-md rounded-lg p-6">
            <form action="{{ route('checkout.delivery') }}" method="POST">
                @csrf

                <div class="space-y-4">
                    <h2 class="text-2xl font-bold mb-4">Select Delivery Method</h2>

                    <div class="grid md:grid-cols-2 gap-4">
                        <div>
                            <input type="radio" name="delivery_method" id="standard_delivery" 
                                   value="standard" class="peer" required checked>
                            <label for="standard_delivery" 
                                   class="block p-4 border rounded-md cursor-pointer 
                                          hover:bg-blue-50 peer-checked:border-blue-500 peer-checked:bg-blue-50">
                                <div class="flex justify-between items-center">
                                    <div>
                                        <h3 class="font-semibold">Standard Delivery</h3>
                                        <p class="text-sm text-gray-600">3-5 Business Days</p>
                                    </div>
                                    <span class="text-gray-600">5.00 IDR</span>
                                </div>
                            </label>
                        </div>

                        <div>
                            <input type="radio" name="delivery_method" id="express_delivery" 
                                   value="express" class="peer">
                            <label for="express_delivery" 
                                   class="block p-4 border rounded-md cursor-pointer 
                                          hover:bg-blue-50 peer-checked:border-blue-500 peer-checked:bg-blue-50">
                                <div class="flex justify-between items-center">
                                    <div>
                                        <h3 class="font-semibold">Express Delivery</h3>
                                        <p class="text-sm text-gray-600">1-2 Business Days</p>
                                    </div>
                                    <span class="text-gray-600">15.00 IDR</span>
                                </div>
                            </label>
                        </div>
                    </div>

                    @php
                        $customerInfo = session('checkout.customer_info');
                        $address = isset($customerInfo['address_id']) ? App\Models\Address::find($customerInfo['address_id']) : null;
                    @endphp

                    @if(!$address)
                        <div>
                            <label for="address" class="block text-gray-700 text-sm font-bold mb-2">Street Address</label>
                            <textarea name="address" id="address" rows="2"
                                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                                    required>{{ old('address') }}</textarea>
                        </div>

                        <div class="grid md:grid-cols-2 gap-4">
                            <div>
                                <label for="city" class="block text-gray-700 text-sm font-bold mb-2">City</label>
                                <input type="text" name="city" id="city"
                                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                                    value="{{ old('city') }}" required>
                            </div>

                            <div>
                                <label for="state" class="block text-gray-700 text-sm font-bold mb-2">State/Province</label>
                                <input type="text" name="state" id="state"
                                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                                    value="{{ old('state') }}" required>
                            </div>
                        </div>

                        <div class="grid md:grid-cols-2 gap-4">
                            <div>
                                <label for="postal_code" class="block text-gray-700 text-sm font-bold mb-2">Postal Code</label>
                                <input type="text" name="postal_code" id="postal_code"
                                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                                    value="{{ old('postal_code') }}" required>
                            </div>

                            <div>
                                <label for="country" class="block text-gray-700 text-sm font-bold mb-2">Country</label>
                                <input type="text" name="country" id="country"
                                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                                    value="{{ old('country', 'Indonesia') }}" required>
                            </div>
                        </div>
                    @else
                        <div class="mt-4 p-4 border rounded-md bg-blue-50">
                            <h3 class="font-semibold mb-2">Selected Address</h3>
                            <p>
                                {{ $address->street_address }}<br>
                                {{ $address->city }}, {{ $address->state }} {{ $address->postal_code }}<br>
                                {{ $address->country }}
                            </p>
                            <input type="hidden" name="address" value="{{ $address->street_address }}">
                            <input type="hidden" name="city" value="{{ $address->city }}">
                            <input type="hidden" name="state" value="{{ $address->state }}">
                            <input type="hidden" name="postal_code" value="{{ $address->postal_code }}">
                            <input type="hidden" name="country" value="{{ $address->country }}">
                        </div>
                    @endif

                    <button type="submit" 
                            class="w-full bg-blue-500 text-white py-3 rounded-md hover:bg-blue-600 mt-4">
                        Continue to Payment
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection