@extends('layouts.app')
@section('show_back_button')
@endsection
@section('title', 'Edit Address')

@section('content')
<div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 pt-12 pb-8">
        <div class="text-center space-y-4">
            <h1 class="text-4xl md:text-5xl font-light text-gray-900 tracking-tight">
                Edit Address
            </h1>
            <p class="text-lg text-gray-500 font-light max-w-md mx-auto">
                Update your delivery details
            </p>
        </div>
    </div>

    <!-- Form Container -->
    <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
        <div class="bg-white border border-gray-100 shadow-sm">
            <div class="p-8 md:p-12 space-y-8">
                <!-- Form -->
                <form action="{{ route('addresses.update', $address->id) }}" method="POST" class="space-y-8">
                    @csrf
                    @method('PUT')
                    
                    <!-- Street Address -->
                    <div class="space-y-2">
                        <label for="street_address" class="block text-sm font-medium text-gray-900 tracking-wide">
                            Street Address *
                        </label>
                        <input type="text" 
                               id="street_address" 
                               name="street_address" 
                               value="{{ old('street_address', $address->street_address) }}"
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
                                   value="{{ old('city', $address->city) }}"
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
                                   value="{{ old('state', $address->state) }}"
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
                                   value="{{ old('postal_code', $address->postal_code) }}"
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
                                   value="{{ old('country', $address->country) }}"
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
                                   {{ old('is_default', $address->is_default) ? 'checked' : '' }}
                                   class="w-5 h-5 text-black border-gray-300 focus:ring-0 focus:ring-offset-0 transition-colors duration-300">
                            <span class="ml-3 text-gray-900 font-light group-hover:text-black transition-colors duration-300">
                                Set as default address
                            </span>
                        </label>
                        <p class="text-sm text-gray-500 font-light ml-8">
                            This will be used as your primary delivery location
                        </p>
                    </div>

                    <!-- Address Preview Card -->
                    <div class="bg-gray-50 border border-gray-200 p-6 space-y-3">
                        <h4 class="text-sm font-medium text-gray-900 tracking-wide uppercase">
                            Current Address Preview
                        </h4>
                        <div class="text-gray-600 font-light space-y-1" id="addressPreview">
                            <p>{{ $address->street_address }}</p>
                            <p>{{ $address->city }}, {{ $address->state }}</p>
                            <p>{{ $address->postal_code }}</p>
                            @if($address->country)
                                <p>{{ $address->country }}</p>
                            @endif
                        </div>
                    </div>

                    <!-- Form Actions -->
                    <div class="flex flex-col sm:flex-row items-center justify-between space-y-4 sm:space-y-0 sm:space-x-4 pt-8 border-t border-gray-100">
                        <!-- Delete Button (Left Side) -->
                        <button type="button" 
                                onclick="confirmDelete({{ $address->id }})"
                                class="w-full sm:w-auto px-6 py-3 border border-red-300 text-red-600 font-medium text-sm tracking-wide transition-all duration-300 hover:bg-red-50 hover:border-red-400 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2">
                            Delete Address
                        </button>

                        <!-- Save/Cancel Buttons (Right Side) -->
                        <div class="flex flex-col sm:flex-row items-center space-y-4 sm:space-y-0 sm:space-x-4">
                            <a href="{{ route('profile.address') }}" 
                               class="w-full sm:w-auto px-8 py-3 border border-gray-300 text-gray-700 font-medium text-sm tracking-wide text-center transition-all duration-300 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2">
                                Cancel
                            </a>
                            <button type="submit" 
                                    class="w-full sm:w-auto px-8 py-3 bg-black text-white font-medium text-sm tracking-wide uppercase transition-all duration-300 hover:bg-gray-800 hover:scale-105 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2">
                                Update Address
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div id="deleteModal" class="fixed inset-0 bg-black bg-opacity-50 hidden items-center justify-center z-50 transition-opacity duration-300">
    <div class="bg-white max-w-md w-full mx-4 transform transition-all duration-300 scale-95" id="modalContent">
        <div class="p-8 text-center space-y-6">
            <!-- Icon -->
            <div class="mx-auto w-16 h-16 bg-red-100 rounded-full flex items-center justify-center">
                <svg class="w-8 h-8 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z"/>
                </svg>
            </div>
            
            <!-- Content -->
            <div class="space-y-3">
                <h3 class="text-xl font-light text-gray-900">
                    Delete Address
                </h3>
                <p class="text-gray-500 font-light leading-relaxed">
                    Are you sure you want to delete this address? This action cannot be undone.
                </p>
            </div>
            
            <!-- Actions -->
            <div class="flex items-center justify-center space-x-4 pt-4">
                <button type="button" 
                        onclick="closeModal()"
                        class="px-6 py-2 border border-gray-300 text-gray-700 font-light transition-colors duration-300 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2">
                    Cancel
                </button>
                <form id="deleteForm" method="POST" class="inline">
                    @csrf
                    @method('DELETE')
                    <button type="submit" 
                            class="px-6 py-2 bg-red-600 text-white font-light transition-colors duration-300 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2">
                        Delete Address
                    </button>
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

    // Real-time address preview update
    const streetInput = document.getElementById('street_address');
    const cityInput = document.getElementById('city');
    const stateInput = document.getElementById('state');
    const postalInput = document.getElementById('postal_code');
    const countryInput = document.getElementById('country');
    const preview = document.getElementById('addressPreview');

    function updatePreview() {
        const street = streetInput.value || '{{ $address->street_address }}';
        const city = cityInput.value || '{{ $address->city }}';
        const state = stateInput.value || '{{ $address->state }}';
        const postal = postalInput.value || '{{ $address->postal_code }}';
        const country = countryInput.value || '{{ $address->country }}';

        preview.innerHTML = `
            <p>${street}</p>
            <p>${city}, ${state}</p>
            <p>${postal}</p>
            ${country ? `<p>${country}</p>` : ''}
        `;
    }

    [streetInput, cityInput, stateInput, postalInput, countryInput].forEach(input => {
        input.addEventListener('input', updatePreview);
    });

    // Delete confirmation
    function confirmDelete(addressId) {
        const modal = document.getElementById('deleteModal');
        const modalContent = document.getElementById('modalContent');
        document.getElementById('deleteForm').action = `/addresses/${addressId}`;
        
        modal.classList.remove('hidden');
        modal.classList.add('flex');
        
        setTimeout(() => {
            modal.classList.remove('opacity-0');
            modalContent.classList.remove('scale-95');
            modalContent.classList.add('scale-100');
        }, 10);
    }

    function closeModal() {
        const modal = document.getElementById('deleteModal');
        const modalContent = document.getElementById('modalContent');
        
        modal.classList.add('opacity-0');
        modalContent.classList.remove('scale-100');
        modalContent.classList.add('scale-95');
        
        setTimeout(() => {
            modal.classList.add('hidden');
            modal.classList.remove('flex');
        }, 300);
    }

    // Close modal when clicking outside
    document.getElementById('deleteModal').addEventListener('click', function(e) {
        if (e.target === this) {
            closeModal();
        }
    });

    // Smooth form submission
    form.addEventListener('submit', function(e) {
        const submitBtn = form.querySelector('button[type="submit"]');
        submitBtn.disabled = true;
        submitBtn.innerHTML = 'Updating...';
        submitBtn.classList.add('opacity-75');
    });
</script>
@endpush