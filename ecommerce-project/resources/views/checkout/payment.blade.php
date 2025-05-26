@extends('layouts.app')
@section('show_back_button')
@endsection

@section('content')
<div class="container mx-auto px-4 py-8">
    <h1 class="text-3xl font-bold mb-6">Payment</h1>

    <div class="grid md:grid-cols-3 gap-6">
        {{-- Checkout Steps Navigation --}}
        <div class="md:col-span-1 bg-white shadow-md rounded-lg p-4">
            <h3 class="text-xl font-bold mb-4">Checkout Progress</h3>
            <ul class="space-y-2">
                <li class="text-gray-600">1. Customer Information</li>
                <li class="text-gray-600">2. Delivery Method</li>
                <li class="text-blue-500 font-semibold">3. Payment</li>
                <li class="text-gray-600">4. Confirmation</li>
            </ul>
        </div>

        {{-- Payment Options --}}
        <div class="md:col-span-2 bg-white shadow-md rounded-lg p-6">
            <form id="payment-form" action="{{ route('checkout.store-payment') }}" method="POST">
                @csrf

                {{-- Hidden fields untuk data yang diperlukan --}}
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

                <div class="space-y-4">
                    <h2 class="text-2xl font-bold mb-4">Payment Method</h2>

                    {{-- Error Messages --}}
                    @if ($errors->any())
                        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
                            <ul>
                                @foreach ($errors->all() as $error)
                                    <li>{{ $error }}</li>
                                @endforeach
                            </ul>
                        </div>
                    @endif

                    {{-- Success Messages --}}
                    @if (session('success'))
                        <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
                            {{ session('success') }}
                        </div>
                    @endif

                    <div class="grid md:grid-cols-2 gap-4">
                        {{-- Midtrans Payment --}}
                        <div>
                            <input type="radio" name="payment_method" id="midtrans" 
                                   value="midtrans" class="peer" required 
                                   {{ old('payment_method', 'midtrans') === 'midtrans' ? 'checked' : '' }}>
                            <label for="midtrans" 
                                   class="block p-4 border rounded-md cursor-pointer 
                                          hover:bg-blue-50 peer-checked:border-blue-500 peer-checked:bg-blue-50">
                                <div class="flex items-center">
                                    <svg class="w-8 h-8 mr-3" fill="currentColor" viewBox="0 0 24 24">
                                        <path d="M20 4H4c-1.11 0-1.99.89-1.99 2L2 18c0 1.11.89 2 2 2h16c1.11 0 2-.89 2-2V6c0-1.11-.89-2-2-2zm0 14H4v-6h16v6zm0-10H4V6h16v2z"/>
                                    </svg>
                                    <div>
                                        <span class="font-semibold">Midtrans Payment</span>
                                        <p class="text-sm text-gray-600">Credit Card, Bank Transfer, E-Wallet, etc.</p>
                                    </div>
                                </div>
                            </label>
                        </div>

                        {{-- Bank Transfer Payment --}}
                        <div>
                            <input type="radio" name="payment_method" id="bank_transfer" 
                                   value="bank_transfer" class="peer"
                                   {{ old('payment_method') === 'bank_transfer' ? 'checked' : '' }}>
                            <label for="bank_transfer" 
                                   class="block p-4 border rounded-md cursor-pointer 
                                          hover:bg-blue-50 peer-checked:border-blue-500 peer-checked:bg-blue-50">
                                <div class="flex items-center">
                                    <svg class="w-8 h-8 mr-3" fill="currentColor" viewBox="0 0 24 24">
                                        <path d="M16 6l2.29 2.29-4.88 4.88-4-4L2 16.59 3.41 18l6-6 4 4 6.3-6.29L22 12V6z"/>
                                    </svg>
                                    <div>
                                        <span class="font-semibold">Manual Bank Transfer</span>
                                        <p class="text-sm text-gray-600">Direct bank transfer</p>
                                    </div>
                                </div>
                            </label>
                        </div>
                    </div>

                    {{-- Midtrans Payment Details --}}
                    <div id="midtrans-details" class="payment-details">
                        <div class="bg-blue-50 border border-blue-200 p-4 rounded-md">
                            <h3 class="font-semibold mb-2">Midtrans Payment Gateway</h3>
                            <p class="text-gray-700">
                                You will be redirected to Midtrans payment gateway where you can choose from various payment methods including:
                            </p>
                            <ul class="mt-2 text-sm text-gray-600 list-disc list-inside">
                                <li>Credit/Debit Cards (Visa, MasterCard, JCB)</li>
                                <li>Bank Transfer (BCA, BNI, BRI, Mandiri, Permata)</li>
                                <li>E-Wallets (GoPay, OVO, DANA, LinkAja)</li>
                                <li>Convenience Stores (Indomaret, Alfamart)</li>
                            </ul>
                        </div>
                    </div>

                    {{-- Bank Transfer Details --}}
                    <div id="bank-transfer-details" class="payment-details hidden">
                        <div class="bg-blue-50 border border-blue-200 p-4 rounded-md">
                            <h3 class="font-semibold mb-2">Bank Transfer Instructions</h3>
                            <p class="text-gray-700">
                                Please transfer the total amount to:
                            </p>
                            <div class="mt-2">
                                <p><strong>Bank Name:</strong> Bank Central Asia (BCA)</p>
                                <p><strong>Account Number:</strong> 1234567890</p>
                                <p><strong>Account Name:</strong> Your Company Name</p>
                            </div>
                            <div class="mt-3 p-3 bg-yellow-50 border border-yellow-200 rounded">
                                <p class="text-sm text-yellow-800">
                                    <strong>Note:</strong> Please send proof of payment via WhatsApp or email after completing the transfer.
                                </p>
                            </div>
                        </div>
                    </div>

                    {{-- Order Summary --}}
                    <div class="bg-gray-100 p-4 rounded-md mt-6">
                        <h3 class="font-semibold mb-2">Order Summary</h3>
                        <div class="flex justify-between mb-2">
                            <span>Subtotal</span>
                            <span>{{ number_format($subtotal ?? 0, 2) }} IDR</span>
                        </div>
                        <div class="flex justify-between mb-2">
                            <span>Delivery ({{ ucfirst($delivery['delivery_method'] ?? 'standard') }})</span>
                            <span>{{ number_format($deliveryCost ?? 0, 2) }} IDR</span>
                        </div>
                        <div class="flex justify-between font-semibold text-lg border-t pt-2 mt-2">
                            <span>Total</span>
                            <span>{{ number_format($total ?? 0, 2) }} IDR</span>
                        </div>
                    </div>

                    <div class="mt-4">
                        <button type="submit" id="submit-button"
                                class="w-full bg-blue-500 text-white py-3 rounded-md hover:bg-blue-600 transition duration-200 disabled:opacity-50 disabled:cursor-not-allowed">
                            <span id="submit-text">Process Payment</span>
                            <div id="loading-spinner" class="hidden flex items-center justify-center">
                                <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                                </svg>
                                Processing...
                            </div>
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection

