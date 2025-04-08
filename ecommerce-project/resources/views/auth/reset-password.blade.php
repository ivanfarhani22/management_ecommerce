@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-8">
    <div class="max-w-md mx-auto bg-white shadow-md rounded-lg p-6">
        <h2 class="text-2xl font-bold mb-6 text-center">Reset Password</h2>
        
        <form method="POST" action="{{ route('password.update') }}">
            @csrf
            
            <input type="hidden" name="token" value="{{ $request->route('token') }}">

            <div class="mb-4">
                <label for="email" class="block text-gray-700 text-sm font-bold mb-2">Email Address</label>
                <input type="email" name="email" id="email" 
                       class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                       value="{{ old('email', $request->email) }}" required autofocus>
                @error('email')
                    <p class="text-red-500 text-xs italic mt-2">{{ $message }}</p>
                @enderror
            </div>

            <div class="mb-4">
                <label for="password" class="block text-gray-700 text-sm font-bold mb-2">New Password</label>
                <input type="password" name="password" id="password" 
                       class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                       required autocomplete="new-password">
                @error('password')
                    <p class="text-red-500 text-xs italic mt-2">{{ $message }}</p>
                @enderror
            </div>

            <div class="mb-4">
                <label for="password_confirmation" class="block text-gray-700 text-sm font-bold mb-2">Confirm New Password</label>
                <input type="password" name="password_confirmation" id="password_confirmation" 
                       class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                       required autocomplete="new-password">
            </div>

            <div class="mb-4">
                <button type="submit" 
                        class="w-full bg-blue-500 text-white py-2 px-4 rounded-md hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50">
                    Reset Password
                </button>
            </div>
        </form>
    </div>
</div>
@endsection