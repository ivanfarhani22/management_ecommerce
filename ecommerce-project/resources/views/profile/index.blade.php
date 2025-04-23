@extends('layouts.app')
@section('show_back_button')
@endsection

@section('content')
<div class="grid md:grid-cols-12 gap-6">
    <!-- Sidebar Profil -->
    <div class="md:col-span-3 bg-white shadow-lg rounded-lg p-6">
        <div class="flex flex-col items-center">
            <div class="relative">
                <img 
                    src="{{ auth()->user()->avatar ?? asset('default-avatar.png') }}" 
                    alt="Foto Profil" 
                    class="w-32 h-32 rounded-full object-cover border-4 border-blue-100 shadow-md hover:scale-105 transition duration-300"
                >
                <span class="absolute bottom-0 right-0 bg-blue-500 text-white rounded-full w-8 h-8 flex items-center justify-center">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                        <path fill-rule="evenodd" d="M4 5a2 2 0 00-2 2v8a2 2 0 002 2h12a2 2 0 002-2V7a2 2 0 00-2-2h-1.586a1 1 0 01-.707-.293l-1.414-1.414A1 1 0 0011.586 3H8.414a1 1 0 00-.707.293L6.293 4.707A1 1 0 015.586 5H4zm6 9a3 3 0 100-6 3 3 0 000 6z" clip-rule="evenodd" />
                    </svg>
                </span>
            </div>

            <div class="text-center mt-4">
                <h2 class="text-xl font-bold text-gray-800">{{ auth()->user()->name }}</h2>
                <p class="text-sm text-gray-500">{{ auth()->user()->email }}</p>
            </div>

            <div class="w-full mt-6">
                <nav class="space-y-2">
                    <a href="#profile-info" 
                       class="flex items-center px-4 py-2 text-gray-700 hover:bg-blue-50 rounded-lg transition duration-200 group active:bg-blue-100"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-3 text-gray-400 group-hover:text-blue-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                        </svg>
                        Informasi Profil
                    </a>
                    <a href="#addresses" 
                       class="flex items-center px-4 py-2 text-gray-700 hover:bg-blue-50 rounded-lg transition duration-200 group"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-3 text-gray-400 group-hover:text-blue-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                        </svg>
                        Alamat
                    </a>
                    <a href="orders" 
                       class="flex items-center px-4 py-2 text-gray-700 hover:bg-blue-50 rounded-lg transition duration-200 group"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-3 text-gray-400 group-hover:text-blue-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
                        </svg>
                        Pesanan
                    </a>
                    <a href="{{ route('profile.edit') }}" 
                       class="flex items-center px-4 py-2 text-gray-700 hover:bg-blue-50 rounded-lg transition duration-200 group"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-3 text-gray-400 group-hover:text-blue-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                        </svg>
                        Pengaturan Akun
                    </a>
                </nav>
            </div>
        </div>
    </div>

    <!-- Konten Profil -->
    <div class="md:col-span-9">
        <div class="bg-white shadow-lg rounded-lg overflow-hidden">
            <!-- Tab Informasi Profil -->
            <div class="p-6" id="profile-info">
                <div class="flex justify-between items-center border-b pb-4 mb-6">
                    <h2 class="text-2xl font-bold text-gray-800">Informasi Profil</h2>
                    <a href="{{ route('profile.edit') }}" class="text-blue-500 hover:text-blue-700 transition duration-200 flex items-center">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" viewBox="0 0 20 20" fill="currentColor">
                            <path d="M13.586 3.586a2 2 0 112.828 2.828l-.793.793-2.828-2.828.793-.793zM11.379 5.793L3 14.172V17h2.828l8.38-8.379-2.83-2.828z" />
                        </svg>
                        Edit Profil
                    </a>
                </div>

                <div class="grid md:grid-cols-2 gap-6">
                    <div>
                        <div class="mb-4">
                            <label class="block text-gray-700 font-bold mb-2">Nama Lengkap</label>
                            <p class="text-gray-600">{{ auth()->user()->name }}</p>
                        </div>
                        <div class="mb-4">
                            <label class="block text-gray-700 font-bold mb-2">Email</label>
                            <p class="text-gray-600">{{ auth()->user()->email }}</p>
                        </div>
                        <div class="mb-4">
                            <label class="block text-gray-700 font-bold mb-2">Telepon</label>
                            <p class="text-gray-600">{{ auth()->user()->phone ?? 'Belum diatur' }}</p>
                        </div>
                    </div>
                    <div>
                        <div class="mb-4">
                            <label class="block text-gray-700 font-bold mb-2">Bergabung Sejak</label>
                            <p class="text-gray-600">{{ auth()->user()->created_at->format('d M Y') }}</p>
                        </div>
                        <div class="mb-4">
                            <label class="block text-gray-700 font-bold mb-2">Terakhir Diperbarui</label>
                            <p class="text-gray-600">{{ auth()->user()->updated_at->format('d M Y') }}</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection