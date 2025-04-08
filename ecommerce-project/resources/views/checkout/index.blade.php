@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-8">
    <h1 class="text-3xl font-bold mb-6">Checkout</h1>

    <div class="grid md:grid-cols-3 gap-6">
        {{-- Checkout Steps Navigation --}}
        <div class="md:col-span-1 bg-white shadow-md rounded-lg p-4">
            <h3 class="text-xl font-bold mb-4">Checkout Progress</h3>
            <ul class="space-y-2">
                <li class="{{ request()->routeIs('checkout.index') ? 'text-blue-500 font-semibold' : 'text-gray-600' }}">
                    1. Customer Information
                </li>
                <li class="{{ request()->routeIs('checkout.delivery') ? 'text-blue-500 font-semibold' : 'text-gray-600' }}">
                    2. Delivery Method
                </li>
                <li class="{{ request()->routeIs('checkout.payment') ? 'text-blue-500 font-semibold' : 'text-gray-600' }}">
                    3. Payment
                </li>
                <li class="{{ request()->routeIs('checkout.confirmation') ? 'text-blue-500 font-semibold' : 'text-gray-600' }}">
                    4. Confirmation
                </li>
            </ul>
        </div>

        {{-- Checkout Form --}}
        <div class="md:col-span-2 bg-white shadow-md rounded-lg p-6">
            <form action="{{ route('checkout.process') }}" method="POST">
                @csrf

                <div class="space-y-4">
                    <h2 class="text-2xl font-bold mb-4">Customer Information</h2>

                    <div class="grid md:grid-cols-2 gap-4">
                        <div>
                            <label for="first_name" class="block text-gray-700 text-sm font-bold mb-2">First Name</label>
                            <input type="text" name="first_name" id="first_name"
                                   class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                                   value="{{ old('first_name', auth()->user()->first_name) }}" required>
                        </div>

                        <div>
                            <label for="last_name" class="block text-gray-700 text-sm font-bold mb-2">Last Name</label>
                            <input type="text" name="last_name" id="last_name"
                                   class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                                   value="{{ old('last_name', auth()->user()->last_name) }}" required>
                        </div>
                    </div>

                    <div>
                        <label for="email" class="block text-gray-700 text-sm font-bold mb-2">Email</label>
                        <input type="email" name="email" id="email"
                               class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                               value="{{ old('email', auth()->user()->email) }}" required>
                    </div>

                    <div>
                        <label for="phone" class="block text-gray-700 text-sm font-bold mb-2">Phone Number</label>
                        <input type="tel" name="phone" id="phone"
                               class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                               value="{{ old('phone', auth()->user()->phone) }}" required>
                    </div>

                    <button type="submit" 
                            class="w-full bg-blue-500 text-white py-3 rounded-md hover:bg-blue-600 mt-4">
                        Continue to Delivery
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection