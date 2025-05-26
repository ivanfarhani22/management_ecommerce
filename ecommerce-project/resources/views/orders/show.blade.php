@extends('layouts.app')
@section('show_back_button')
@endsection

@section('content')
<div class="min-h-screen bg-gray-50">
    <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8 sm:py-12">
        <!-- Header Section -->
        <div class="mb-12">
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-6">
                <div>
                    <h1 class="text-2xl sm:text-3xl font-light text-gray-900 tracking-tight">Detail Pesanan</h1>
                    <div class="mt-2 flex items-center space-x-4">
                        <p class="text-sm text-gray-500">Order #{{ $order->id }}</p>
                        <span class="text-gray-300">•</span>
                        <p class="text-sm text-gray-500">{{ $order->created_at->format('d M Y H:i') }}</p>
                    </div>
                </div>
                
                <!-- Status Badge -->
                @if($order->status == 'completed')
                    <span class="px-4 py-2 text-sm font-medium bg-green-50 text-green-700 border border-green-200">
                        Selesai
                    </span>
                @elseif($order->status == 'processing')
                    <span class="px-4 py-2 text-sm font-medium bg-yellow-50 text-yellow-700 border border-yellow-200">
                        Diproses
                    </span>
                @elseif($order->status == 'cancelled')
                    <span class="px-4 py-2 text-sm font-medium bg-red-50 text-red-700 border border-red-200">
                        Dibatalkan
                    </span>
                @elseif($order->status == 'pending')
                    <span class="px-4 py-2 text-sm font-medium bg-blue-50 text-blue-700 border border-blue-200">
                        Menunggu Pembayaran
                    </span>
                @else
                    <span class="px-4 py-2 text-sm font-medium bg-gray-50 text-gray-700 border border-gray-200">
                        {{ $order->status }}
                    </span>
                @endif
            </div>
        </div>

        <!-- Main Content -->
        <div class="bg-white shadow-sm overflow-hidden">
            <!-- Order Items Section -->
            <div class="p-6 sm:p-8">
                <h2 class="text-lg font-light text-gray-900 mb-6 flex items-center">
                    <svg class="w-5 h-5 text-gray-400 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
                    </svg>
                    Item Pesanan
                </h2>
                
                <!-- Items List -->
                <div class="space-y-4">
                    @foreach($order->items as $item)
                        <div class="flex items-center justify-between py-4 border-b border-gray-100 last:border-b-0 hover:bg-gray-50 transition-colors duration-200 px-4 -mx-4">
                            <div class="flex items-center space-x-4 flex-1">
                                <!-- Product Image -->
                                <div class="w-16 h-16 bg-gray-100 overflow-hidden">
                                    @if($item->product && $item->product->image)
                                        <img src="{{ asset('storage/' . $item->product->image) }}" 
                                             alt="{{ $item->product->name }}" 
                                             class="w-full h-full object-cover">
                                    @else
                                        <div class="w-full h-full flex items-center justify-center">
                                            <svg class="w-6 h-6 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                            </svg>
                                        </div>
                                    @endif
                                </div>
                                
                                <!-- Product Info -->
                                <div class="flex-1 min-w-0">
                                    <h3 class="text-sm font-medium text-gray-900">{{ $item->product->name }}</h3>
                                    @if(isset($item->product->sku))
                                        <p class="text-xs text-gray-500 mt-1">SKU: {{ $item->product->sku }}</p>
                                    @endif
                                    <p class="text-sm text-gray-600 mt-1">Rp {{ number_format($item->price, 0, ',', '.') }} × {{ $item->quantity }}</p>
                                </div>
                            </div>
                            
                            <!-- Subtotal -->
                            <div class="text-right">
                                <p class="text-sm font-medium text-gray-900">Rp {{ number_format($item->quantity * $item->price, 0, ',', '.') }}</p>
                            </div>
                        </div>
                    @endforeach
                </div>
            </div>

            <!-- Order Summary -->
            <div class="bg-gray-50 px-6 sm:px-8 py-6 border-t">
                <div class="max-w-sm ml-auto">
                    <h3 class="text-lg font-light text-gray-900 mb-4">Ringkasan Pesanan</h3>
                    
                    <div class="space-y-3">
                        <div class="flex justify-between text-sm">
                            <span class="text-gray-600">Subtotal</span>
                            <span class="font-medium text-gray-900">Rp {{ number_format($order->total_amount, 0, ',', '.') }}</span>
                        </div>
                        <div class="flex justify-between text-sm">
                            <span class="text-gray-600">Pajak</span>
                            <span class="font-medium text-gray-900">Rp 0</span>
                        </div>
                        <div class="flex justify-between text-sm">
                            <span class="text-gray-600">Ongkos Kirim</span>
                            <span class="font-medium text-gray-900">Rp 0</span>
                        </div>
                        <div class="border-t border-gray-200 pt-3">
                            <div class="flex justify-between">
                                <span class="text-base font-medium text-gray-900">Total</span>
                                <span class="text-lg font-semibold text-gray-900">Rp {{ number_format($order->total_amount, 0, ',', '.') }}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Action Buttons -->
            <div class="px-6 sm:px-8 py-6 border-t border-gray-200 bg-white">
                <div class="flex flex-col sm:flex-row justify-end space-y-3 sm:space-y-0 sm:space-x-3">
                    <a href="#" 
                       class="inline-flex items-center justify-center px-6 py-3 border border-gray-300 text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500">
                        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
                        </svg>
                        Cetak Invoice
                    </a>
                    <a href="{{ route('orders.index') }}" 
                       class="inline-flex items-center justify-center px-6 py-3 bg-gray-900 text-white text-sm font-medium hover:bg-gray-800 transition-all duration-300 ease-in-out transform hover:scale-105 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-900">
                        Kembali ke Daftar Pesanan
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
/* Smooth hover animations */
@media (prefers-reduced-motion: reduce) {
    .transform,
    .transition-all,
    .transition-colors,
    .transition-shadow {
        transition: none !important;
        transform: none !important;
    }
}

/* Custom scrollbar for responsive table */
.overflow-x-auto::-webkit-scrollbar {
    height: 6px;
}

.overflow-x-auto::-webkit-scrollbar-track {
    background: #f1f5f9;
}

.overflow-x-auto::-webkit-scrollbar-thumb {
    background: #cbd5e1;
    border-radius: 3px;
}

.overflow-x-auto::-webkit-scrollbar-thumb:hover {
    background: #94a3b8;
}
</style>
@endsection