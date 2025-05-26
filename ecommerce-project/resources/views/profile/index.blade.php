@extends('layouts.app')
@section('show_back_button')
@endsection

@section('content')
<div class="min-h-screen bg-gray-50 py-8 px-4 sm:px-6 lg:px-8">
    <div class="max-w-7xl mx-auto">
        <!-- Header Section -->
        <div class="text-center mb-12">
            <h1 class="text-3xl md:text-4xl font-light text-gray-900 mb-4">Profil Saya</h1>
            <div class="w-16 h-0.5 bg-gray-900 mx-auto"></div>
        </div>

        <div class="grid lg:grid-cols-4 gap-8">
            <!-- Sidebar Profile -->
            <div class="lg:col-span-1">
                <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
            <!-- Profile Avatar Section -->
            <div class="p-8 text-center border-b border-gray-50">
                <div class="relative inline-block mb-6">
                    <div class="w-24 h-24 rounded-full overflow-hidden ring-1 ring-gray-100 hover:ring-gray-200 transition-all duration-300 group">
                        @php
                            $user = auth()->user();
                            $hasAvatar = false;
                            $avatarUrl = null;
                            
                            if ($user->avatar) {
                                // Check if avatar path already includes 'avatars/' or not
                                $avatarPath = $user->avatar;
                                
                                // If avatar field doesn't start with 'avatars/', add it
                                if (!str_starts_with($avatarPath, 'avatars/')) {
                                    $avatarPath = 'avatars/' . $avatarPath;
                                }
                                
                                // Check if file exists in storage
                                if (Storage::disk('public')->exists($avatarPath)) {
                                    $avatarUrl = Storage::disk('public')->url($avatarPath);
                                    $hasAvatar = true;
                                }
                            }
                            
                            // Generate initials as fallback
                            $names = explode(' ', trim($user->name));
                            $initials = '';
                            foreach ($names as $name) {
                                if (!empty($name)) {
                                    $initials .= strtoupper(substr($name, 0, 1));
                                }
                            }
                            $initials = substr($initials, 0, 2);
                            
                            // Ensure we have at least one initial
                            if (empty($initials)) {
                                $initials = strtoupper(substr($user->name, 0, 1));
                            }
                        @endphp
                        
                        @if($hasAvatar && $avatarUrl)
                            <img 
                                src="{{ $avatarUrl }}" 
                                alt="Profile {{ $user->name }}"
                                class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                                onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';"
                            >
                            <!-- Fallback with initials (hidden by default) -->
                            <div class="w-full h-full bg-gradient-to-br from-blue-400 to-purple-500 flex items-center justify-center text-white font-semibold text-lg" style="display: none;">
                                {{ $initials }}
                            </div>
                        @else
                            <!-- Default avatar with initials -->
                            <div class="w-full h-full bg-gradient-to-br from-blue-400 to-purple-500 flex items-center justify-center text-white font-semibold text-lg">
                                {{ $initials }}
                            </div>
                        @endif
                    </div>
                </div>
                
                <h2 class="text-lg font-medium text-gray-900 mb-1">{{ $user->name }}</h2>
                <p class="text-sm text-gray-500 font-light">{{ $user->email }}</p>
            </div>

                    <!-- Navigation Menu -->
                    <nav class="p-6">
                        <div class="space-y-1">
                            <a href="#profile-info" 
                               class="flex items-center px-4 py-3 text-sm text-gray-900 bg-gray-50 rounded-xl transition-all duration-200 group"
                            >
                                <div class="w-5 h-5 mr-3">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" />
                                    </svg>
                                </div>
                                Informasi Profil
                            </a>
                            
                            <a href="{{ route('profile.address') }}" 
                               class="flex items-center px-4 py-3 text-sm text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-xl transition-all duration-200 group"
                            >
                                <div class="w-5 h-5 mr-3">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M15 10.5a3 3 0 11-6 0 3 3 0 016 0z" />
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1115 0z" />
                                    </svg>
                                </div>
                                Alamat
                            </a>
                            
                            <a href="{{ route('orders.index') }}" 
                               class="flex items-center px-4 py-3 text-sm text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-xl transition-all duration-200 group"
                            >
                                <div class="w-5 h-5 mr-3">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 10.5V6a3.75 3.75 0 10-7.5 0v4.5m11.356-1.993l1.263 12c.07.665-.45 1.243-1.119 1.243H4.25a1.125 1.125 0 01-1.12-1.243l1.264-12A1.125 1.125 0 015.513 7.5h12.974c.576 0 1.059.435 1.119.993z" />
                                    </svg>
                                </div>
                                Pesanan
                            </a>
                            
                            <a href="{{ route('profile.edit') }}" 
                               class="flex items-center px-4 py-3 text-sm text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-xl transition-all duration-200 group"
                            >
                                <div class="w-5 h-5 mr-3">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.324.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 011.37.49l1.296 2.247a1.125 1.125 0 01-.26 1.431l-1.003.827c-.293.24-.438.613-.431.992a6.759 6.759 0 010 .255c-.007.378.138.75.43.99l1.005.828c.424.35.534.954.26 1.43l-1.298 2.247a1.125 1.125 0 01-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.57 6.57 0 01-.22.128c-.331.183-.581.495-.644.869l-.213 1.28c-.09.543-.56.941-1.11.941h-2.594c-.55 0-1.02-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 01-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 01-1.369-.49l-1.297-2.247a1.125 1.125 0 01.26-1.431l1.004-.827c.292-.24.437-.613.43-.992a6.932 6.932 0 010-.255c.007-.378-.138-.75-.43-.99l-1.004-.828a1.125 1.125 0 01-.26-1.43l1.297-2.247a1.125 1.125 0 011.37-.491l1.216.456c.356.133.751.072 1.076-.124.072-.044.146-.087.22-.128.332-.183.582-.495.644-.869l.214-1.281z" />
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                    </svg>
                                </div>
                                Pengaturan
                            </a>
                        </div>
                    </nav>
                </div>
            </div>

            <!-- Main Content -->
            <div class="lg:col-span-3">
                <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
                    <!-- Header -->
                    <div class="p-8 border-b border-gray-50" id="profile-info">
                        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                            <div>
                                <h2 class="text-2xl font-light text-gray-900 mb-2">Informasi Profil</h2>
                                <p class="text-sm text-gray-500 font-light">Kelola informasi pribadi Anda</p>
                            </div>
                            <a href="{{ route('profile.edit') }}" 
                               class="inline-flex items-center px-6 py-2.5 bg-gray-900 text-white text-sm font-medium rounded-xl hover:bg-gray-800 transition-colors duration-200 group"
                            >
                                <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 mr-2 group-hover:scale-110 transition-transform duration-200" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M16.862 4.487l1.687-1.688a1.875 1.875 0 112.652 2.652L10.582 16.07a4.5 4.5 0 01-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 011.13-1.897l8.932-8.931zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0115.75 21H5.25A2.25 2.25 0 013 18.75V8.25A2.25 2.25 0 015.25 6H10" />
                                </svg>
                                Edit Profil
                            </a>
                        </div>
                    </div>

                    <!-- Profile Information -->
                    <div class="p-8">
                        <div class="grid sm:grid-cols-2 gap-8">
                            <!-- Left Column -->
                            <div class="space-y-6">
                                <div class="group">
                                    <label class="block text-xs font-medium text-gray-400 uppercase tracking-wider mb-2">
                                        Nama Lengkap
                                    </label>
                                    <p class="text-gray-900 font-light text-lg">{{ auth()->user()->name }}</p>
                                </div>
                                
                                <div class="group">
                                    <label class="block text-xs font-medium text-gray-400 uppercase tracking-wider mb-2">
                                        Email
                                    </label>
                                    <p class="text-gray-900 font-light text-lg">{{ auth()->user()->email }}</p>
                                </div>
                                
                                <div class="group">
                                    <label class="block text-xs font-medium text-gray-400 uppercase tracking-wider mb-2">
                                        Nomor Telepon
                                    </label>
                                    <p class="text-gray-900 font-light text-lg">
                                        {{ auth()->user()->phone ?? 'Belum diatur' }}
                                    </p>
                                </div>
                            </div>

                            <!-- Right Column -->
                            <div class="space-y-6">
                                <div class="group">
                                    <label class="block text-xs font-medium text-gray-400 uppercase tracking-wider mb-2">
                                        Bergabung Sejak
                                    </label>
                                    <p class="text-gray-900 font-light text-lg">
                                        {{ auth()->user()->created_at->format('d M Y') }}
                                    </p>
                                </div>
                                
                                <div class="group">
                                    <label class="block text-xs font-medium text-gray-400 uppercase tracking-wider mb-2">
                                        Terakhir Diperbarui
                                    </label>
                                    <p class="text-gray-900 font-light text-lg">
                                        {{ auth()->user()->updated_at->format('d M Y') }}
                                    </p>
                                </div>
                                
                                <div class="group">
                                    <label class="block text-xs font-medium text-gray-400 uppercase tracking-wider mb-2">
                                        Status Akun
                                    </label>
                                    <div class="flex items-center">
                                        <div class="w-2 h-2 bg-green-400 rounded-full mr-2"></div>
                                        <p class="text-gray-900 font-light text-lg">Aktif</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection