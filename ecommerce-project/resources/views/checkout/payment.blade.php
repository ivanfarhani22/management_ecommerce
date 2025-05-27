@extends('layouts.app')
@section('show_back_button')

@section('content')
<div class="min-h-screen bg-gray-50">
    <div class="max-w-6xl mx-auto px-4 py-12">
        <!-- Header -->
        <div class="text-center mb-12">
            <h1 class="text-4xl font-light text-gray-900 mb-4">Complete Your Order</h1>
            <p class="text-gray-600 font-light">Choose your preferred payment method</p>
        </div>

        <div class="grid lg:grid-cols-12 gap-8">
            <!-- Progress Steps - Left Sidebar -->
            <div class="lg:col-span-3">
                <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 sticky top-6">
                    <h3 class="text-lg font-medium text-gray-900 mb-6">Order Progress</h3>
                    <div class="space-y-4">
                        <div class="flex items-center space-x-3">
                            <div class="w-8 h-8 rounded-full bg-green-100 flex items-center justify-center">
                                <svg class="w-4 h-4 text-green-600" fill="currentColor" viewBox="0 0 20 20">
                                    <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                                </svg>
                            </div>
                            <span class="text-sm text-green-600 font-medium">Customer Information</span>
                        </div>
                        <div class="flex items-center space-x-3">
                            <div class="w-8 h-8 rounded-full bg-green-100 flex items-center justify-center">
                                <svg class="w-4 h-4 text-green-600" fill="currentColor" viewBox="0 0 20 20">
                                    <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                                </svg>
                            </div>
                            <span class="text-sm text-green-600 font-medium">Delivery Method</span>
                        </div>
                        <div class="flex items-center space-x-3">
                            <div class="w-8 h-8 rounded-full bg-black flex items-center justify-center">
                                <span class="text-white text-sm font-medium">3</span>
                            </div>
                            <span class="text-sm text-gray-900 font-medium">Payment</span>
                        </div>
                        <div class="flex items-center space-x-3">
                            <div class="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center">
                                <span class="text-gray-400 text-sm">4</span>
                            </div>
                            <span class="text-sm text-gray-400">Confirmation</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Main Content -->
            <div class="lg:col-span-9">
                <!-- Error/Success Messages -->
                @if ($errors->any())
                    <div class="bg-red-50 border border-red-200 rounded-2xl p-4 mb-6">
                        <div class="flex items-center space-x-2">
                            <svg class="w-5 h-5 text-red-500" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
                            </svg>
                            <div>
                                @foreach ($errors->all() as $error)
                                    <p class="text-sm text-red-700">{{ $error }}</p>
                                @endforeach
                            </div>
                        </div>
                    </div>
                @endif

                @if (session('success'))
                    <div class="bg-green-50 border border-green-200 rounded-2xl p-4 mb-6">
                        <div class="flex items-center space-x-2">
                            <svg class="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                            </svg>
                            <p class="text-sm text-green-700">{{ session('success') }}</p>
                        </div>
                    </div>
                @endif

                <form id="payment-form" action="{{ route('checkout.store-payment') }}" method="POST" class="space-y-8">
                    @csrf

                    <!-- Hidden Fields -->
                    @if(isset($subtotal))
                        <input type="hidden" name="subtotal" value="{{ $subtotal }}">
                    @endif
                    @if(isset($deliveryCost))
                        <input type="hidden" name="delivery_cost" value="{{ $deliveryCost }}">
                    @endif
                    @if(isset($total))
                        <input type="hidden" name="total" value="{{ $total }}">
                    @endif
                    @if(isset($delivery))
                        <input type="hidden" name="delivery_method" value="{{ $delivery['delivery_method'] ?? '' }}">
                    @endif

                    <!-- Payment Methods -->
                    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-8">
                        <h2 class="text-2xl font-light text-gray-900 mb-8">Select Payment Method</h2>
                        
                        <div class="grid md:grid-cols-2 gap-4">
                            <!-- Midtrans Payment -->
                            <div class="relative">
                                <input type="radio" name="payment_method" id="midtrans" 
                                       value="midtrans" class="peer sr-only" required 
                                       {{ old('payment_method', 'midtrans') === 'midtrans' ? 'checked' : '' }}>
                                <label for="midtrans" 
                                       class="block p-6 border-2 border-gray-200 rounded-2xl cursor-pointer 
                                              transition-all duration-300 hover:border-gray-300 hover:shadow-md
                                              peer-checked:border-black peer-checked:bg-gray-50">
                                    <div class="flex flex-col items-center text-center space-y-3">
                                        <div class="w-12 h-12 bg-gray-100 rounded-2xl flex items-center justify-center">
                                            <svg class="w-6 h-6 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"/>
                                            </svg>
                                        </div>
                                        <div>
                                            <h3 class="font-medium text-gray-900">Midtrans Gateway</h3>
                                            <p class="text-sm text-gray-500 mt-1">Card, Bank Transfer, E-Wallet</p>
                                        </div>
                                    </div>
                                    <div class="absolute top-4 right-4 opacity-0 peer-checked:opacity-100 transition-opacity">
                                        <div class="w-5 h-5 bg-black rounded-full flex items-center justify-center">
                                            <svg class="w-3 h-3 text-white" fill="currentColor" viewBox="0 0 20 20">
                                                <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                                            </svg>
                                        </div>
                                    </div>
                                </label>
                            </div>

                            <!-- Bank Transfer -->
                            <div class="relative">
                                <input type="radio" name="payment_method" id="bank_transfer" 
                                       value="bank_transfer" class="peer sr-only"
                                       {{ old('payment_method') === 'bank_transfer' ? 'checked' : '' }}>
                                <label for="bank_transfer" 
                                       class="block p-6 border-2 border-gray-200 rounded-2xl cursor-pointer 
                                              transition-all duration-300 hover:border-gray-300 hover:shadow-md
                                              peer-checked:border-black peer-checked:bg-gray-50">
                                    <div class="flex flex-col items-center text-center space-y-3">
                                        <div class="w-12 h-12 bg-gray-100 rounded-2xl flex items-center justify-center">
                                            <svg class="w-6 h-6 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 14v3m4-3v3m4-3v3M3 21h18M3 10h18M3 7l9-4 9 4M4 10h16v11H4V10z"/>
                                            </svg>
                                        </div>
                                        <div>
                                            <h3 class="font-medium text-gray-900">Bank Transfer</h3>
                                            <p class="text-sm text-gray-500 mt-1">Manual bank transfer</p>
                                        </div>
                                    </div>
                                    <div class="absolute top-4 right-4 opacity-0 peer-checked:opacity-100 transition-opacity">
                                        <div class="w-5 h-5 bg-black rounded-full flex items-center justify-center">
                                            <svg class="w-3 h-3 text-white" fill="currentColor" viewBox="0 0 20 20">
                                                <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                                            </svg>
                                        </div>
                                    </div>
                                </label>
                            </div>
                        </div>
                    </div>

                    <!-- Midtrans Payment Options (Show when Midtrans is selected) -->
                    <div id="midtrans-details" class="bg-white rounded-2xl shadow-sm border border-gray-100 p-8">
                        <h3 class="text-lg font-medium text-gray-900 mb-6">Available Payment Options</h3>
                        <div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
                            <div class="flex items-center space-x-3 p-4 bg-gray-50 rounded-xl">
                                <div class="w-8 h-8 bg-white rounded-lg flex items-center justify-center">
                                    <svg class="w-4 h-4 text-gray-600" fill="currentColor" viewBox="0 0 20 20">
                                        <path d="M4 4a2 2 0 00-2 2v1h16V6a2 2 0 00-2-2H4z"/>
                                        <path fill-rule="evenodd" d="M18 9H2v5a2 2 0 002 2h12a2 2 0 002-2V9zM4 13a1 1 0 011-1h1a1 1 0 110 2H5a1 1 0 01-1-1zm5-1a1 1 0 100 2h1a1 1 0 100-2H9z" clip-rule="evenodd"/>
                                    </svg>
                                </div>
                                <span class="text-sm font-medium text-gray-700">Credit Card</span>
                            </div>
                            <div class="flex items-center space-x-3 p-4 bg-gray-50 rounded-xl">
                                <div class="w-8 h-8 bg-white rounded-lg flex items-center justify-center">
                                    <svg class="w-4 h-4 text-gray-600" fill="currentColor" viewBox="0 0 20 20">
                                        <path d="M8 14v3m4-3v3m4-3v3M3 21h18M3 10h18M3 7l9-4 9 4M4 10h16v11H4V10z"/>
                                    </svg>
                                </div>
                                <span class="text-sm font-medium text-gray-700">Bank Transfer</span>
                            </div>
                            <div class="flex items-center space-x-3 p-4 bg-gray-50 rounded-xl">
                                <div class="w-8 h-8 bg-white rounded-lg flex items-center justify-center">
                                    <svg class="w-4 h-4 text-gray-600" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M3 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" clip-rule="evenodd"/>
                                    </svg>
                                </div>
                                <span class="text-sm font-medium text-gray-700">E-Wallets</span>
                            </div>
                            <div class="flex items-center space-x-3 p-4 bg-gray-50 rounded-xl">
                                <div class="w-8 h-8 bg-white rounded-lg flex items-center justify-center">
                                    <svg class="w-4 h-4 text-gray-600" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M5.05 4.05a7 7 0 119.9 9.9L10 18.9l-4.95-4.95a7 7 0 010-9.9zM10 11a2 2 0 100-4 2 2 0 000 4z" clip-rule="evenodd"/>
                                    </svg>
                                </div>
                                <span class="text-sm font-medium text-gray-700">Retail Outlets</span>
                            </div>
                        </div>
                    </div>

                    <!-- Bank Transfer Details (Show when Bank Transfer is selected) -->
                    <div id="bank-transfer-details" class="bg-white rounded-2xl shadow-sm border border-gray-100 p-8 hidden">
                        <h3 class="text-lg font-medium text-gray-900 mb-4">Bank Transfer Instructions</h3>
                        <p class="text-gray-600 mb-6">Please transfer the exact amount to the following account:</p>
                        
                        <div class="bg-gray-50 rounded-2xl p-6 mb-6">
                            <div class="grid sm:grid-cols-3 gap-4">
                                <div>
                                    <p class="text-xs font-medium text-gray-500 uppercase tracking-wide mb-1">Bank Name</p>
                                    <p class="font-medium text-gray-900">Bank Central Asia</p>
                                </div>
                                <div>
                                    <p class="text-xs font-medium text-gray-500 uppercase tracking-wide mb-1">Account Number</p>
                                    <p class="font-medium text-gray-900 font-mono">1234567890</p>
                                </div>
                                <div>
                                    <p class="text-xs font-medium text-gray-500 uppercase tracking-wide mb-1">Account Name</p>
                                    <p class="font-medium text-gray-900">Your Company Name</p>
                                </div>
                            </div>
                        </div>
                        
                        <div class="bg-amber-50 border border-amber-200 rounded-2xl p-4">
                            <div class="flex items-start space-x-2">
                                <svg class="w-5 h-5 text-amber-500 mt-0.5 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                                    <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
                                </svg>
                                <p class="text-sm text-amber-800">
                                    Please send proof of payment via WhatsApp or email after completing the transfer.
                                </p>
                            </div>
                        </div>
                    </div>

                    <!-- Order Summary -->
                    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-8">
                        <h3 class="text-lg font-medium text-gray-900 mb-6">Order Summary</h3>
                        <div class="space-y-4">
                            <div class="flex justify-between items-center">
                                <span class="text-gray-600">Subtotal</span>
                                <span class="font-medium">IDR {{ number_format($subtotal ?? 0, 0, ',', '.') }}</span>
                            </div>
                            <div class="flex justify-between items-center">
                                <span class="text-gray-600">Delivery ({{ ucfirst($delivery['delivery_method'] ?? 'standard') }})</span>
                                <span class="font-medium">IDR {{ number_format($deliveryCost ?? 0, 0, ',', '.') }}</span>
                            </div>
                            <div class="border-t border-gray-200 pt-4">
                                <div class="flex justify-between items-center">
                                    <span class="text-lg font-medium text-gray-900">Total</span>
                                    <span class="text-2xl font-light text-gray-900">IDR {{ number_format($total ?? 0, 0, ',', '.') }}</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Submit Button -->
                    <div class="flex justify-center">
                        <button type="submit" id="submit-button"
                                class="bg-black text-white px-12 py-4 rounded-2xl font-medium hover:bg-gray-800 transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed min-w-[240px]">
                            <span id="submit-text">Process Payment</span>
                            <div id="loading-spinner" class="hidden flex items-center justify-center space-x-2">
                                <svg class="animate-spin w-4 h-4" fill="none" viewBox="0 0 24 24">
                                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                                </svg>
                                <span>Processing...</span>
                            </div>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection

