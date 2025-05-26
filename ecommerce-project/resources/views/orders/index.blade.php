@extends('layouts.app')
@section('show_back_button')
@endsection

@section('content')
<div class="min-h-screen bg-gray-50">
    <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8 sm:py-12">
        <!-- Header Section -->
        <div class="mb-12">
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-6">
                <div>
                    <h1 class="text-2xl sm:text-3xl font-light text-gray-900 tracking-tight">Pesanan Saya</h1>
                    <p class="mt-2 text-sm text-gray-500">Kelola dan pantau semua pesanan Anda</p>
                </div>
                <a href="{{ route('products.index') }}" 
                   class="inline-flex items-center justify-center px-6 py-3 bg-gray-900 text-white text-sm font-medium hover:bg-gray-800 transition-all duration-300 ease-in-out transform hover:scale-105 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-900">
                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
                    </svg>
                    Lanjutkan Belanja
                </a>
            </div>
        </div>

        @if($orders->count() > 0)
            <!-- Orders Grid -->
            <div class="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6">
                @foreach($orders as $order)
                    <div class="bg-white hover:shadow-lg transition-all duration-300 ease-in-out transform hover:-translate-y-1 group">
                        <div class="p-6">
                            <!-- Order Header -->
                            <div class="flex items-center justify-between mb-4">
                                <div class="flex items-center space-x-3">
                                    <div class="w-10 h-10 bg-gray-100 flex items-center justify-center">
                                        <svg class="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
                                        </svg>
                                    </div>
                                    <div>
                                        <h3 class="text-sm font-medium text-gray-900">#{{ $order->id }}</h3>
                                        <p class="text-xs text-gray-500">{{ $order->created_at->format('d M Y') }}</p>
                                    </div>
                                </div>
                                
                                <!-- Status Badge -->
                                @if($order->status == 'completed')
                                    <span class="px-2 py-1 text-xs font-medium bg-green-50 text-green-700 border border-green-200">
                                        Selesai
                                    </span>
                                @elseif($order->status == 'processing')
                                    <span class="px-2 py-1 text-xs font-medium bg-yellow-50 text-yellow-700 border border-yellow-200">
                                        Diproses
                                    </span>
                                @elseif($order->status == 'cancelled')
                                    <span class="px-2 py-1 text-xs font-medium bg-red-50 text-red-700 border border-red-200">
                                        Dibatalkan
                                    </span>
                                @elseif($order->status == 'pending')
                                    <span class="px-2 py-1 text-xs font-medium bg-blue-50 text-blue-700 border border-blue-200">
                                        Menunggu
                                    </span>
                                @else
                                    <span class="px-2 py-1 text-xs font-medium bg-gray-50 text-gray-700 border border-gray-200">
                                        {{ $order->status }}
                                    </span>
                                @endif
                            </div>

                            <!-- Order Details -->
                            <div class="space-y-3 mb-6">
                                <div class="flex justify-between items-center">
                                    <span class="text-sm text-gray-500">Total</span>
                                    <span class="text-lg font-light text-gray-900">Rp {{ number_format($order->total_amount, 0, ',', '.') }}</span>
                                </div>
                                <div class="flex justify-between items-center">
                                    <span class="text-sm text-gray-500">Waktu</span>
                                    <span class="text-sm text-gray-700">{{ $order->created_at->format('H:i') }}</span>
                                </div>
                            </div>

                            <!-- Action Button -->
                            <div class="pt-4 border-t border-gray-100">
                                <a href="{{ route('orders.show', $order->id) }}" 
                                   class="w-full inline-flex items-center justify-center px-4 py-2.5 bg-gray-50 text-gray-700 text-sm font-medium hover:bg-gray-100 transition-colors duration-200 group-hover:bg-gray-900 group-hover:text-white">
                                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                    </svg>
                                    Lihat Detail
                                </a>
                            </div>
                        </div>
                    </div>
                @endforeach
            </div>

            <!-- Pagination -->
            @if(method_exists($orders, 'links'))
            <div class="mt-12 flex justify-center">
                <div class="bg-white px-6 py-4 shadow-sm">
                    {{ $orders->links() }}
                </div>
            </div>
            @endif

        @else
            <!-- Empty State -->
            <div class="bg-white">
                <div class="px-6 py-20 text-center">
                    <div class="w-20 h-20 mx-auto mb-8 bg-gray-100 flex items-center justify-center">
                        <svg class="w-10 h-10 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
                        </svg>
                    </div>
                    <h3 class="text-xl font-light text-gray-900 mb-3">Belum ada pesanan</h3>
                    <p class="text-gray-500 mb-8 max-w-sm mx-auto">Anda belum memiliki pesanan apapun. Mulai berbelanja sekarang untuk melihat pesanan di sini.</p>
                    <a href="{{ route('products.index') }}" 
                       class="inline-flex items-center px-8 py-3 bg-gray-900 text-white text-sm font-medium hover:bg-gray-800 transition-all duration-300 ease-in-out transform hover:scale-105 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-900">
                        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
                        </svg>
                        Mulai Belanja
                    </a>
                </div>
            </div>
        @endif
    </div>
</div>

<style>
/* Custom Pagination Styling */
.pagination {
    @apply flex items-center space-x-1;
}

.pagination .page-link {
    @apply px-3 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors duration-200;
}

.pagination .page-item.active .page-link {
    @apply bg-gray-900 text-white hover:bg-gray-800;
}

.pagination .page-item.disabled .page-link {
    @apply text-gray-400 cursor-not-allowed hover:bg-transparent;
}

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
</style>
@endsection