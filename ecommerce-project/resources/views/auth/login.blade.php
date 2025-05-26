@extends('layouts.app')

@section('content')
<div class="min-h-screen flex items-center justify-center bg-white py-16 px-4 sm:px-6 lg:px-8">
    <div class="w-full max-w-sm space-y-10">
        <!-- Header -->
        <div class="text-center space-y-2">
            <h1 class="text-2xl font-light text-gray-900 tracking-wide">
                Welcome Back
            </h1>
            <p class="text-sm font-light text-gray-500">
                Please sign in to your account
            </p>
        </div>
        
        <!-- Form -->
        <form class="space-y-8" action="{{ route('login') }}" method="POST">
            @csrf
            
            <!-- Input Fields -->
            <div class="space-y-6">
                <div class="group">
                    <label for="email" class="block text-xs font-medium text-gray-700 mb-2 tracking-wide uppercase">
                        Email Address
                    </label>
                    <input id="email" 
                           name="email" 
                           type="email" 
                           required 
                           class="w-full px-0 py-3 text-gray-900 placeholder-gray-400 bg-transparent border-0 border-b border-gray-200 focus:border-gray-900 focus:outline-none focus:ring-0 transition-colors duration-300 font-light"
                           placeholder="Enter your email"
                           value="{{ old('email') }}">
                </div>
                
                <div class="group">
                    <label for="password" class="block text-xs font-medium text-gray-700 mb-2 tracking-wide uppercase">
                        Password
                    </label>
                    <input id="password" 
                           name="password" 
                           type="password" 
                           required 
                           class="w-full px-0 py-3 text-gray-900 placeholder-gray-400 bg-transparent border-0 border-b border-gray-200 focus:border-gray-900 focus:outline-none focus:ring-0 transition-colors duration-300 font-light"
                           placeholder="Enter your password">
                </div>
            </div>

            <!-- Error Messages -->
            @if ($errors->any())
                <div class="space-y-1">
                    @foreach ($errors->all() as $error)
                        <p class="text-xs text-red-500 font-light">{{ $error }}</p>
                    @endforeach
                </div>
            @endif

            <!-- Remember & Forgot -->
            <div class="flex items-center justify-between">
                <label class="flex items-center cursor-pointer group">
                    <input type="checkbox" 
                           name="remember" 
                           class="w-4 h-4 text-gray-900 border-gray-300 rounded focus:ring-0 focus:ring-offset-0">
                    <span class="ml-3 text-sm font-light text-gray-600 group-hover:text-gray-900 transition-colors duration-200">
                        Remember me
                    </span>
                </label>

                <a href="{{ route('password.request') }}" 
                   class="text-sm font-light text-gray-600 hover:text-gray-900 transition-colors duration-200 underline-offset-4 hover:underline">
                    Forgot password?
                </a>
            </div>

            <!-- Submit Button -->
            <div class="pt-4">
                <button type="submit" 
                        class="group w-full py-4 px-6 text-sm font-medium tracking-wide uppercase text-white bg-gray-900 hover:bg-gray-800 focus:outline-none focus:ring-0 transition-all duration-300 transform hover:scale-[1.02] active:scale-[0.98]">
                    <span class="flex items-center justify-center">
                        Sign In
                        <svg class="w-4 h-4 ml-2 group-hover:translate-x-1 transition-transform duration-200" 
                             fill="none" 
                             stroke="currentColor" 
                             viewBox="0 0 24 24">
                            <path stroke-linecap="round" 
                                  stroke-linejoin="round" 
                                  stroke-width="2" 
                                  d="M17 8l4 4m0 0l-4 4m4-4H3">
                            </path>
                        </svg>
                    </span>
                </button>
            </div>
        </form>
        
        <!-- Register Link -->
        <div class="text-center pt-8 border-t border-gray-100">
            <p class="text-sm font-light text-gray-500">
                Don't have an account? 
                <a href="{{ route('register') }}" 
                   class="font-medium text-gray-900 hover:underline underline-offset-4 transition-all duration-200">
                    Create one here
                </a>
            </p>
        </div>
    </div>
</div>

<style>
    /* Custom styles for enhanced elegance */
    .group input:focus + label,
    .group input:not(:placeholder-shown) + label {
        @apply text-gray-900;
    }
    
    /* Smooth focus transitions */
    input[type="email"]:focus,
    input[type="password"]:focus {
        box-shadow: none;
    }
    
    /* Custom checkbox styling */
    input[type="checkbox"]:checked {
        background-color: #111827;
        border-color: #111827;
    }
    
    /* Responsive adjustments */
    @media (max-width: 640px) {
        .space-y-10 > * + * {
            margin-top: 2rem;
        }
        
        .space-y-8 > * + * {
            margin-top: 1.5rem;
        }
    }
    
    /* Subtle animations */
    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(20px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    
    .min-h-screen > div {
        animation: fadeInUp 0.6s ease-out;
    }
</style>
@endsection