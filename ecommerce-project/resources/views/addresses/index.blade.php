@extends('layouts.app')
@section('show_back_button')
@endsection
@section('title', 'My Addresses')

@section('content')
<div class="min-h-screen bg-gray-50">
    <!-- Page Header -->
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-12 pb-8">
        <div class="text-center space-y-4">
            <h1 class="text-4xl md:text-5xl font-light text-gray-900 tracking-tight">
                My Addresses
            </h1>
            <p class="text-lg text-gray-500 font-light max-w-md mx-auto">
                Manage your delivery locations with ease
            </p>
            <div class="pt-6">
                <a href="{{ route('addresses.create') }}" 
                   class="inline-flex items-center px-8 py-3 bg-black text-white font-medium text-sm tracking-wide uppercase transition-all duration-300 hover:bg-gray-800 hover:scale-105 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2">
                    Add New Address
                </a>
            </div>
        </div>
    </div>

    <!-- Alerts -->
    @if(session('success'))
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mb-8">
            <div class="bg-white border border-green-200 text-green-800 px-6 py-4 flex items-center justify-between shadow-sm">
                <span class="font-light">{{ session('success') }}</span>
                <button onclick="this.parentElement.parentElement.remove()" 
                        class="text-green-600 hover:text-green-800 font-light text-xl">
                    ×
                </button>
            </div>
        </div>
    @endif

    @if(session('error'))
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mb-8">
            <div class="bg-white border border-red-200 text-red-800 px-6 py-4 flex items-center justify-between shadow-sm">
                <span class="font-light">{{ session('error') }}</span>
                <button onclick="this.parentElement.parentElement.remove()" 
                        class="text-red-600 hover:text-red-800 font-light text-xl">
                    ×
                </button>
            </div>
        </div>
    @endif

    <!-- Main Content -->
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
        @if($addresses->count() > 0)
            <!-- Addresses Grid -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-8">
                @foreach($addresses as $address)
                    <div class="group bg-white border border-gray-100 transition-all duration-500 hover:shadow-lg hover:scale-105 hover:border-gray-200">
                        <!-- Card Content -->
                        <div class="p-8 space-y-6">
                            <!-- Header -->
                            <div class="flex items-start justify-between">
                                <h3 class="text-lg font-light text-gray-900">
                                    Address {{ $loop->iteration }}
                                </h3>
                                @if($address->is_default)
                                    <span class="bg-black text-white px-3 py-1 text-xs font-medium tracking-wide uppercase">
                                        Default
                                    </span>
                                @endif
                            </div>
                            
                            <!-- Address Content -->
                            <div class="space-y-2 text-gray-600 font-light leading-relaxed">
                                <p>{{ $address->street_address }}</p>
                                <p>{{ $address->city }}, {{ $address->state }}</p>
                                <p>{{ $address->postal_code }}</p>
                                @if($address->country)
                                    <p>{{ $address->country }}</p>
                                @endif
                            </div>
                        </div>
                        
                        <!-- Actions -->
                        <div class="px-8 pb-8 flex items-center justify-end space-x-3">
                            <a href="{{ route('addresses.edit', $address->id) }}" 
                               class="w-10 h-10 border border-gray-200 text-gray-600 hover:bg-black hover:text-white hover:border-black transition-all duration-300 flex items-center justify-center group/edit"
                               title="Edit Address">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                                </svg>
                            </a>
                            
                            <button type="button" 
                                    onclick="confirmDelete({{ $address->id }})"
                                    class="w-10 h-10 border border-gray-200 text-gray-600 hover:bg-red-500 hover:text-white hover:border-red-500 transition-all duration-300 flex items-center justify-center"
                                    title="Delete Address">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                                </svg>
                            </button>
                        </div>
                    </div>
                @endforeach
            </div>
        @else
            <!-- Empty State -->
            <div class="text-center py-24">
                <div class="max-w-md mx-auto space-y-8">
                    <!-- Icon -->
                    <div class="mx-auto w-24 h-24 bg-gray-100 rounded-full flex items-center justify-center">
                        <svg class="w-12 h-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
                        </svg>
                    </div>
                    
                    <!-- Content -->
                    <div class="space-y-4">
                        <h2 class="text-2xl font-light text-gray-900">
                            No addresses yet
                        </h2>
                        <p class="text-gray-500 font-light">
                            Add your first delivery address to get started with seamless ordering
                        </p>
                    </div>
                    
                    <!-- CTA -->
                    <div class="pt-4">
                        <a href="{{ route('addresses.create') }}" 
                           class="inline-flex items-center px-8 py-3 bg-black text-white font-medium text-sm tracking-wide uppercase transition-all duration-300 hover:bg-gray-800 hover:scale-105 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2">
                            Add Your First Address
                        </a>
                    </div>
                </div>
            </div>
        @endif
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
    function confirmDelete(addressId) {
        const modal = document.getElementById('deleteModal');
        const modalContent = document.getElementById('modalContent');
        document.getElementById('deleteForm').action = `/addresses/${addressId}`;
        
        modal.classList.remove('hidden');
        modal.classList.add('flex');
        
        // Animation
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

    // Auto-hide alerts after 5 seconds
    setTimeout(function() {
        const alerts = document.querySelectorAll('[class*="border-green-200"], [class*="border-red-200"]');
        alerts.forEach(alert => {
            alert.style.transition = 'opacity 0.5s ease-out';
            alert.style.opacity = '0';
            setTimeout(() => alert.remove(), 500);
        });
    }, 5000);

    // Add smooth scroll behavior
    document.documentElement.style.scrollBehavior = 'smooth';
</script>
@endpush