@extends('layouts.app')
@section('show_back_button')
@endsection
@section('title', 'Add New Address')

@section('content')
<div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 pt-12 pb-8">
        <div class="text-center space-y-4">
            <h1 class="text-4xl md:text-5xl font-light text-gray-900 tracking-tight">
                Add New Address
            </h1>
            <p class="text-lg text-gray-500 font-light max-w-md mx-auto">
                Enter your delivery details below
            </p>
        </div>
    </div>

    <!-- Form Container -->
    <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
        <div class="bg-white border border-gray-100 shadow-sm">
            <div class="p-8 md:p-12 space-y-8">

                <!-- Form -->
                <form action="{{ route('addresses.store') }}" method="POST" class="space-y-8">
                    @csrf
                    
                    <!-- Street Address -->
                    <div class="space-y-2">
                        <label for="street_address" class="block text-sm font-medium text-gray-900 tracking-wide">
                            Street Address *
                        </label>
                        <input type="text" 
                               id="street_address" 
                               name="street_address" 
                               value="{{ old('street_address') }}"
                               class="w-full px-4 py-4 border border-gray-200 text-gray-900 font-light placeholder-gray-400 focus:border-black focus:ring-0 transition-colors duration-300 @error('street_address') border-red-500 @enderror"
                               placeholder="Enter your street address"
                               required>
                        @error('street_address')
                            <p class="text-red-500 text-sm font-light">{{ $message }}</p>
                        @enderror
                    </div>

                    <!-- City & State Row -->
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <!-- City -->
                        <div class="space-y-2">
                            <label for="city" class="block text-sm font-medium text-gray-900 tracking-wide">
                                City *
                            </label>
                            <input type="text" 
                                   id="city" 
                                   name="city" 
                                   value="{{ old('city') }}"
                                   class="w-full px-4 py-4 border border-gray-200 text-gray-900 font-light placeholder-gray-400 focus:border-black focus:ring-0 transition-colors duration-300 @error('city') border-red-500 @enderror"
                                   placeholder="Enter city"
                                   required>
                            @error('city')
                                <p class="text-red-500 text-sm font-light">{{ $message }}</p>
                            @enderror
                        </div>

                        <!-- State -->
                        <div class="space-y-2">
                            <label for="state" class="block text-sm font-medium text-gray-900 tracking-wide">
                                State *
                            </label>
                            <input type="text" 
                                   id="state" 
                                   name="state" 
                                   value="{{ old('state') }}"
                                   class="w-full px-4 py-4 border border-gray-200 text-gray-900 font-light placeholder-gray-400 focus:border-black focus:ring-0 transition-colors duration-300 @error('state') border-red-500 @enderror"
                                   placeholder="Enter state"
                                   required>
                            @error('state')
                                <p class="text-red-500 text-sm font-light">{{ $message }}</p>
                            @enderror
                        </div>
                    </div>

                    <!-- Postal Code & Country Row -->
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <!-- Postal Code -->
                        <div class="space-y-2">
                            <label for="postal_code" class="block text-sm font-medium text-gray-900 tracking-wide">
                                Postal Code *
                            </label>
                            <input type="text" 
                                   id="postal_code" 
                                   name="postal_code" 
                                   value="{{ old('postal_code') }}"
                                   class="w-full px-4 py-4 border border-gray-200 text-gray-900 font-light placeholder-gray-400 focus:border-black focus:ring-0 transition-colors duration-300 @error('postal_code') border-red-500 @enderror"
                                   placeholder="Enter postal code"
                                   required>
                            @error('postal_code')
                                <p class="text-red-500 text-sm font-light">{{ $message }}</p>
                            @enderror
                        </div>

                        <!-- Country -->
                        <div class="space-y-2">
                            <label for="country" class="block text-sm font-medium text-gray-900 tracking-wide">
                                Country
                            </label>
                            <input type="text" 
                                   id="country" 
                                   name="country" 
                                   value="{{ old('country', 'Indonesia') }}"
                                   class="w-full px-4 py-4 border border-gray-200 text-gray-900 font-light placeholder-gray-400 focus:border-black focus:ring-0 transition-colors duration-300 @error('country') border-red-500 @enderror"
                                   placeholder="Enter country">
                            @error('country')
                                <p class="text-red-500 text-sm font-light">{{ $message }}</p>
                            @enderror
                        </div>
                    </div>

                    <!-- Default Address Checkbox -->
                    <div class="space-y-2">
                        <label class="flex items-center cursor-pointer group">
                            <input type="checkbox" 
                                   name="is_default" 
                                   value="1"
                                   {{ old('is_default') ? 'checked' : '' }}
                                   class="w-5 h-5 text-black border-gray-300 focus:ring-0 focus:ring-offset-0 transition-colors duration-300">
                            <span class="ml-3 text-gray-900 font-light group-hover:text-black transition-colors duration-300">
                                Set as default address
                            </span>
                        </label>
                        <p class="text-sm text-gray-500 font-light ml-8">
                            This will be used as your primary delivery location
                        </p>
                    </div>

                    <!-- Form Actions -->
                    <div class="flex flex-col sm:flex-row items-center justify-end space-y-4 sm:space-y-0 sm:space-x-4 pt-8 border-t border-gray-100">
                        <a href="{{ route('profile.address') }}" 
                           class="w-full sm:w-auto px-8 py-3 border border-gray-300 text-gray-700 font-medium text-sm tracking-wide text-center transition-all duration-300 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2">
                            Cancel
                        </a>
                        <button type="submit" 
                                class="w-full sm:w-auto px-8 py-3 bg-black text-white font-medium text-sm tracking-wide uppercase transition-all duration-300 hover:bg-gray-800 hover:scale-105 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2">
                            Save Address
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
    // Auto-focus first input
    document.addEventListener('DOMContentLoaded', function() {
        document.getElementById('street_address').focus();
    });

    // Form validation enhancement
    const form = document.querySelector('form');
    const inputs = form.querySelectorAll('input[required]');
    
    inputs.forEach(input => {
        input.addEventListener('blur', function() {
            if (this.value.trim() === '') {
                this.classList.add('border-red-300');
            } else {
                this.classList.remove('border-red-300');
                this.classList.add('border-green-300');
            }
        });
    });

    // Smooth form submission
    form.addEventListener('submit', function(e) {
        const submitBtn = form.querySelector('button[type="submit"]');
        submitBtn.disabled = true;
        submitBtn.innerHTML = 'Saving...';
        submitBtn.classList.add('opacity-75');
    });
</script>
@endpush