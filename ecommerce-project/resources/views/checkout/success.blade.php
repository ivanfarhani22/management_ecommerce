@extends('layouts.app')
@section('show_back_button')
@endsection

@section('content')
<div class="container mx-auto px-4 py-8">
    <div class="max-w-2xl mx-auto bg-white shadow-md rounded-lg p-8 text-center">
        <div class="mb-6">
            <svg class="mx-auto h-16 w-16 text-green-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <h1 class="text-3xl font-bold mt-4">Order Confirmed!</h1>
            <p class="text-gray-600 mt-2">Thank you for your purchase.</p>
        </div>

        <div class="bg-gray-100 rounded-lg p-4 mb-6">
            <h2 class="text-xl font-semibold mb-2">Order Details</h2>
            <p class="text-gray-700">
                <strong>Order Number:</strong> {{ $order->order_number }}<br>
                <strong>Date:</strong> {{ $order->created_at instanceof \DateTime ? $order->created_at->format('d M Y H:i') : date('d M Y H:i', strtotime($order->created_at)) }}
            </p>
        </div>

        <div class="grid md:grid-cols-2 gap-4 mb-6">
            <div>
                <h3 class="font-semibold mb-2">Shipping Information</h3>
                <p class="text-gray-700">
                    {{ $order->shipping_name }}<br>
                    {{ $order->shipping_address }}<br>
                    {{ $order->shipping_city ?? '' }}{{ !empty($order->shipping_postal_code) ? ', ' . $order->shipping_postal_code : '' }}<br>
                    {{ $order->shipping_country ?? '' }}
                </p>
            </div>

            <div>
                <h3 class="font-semibold mb-2">Payment Method</h3>
                <p class="text-gray-700">
                    {{ ucfirst(str_replace('_', ' ', $order->payment_method ?? 'Not specified')) }}
                </p>
            </div>
        </div>

        <div class="bg-gray-100 rounded-lg p-4 mb-6">
            <h3 class="text-xl font-semibold mb-2">Order Summary</h3>
            <div class="space-y-2">
                @if(isset($order->items) && count($order->items) > 0)
                    @foreach($order->items as $item)
                        <div class="flex justify-between">
                            <span>{{ $item->product_name }} ({{ $item->quantity }}x)</span>
                            <span>{{ number_format($item->price * $item->quantity, 2) }} IDR</span>
                        </div>
                    @endforeach
                @else
                    <div class="text-gray-600">Order items not available</div>
                @endif
                <hr class="my-2">
                <div class="flex justify-between font-semibold">
                    <span>Total</span>
                    <span>{{ number_format($order->total_amount ?? 0, 2) }} IDR</span>
                </div>
            </div>
        </div>

        <div class="space-x-4">
            @if(isset($order->id))
                <a href="{{ route('orders.show', $order->id) }}" 
                   class="bg-blue-500 text-white px-6 py-3 rounded-md hover:bg-blue-600">
                    View Order Details
                </a>
            @endif
            <a href="{{ route('catalog.index') }}" 
               class="bg-gray-200 text-gray-800 px-6 py-3 rounded-md hover:bg-gray-300">
                Continue Shopping
            </a>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
    // Send order confirmation email or perform any additional tracking
    document.addEventListener('DOMContentLoaded', function() {
        // Example: Send order confirmation via AJAX
        @if(isset($order->id))
        fetch('{{ route('orders.send-confirmation', $order->id) }}', {
            method: 'POST',
            headers: {
                'X-CSRF-TOKEN': '{{ csrf_token() }}'
            }
        });
        @endif
    });
</script>
@endpush