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
            <form action="{{ route('checkout.payment') }}" method="POST">
                @csrf

                <div class="space-y-4">
                    <h2 class="text-2xl font-bold mb-4">Payment Method</h2>

                    <div class="grid md:grid-cols-2 gap-4">
                        {{-- Credit Card Payment --}}
                        <div>
                            <input type="radio" name="payment_method" id="credit_card" 
                                   value="credit_card" class="peer" required>
                            <label for="credit_card" 
                                   class="block p-4 border rounded-md cursor-pointer 
                                          hover:bg-blue-50 peer-checked:border-blue-500 peer-checked:bg-blue-50">
                                <div class="flex items-center">
                                    <svg class="w-8 h-8 mr-3" fill="currentColor" viewBox="0 0 24 24">
                                        <path d="M20 4H4c-1.11 0-1.99.89-1.99 2L2 18c0 1.11.89 2 2 2h16c1.11 0 2-.89 2-2V6c0-1.11-.89-2-2-2zm0 14H4v-6h16v6zm0-10H4V6h16v2z"/>
                                    </svg>
                                    <span class="font-semibold">Credit Card</span>
                                </div>
                            </label>
                        </div>

                        {{-- Bank Transfer Payment --}}
                        <div>
                            <input type="radio" name="payment_method" id="bank_transfer" 
                                   value="bank_transfer" class="peer">
                            <label for="bank_transfer" 
                                   class="block p-4 border rounded-md cursor-pointer 
                                          hover:bg-blue-50 peer-checked:border-blue-500 peer-checked:bg-blue-50">
                                <div class="flex items-center">
                                    <svg class="w-8 h-8 mr-3" fill="currentColor" viewBox="0 0 24 24">
                                        <path d="M16 6l2.29 2.29-4.88 4.88-4-4L2 16.59 3.41 18l6-6 4 4 6.3-6.29L22 12V6z"/>
                                    </svg>
                                    <span class="font-semibold">Bank Transfer</span>
                                </div>
                            </label>
                        </div>

                        {{-- PayPal Payment --}}
                        <div>
                            <input type="radio" name="payment_method" id="paypal" 
                                   value="paypal" class="peer">
                            <label for="paypal" 
                                   class="block p-4 border rounded-md cursor-pointer 
                                          hover:bg-blue-50 peer-checked:border-blue-500 peer-checked:bg-blue-50">
                                <div class="flex items-center">
                                    <svg class="w-8 h-8 mr-3" fill="currentColor" viewBox="0 0 24 24">
                                        <path d="M9.5 15.5c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm5-2c0-1.1.9-2 2-2s2 .9 2 2-.9 2-2 2-2-.9-2-2z"/>
                                        <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8z"/>
                                    </svg>
                                    <span class="font-semibold">PayPal</span>
                                </div>
                            </label>
                        </div>
                    </div>

                    {{-- Credit Card Details --}}
                    <div id="credit-card-details" class="hidden">
                        <div class="grid md:grid-cols-2 gap-4">
                            <div>
                                <label for="card_name" class="block text-gray-700 text-sm font-bold mb-2">Name on Card</label>
                                <input type="text" name="card_name" id="card_name"
                                       class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                            </div>
                            <div>
                                <label for="card_number" class="block text-gray-700 text-sm font-bold mb-2">Card Number</label>
                                <input type="text" name="card_number" id="card_number"
                                       class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                                       pattern="\d{4}\s?\d{4}\s?\d{4}\s?\d{4}">
                            </div>
                        </div>
                        <div class="grid md:grid-cols-3 gap-4 mt-4">
                            <div>
                                <label for="expiry_date" class="block text-gray-700 text-sm font-bold mb-2">Expiry Date</label>
                                <input type="text" name="expiry_date" id="expiry_date"
                                       placeholder="MM/YY"
                                       class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                                       pattern="(0[1-9]|1[0-2])\/\d{2}">
                            </div>
                            <div>
                                <label for="cvv" class="block text-gray-700 text-sm font-bold mb-2">CVV</label>
                                <input type="text" name="cvv" id="cvv"
                                       class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                                       pattern="\d{3}">
                            </div>
                        </div>
                        <input type="hidden" name="payment_details" id="payment_details_cc">
                    </div>

                    {{-- Bank Transfer Details --}}
                    <div id="bank-transfer-details" class="hidden">
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
                        </div>
                        <input type="hidden" name="payment_details" value="bank_transfer_details" id="payment_details_bank">
                    </div>

                    {{-- PayPal Details --}}
                    <div id="paypal-details" class="hidden">
                        <div class="bg-blue-50 border border-blue-200 p-4 rounded-md">
                            <h3 class="font-semibold mb-2">PayPal Instructions</h3>
                            <p class="text-gray-700">
                                You will be redirected to PayPal to complete your payment after submitting this form.
                            </p>
                        </div>
                        <input type="hidden" name="payment_details" value="paypal_details" id="payment_details_paypal">
                    </div>

                    {{-- Order Summary --}}
                    <div class="bg-gray-100 p-4 rounded-md mt-6">
                        <h3 class="font-semibold mb-2">Order Summary</h3>
                        <div class="flex justify-between mb-2">
                            <span>Subtotal</span>
                            <span>{{ number_format($subtotal, 2) }} IDR</span>
                        </div>
                        <div class="flex justify-between mb-2">
                            <span>Delivery ({{ ucfirst($delivery['delivery_method']) }})</span>
                            <span>{{ number_format($deliveryCost, 2) }} IDR</span>
                        </div>
                        <div class="flex justify-between font-semibold text-lg border-t pt-2 mt-2">
                            <span>Total</span>
                            <span>{{ number_format($total, 2) }} IDR</span>
                        </div>
                    </div>

                    <div class="mt-4">
                        <button type="submit" 
                                class="w-full bg-blue-500 text-white py-3 rounded-md hover:bg-blue-600">
                            Complete Payment
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const creditCardRadio = document.getElementById('credit_card');
        const bankTransferRadio = document.getElementById('bank_transfer');
        const paypalRadio = document.getElementById('paypal');
        const creditCardDetails = document.getElementById('credit-card-details');
        const bankTransferDetails = document.getElementById('bank-transfer-details');
        const paypalDetails = document.getElementById('paypal-details');
        const paymentDetailsCc = document.getElementById('payment_details_cc');
        
        function updatePaymentDetailsField() {
            if (creditCardRadio.checked) {
                const cardName = document.getElementById('card_name').value;
                const cardNumber = document.getElementById('card_number').value;
                const expiry = document.getElementById('expiry_date').value;
                
                paymentDetailsCc.value = JSON.stringify({
                    card_name: cardName,
                    card_number: cardNumber ? cardNumber.replace(/\s/g, '').substr(-4) : '',
                    expiry: expiry
                });
            }
        }
        
        // Add event listeners to all credit card fields
        document.getElementById('card_name').addEventListener('input', updatePaymentDetailsField);
        document.getElementById('card_number').addEventListener('input', updatePaymentDetailsField);
        document.getElementById('expiry_date').addEventListener('input', updatePaymentDetailsField);
        document.getElementById('cvv').addEventListener('input', updatePaymentDetailsField);

        // Show the appropriate details section based on selection
        function updatePaymentMethod() {
            creditCardDetails.classList.add('hidden');
            bankTransferDetails.classList.add('hidden');
            paypalDetails.classList.add('hidden');
            
            if (creditCardRadio.checked) {
                creditCardDetails.classList.remove('hidden');
                updatePaymentDetailsField();
            } else if (bankTransferRadio.checked) {
                bankTransferDetails.classList.remove('hidden');
            } else if (paypalRadio.checked) {
                paypalDetails.classList.remove('hidden');
            }
        }

        creditCardRadio.addEventListener('change', updatePaymentMethod);
        bankTransferRadio.addEventListener('change', updatePaymentMethod);
        paypalRadio.addEventListener('change', updatePaymentMethod);

        // Initialize the form
        if (creditCardRadio.checked) {
            creditCardRadio.dispatchEvent(new Event('change'));
        } else if (bankTransferRadio.checked) {
            bankTransferRadio.dispatchEvent(new Event('change'));
        } else if (paypalRadio.checked) {
            paypalRadio.dispatchEvent(new Event('change'));
        } else {
            // Default to credit card if nothing selected
            creditCardRadio.checked = true;
            creditCardRadio.dispatchEvent(new Event('change'));
        }
    });
</script>
@endpush