@push('scripts')
{{-- Midtrans Snap.js Script --}}
<script src="https://app.sandbox.midtrans.com/snap/snap.js" data-client-key="{{ config('midtrans.client_key') }}"></script>

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
        
        // Fungsi untuk menampilkan detail pembayaran sesuai pilihan
        function updatePaymentMethod() {
            console.log('Updating payment method...');
            
            // Hide all payment details
            midtransDetails.classList.add('hidden');
            bankTransferDetails.classList.add('hidden');
            
            // Show appropriate details and update button text
            if (midtransRadio.checked) {
                midtransDetails.classList.remove('hidden');
                submitText.textContent = 'Process Payment';
                console.log('Midtrans selected');
            } else if (bankTransferRadio.checked) {
                bankTransferDetails.classList.remove('hidden');
                submitText.textContent = 'Complete Order';
                console.log('Bank transfer selected');
            }
        }

        // Event listeners untuk radio buttons
        if (midtransRadio) {
            midtransRadio.addEventListener('change', function() {
                console.log('Midtrans radio changed:', this.checked);
                updatePaymentMethod();
            });
        }

        if (bankTransferRadio) {
            bankTransferRadio.addEventListener('change', function() {
                console.log('Bank transfer radio changed:', this.checked);
                updatePaymentMethod();
            });
        }

        // Initialize form dengan pilihan default
        updatePaymentMethod();

        // Handle form submission
        if (form) {
            form.addEventListener('submit', function(e) {
                e.preventDefault(); // Prevent default form submission
                console.log('Form submitted');
                
                // Validasi payment method
                const selectedPaymentMethod = document.querySelector('input[name="payment_method"]:checked');
                if (!selectedPaymentMethod) {
                    alert('Please select a payment method');
                    return false;
                }

                console.log('Selected payment method:', selectedPaymentMethod.value);

                // Show loading state
                if (submitButton) {
                    submitButton.disabled = true;
                    submitText.classList.add('hidden');
                    loadingSpinner.classList.remove('hidden');
                }

                // Handle different payment methods
                if (selectedPaymentMethod.value === 'midtrans') {
                    processMidtransPayment();
                } else if (selectedPaymentMethod.value === 'bank_transfer') {
                    processBankTransferPayment();
                }
            });
        }

        // Function to handle Midtrans payment
        function processMidtransPayment() {
            console.log('Processing Midtrans payment...');
            
            // Prepare form data
            const formData = new FormData(form);
            
            // Send AJAX request to get snap token
            fetch(form.action, {
                method: 'POST',
                body: formData,
                headers: {
                    'X-Requested-With': 'XMLHttpRequest',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                }
            })
            .then(response => {
                console.log('Response status:', response.status);
                return response.json();
            })
            .then(data => {
                console.log('Response data:', data);
                
                if (data.success && data.snap_token) {
                    // Open Midtrans Snap
                    snap.pay(data.snap_token, {
                        onSuccess: function(result) {
                            console.log('Payment success:', result);
                            // Redirect to success page or show success message
                            if (data.redirect_url) {
                                window.location.href = data.redirect_url;
                            } else {
                                alert('Payment successful!');
                                location.reload();
                            }
                        },
                        onPending: function(result) {
                            console.log('Payment pending:', result);
                            alert('Payment pending. Please complete your payment.');
                            if (data.redirect_url) {
                                window.location.href = data.redirect_url;
                            }
                        },
                        onError: function(result) {
                            console.log('Payment error:', result);
                            alert('Payment failed. Please try again.');
                            resetFormState();
                        },
                        onClose: function() {
                            console.log('Payment popup closed');
                            resetFormState();
                        }
                    });
                } else {
                    console.error('Error:', data.message || 'Failed to get payment token');
                    alert(data.message || 'Failed to process payment. Please try again.');
                    resetFormState();
                }
            })
            .catch(error => {
                console.error('Fetch error:', error);
                alert('Network error. Please check your connection and try again.');
                resetFormState();
            });
        }

        // Function to handle bank transfer payment
        function processBankTransferPayment() {
            console.log('Processing bank transfer payment...');
            
            // For bank transfer, submit form normally
            const formData = new FormData(form);
            
            fetch(form.action, {
                method: 'POST',
                body: formData,
                headers: {
                    'X-Requested-With': 'XMLHttpRequest',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                }
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    if (data.redirect_url) {
                        window.location.href = data.redirect_url;
                    } else {
                        alert('Order placed successfully! Please complete the bank transfer.');
                    }
                } else {
                    alert(data.message || 'Failed to process order. Please try again.');
                    resetFormState();
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Network error. Please try again.');
                resetFormState();
            });
        }

        // Function to reset form state
        function resetFormState() {
            if (submitButton) {
                submitButton.disabled = false;
                submitText.classList.remove('hidden');
                loadingSpinner.classList.add('hidden');
            }
        }

        // Debug: Log form action
        if (form) {
            console.log('Form action:', form.action);
            console.log('Form method:', form.method);
        }

        // Add CSRF token meta tag if not exists
        if (!document.querySelector('meta[name="csrf-token"]')) {
            const meta = document.createElement('meta');
            meta.name = 'csrf-token';
            meta.content = document.querySelector('input[name="_token"]').value;
            document.getElementsByTagName('head')[0].appendChild(meta);
        }
    });
</script>
@endpush