@push('scripts')
{{-- Load Midtrans Snap.js --}}
@if(config('midtrans.is_production'))
    <script src="https://app.midtrans.com/snap/snap.js" data-client-key="{{ config('midtrans.client_key') }}"></script>
@else
    <script src="https://app.sandbox.midtrans.com/snap/snap.js" data-client-key="{{ config('midtrans.client_key') }}"></script>
@endif

<script>
document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('payment-form');
    const midtransRadio = document.getElementById('midtrans');
    const bankTransferRadio = document.getElementById('bank_transfer');
    const midtransDetails = document.getElementById('midtrans-details');
    const bankTransferDetails = document.getElementById('bank-transfer-details');
    const submitButton = document.getElementById('submit-button');
    const submitText = document.getElementById('submit-text');
    const loadingSpinner = document.getElementById('loading-spinner');
    
    let isProcessing = false;
    
    // Toggle payment method details
    function togglePaymentDetails() {
        if (midtransRadio.checked) {
            midtransDetails.classList.remove('hidden');
            bankTransferDetails.classList.add('hidden');
            submitText.textContent = 'Process Payment';
        } else if (bankTransferRadio.checked) {
            midtransDetails.classList.add('hidden');
            bankTransferDetails.classList.remove('hidden');
            submitText.textContent = 'Complete Order';
        }
    }

    // Event listeners
    midtransRadio.addEventListener('change', togglePaymentDetails);
    bankTransferRadio.addEventListener('change', togglePaymentDetails);

    // Initialize
    togglePaymentDetails();

    // Form submission
    form.addEventListener('submit', function(e) {
        e.preventDefault();
        
        if (isProcessing) return;
        
        const selectedPaymentMethod = document.querySelector('input[name="payment_method"]:checked');
        if (!selectedPaymentMethod) {
            alert('Please select a payment method');
            return;
        }

        isProcessing = true;
        setLoadingState(true);

        if (selectedPaymentMethod.value === 'midtrans') {
            processMidtransPayment();
        } else {
            processBankTransferPayment();
        }
    });

    function processMidtransPayment() {
        const formData = new FormData(form);
        
        fetch(form.action, {
            method: 'POST',
            body: formData,
            headers: {
                'X-Requested-With': 'XMLHttpRequest',
                'Accept': 'application/json'
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.success && data.snap_token) {
                // Directly open Midtrans payment popup
                window.snap.pay(data.snap_token, {
                    onSuccess: function(result) {
                        window.location.href = data.redirect_url || '/checkout/success';
                    },
                    onPending: function(result) {
                        window.location.href = data.redirect_url || '/checkout/pending';
                    },
                    onError: function(result) {
                        alert('Payment failed. Please try again.');
                        resetFormState();
                    },
                    onClose: function() {
                        resetFormState();
                    }
                });
            } else {
                alert(data.message || 'Failed to initialize payment');
                resetFormState();
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Failed to process payment. Please try again.');
            resetFormState();
        });
    }

    function processBankTransferPayment() {
        const formData = new FormData(form);
        
        fetch(form.action, {
            method: 'POST',
            body: formData,
            headers: {
                'X-Requested-With': 'XMLHttpRequest',
                'Accept': 'application/json'
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                window.location.href = data.redirect_url || '/checkout/success';
            } else {
                alert(data.message || 'Failed to create order');
                resetFormState();
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Failed to process order. Please try again.');
            resetFormState();
        });
    }

    function setLoadingState(loading) {
        if (loading) {
            submitText.classList.add('hidden');
            loadingSpinner.classList.remove('hidden');
            submitButton.disabled = true;
        } else {
            submitText.classList.remove('hidden');
            loadingSpinner.classList.add('hidden');
            submitButton.disabled = false;
        }
    }

    function resetFormState() {
        isProcessing = false;
        setLoadingState(false);
    }
});
</script>
@endpush