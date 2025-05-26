@extends('layouts.app')

@section('content')
<div class="min-h-screen flex items-center justify-center bg-white py-16 px-4 sm:px-6 lg:px-8">
    <div class="w-full max-w-sm space-y-10">
        <!-- Header -->
        <div class="text-center space-y-2">
            <h1 class="text-2xl font-light text-gray-900 tracking-wide">
                Create Account
            </h1>
            <p class="text-sm font-light text-gray-500">
                Join us and start your journey
            </p>
        </div>
        
        <!-- Form -->
        <form class="space-y-8" method="POST" action="{{ route('register') }}">
            @csrf
            
            <!-- Input Fields -->
            <div class="space-y-6">
                <div class="group">
                    <label for="name" class="block text-xs font-medium text-gray-700 mb-2 tracking-wide uppercase">
                        Full Name
                    </label>
                    <input id="name" 
                           name="name" 
                           type="text" 
                           required 
                           autofocus
                           class="w-full px-0 py-3 text-gray-900 placeholder-gray-400 bg-transparent border-0 border-b border-gray-200 focus:border-gray-900 focus:outline-none focus:ring-0 transition-colors duration-300 font-light"
                           placeholder="Enter your full name"
                           value="{{ old('name') }}">
                    @error('name')
                        <p class="text-xs text-red-500 font-light mt-2">{{ $message }}</p>
                    @enderror
                </div>
                
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
                    @error('email')
                        <p class="text-xs text-red-500 font-light mt-2">{{ $message }}</p>
                    @enderror
                </div>
                
                <div class="group">
                    <label for="password" class="block text-xs font-medium text-gray-700 mb-2 tracking-wide uppercase">
                        Password
                    </label>
                    <input id="password" 
                           name="password" 
                           type="password" 
                           required 
                           autocomplete="new-password"
                           class="w-full px-0 py-3 text-gray-900 placeholder-gray-400 bg-transparent border-0 border-b border-gray-200 focus:border-gray-900 focus:outline-none focus:ring-0 transition-colors duration-300 font-light"
                           placeholder="Create a password">
                    @error('password')
                        <p class="text-xs text-red-500 font-light mt-2">{{ $message }}</p>
                    @enderror
                </div>
                
                <div class="group">
                    <label for="password_confirmation" class="block text-xs font-medium text-gray-700 mb-2 tracking-wide uppercase">
                        Confirm Password
                    </label>
                    <input id="password_confirmation" 
                           name="password_confirmation" 
                           type="password" 
                           required 
                           autocomplete="new-password"
                           class="w-full px-0 py-3 text-gray-900 placeholder-gray-400 bg-transparent border-0 border-b border-gray-200 focus:border-gray-900 focus:outline-none focus:ring-0 transition-colors duration-300 font-light"
                           placeholder="Confirm your password">
                </div>
            </div>

            <!-- Password Requirements -->
            <div class="bg-gray-50 p-4 space-y-2">
                <p class="text-xs font-medium text-gray-700 tracking-wide uppercase mb-2">Password Requirements</p>
                <div class="space-y-1 text-xs text-gray-500 font-light">
                    <p class="flex items-center">
                        <span class="w-1 h-1 bg-gray-300 rounded-full mr-2"></span>
                        At least 8 characters long
                    </p>
                    <p class="flex items-center">
                        <span class="w-1 h-1 bg-gray-300 rounded-full mr-2"></span>
                        Mix of letters and numbers
                    </p>
                </div>
            </div>

            <!-- Submit Button -->
            <div class="pt-2">
                <button type="submit" 
                        class="group w-full py-4 px-6 text-sm font-medium tracking-wide uppercase text-white bg-gray-900 hover:bg-gray-800 focus:outline-none focus:ring-0 transition-all duration-300 transform hover:scale-[1.02] active:scale-[0.98]">
                    <span class="flex items-center justify-center">
                        Create Account
                        <svg class="w-4 h-4 ml-2 group-hover:translate-x-1 transition-transform duration-200" 
                             fill="none" 
                             stroke="currentColor" 
                             viewBox="0 0 24 24">
                            <path stroke-linecap="round" 
                                  stroke-linejoin="round" 
                                  stroke-width="2" 
                                  d="M13 7l5 5m0 0l-5 5m5-5H6">
                            </path>
                        </svg>
                    </span>
                </button>
            </div>
        </form>
        
        <!-- Login Link -->
        <div class="text-center pt-8 border-t border-gray-100">
            <p class="text-sm font-light text-gray-500">
                Already have an account? 
                <a href="{{ route('login') }}" 
                   class="font-medium text-gray-900 hover:underline underline-offset-4 transition-all duration-200">
                    Sign in here
                </a>
            </p>
        </div>
        
        <!-- Terms & Privacy -->
        <div class="text-center pt-4">
            <p class="text-xs font-light text-gray-400 leading-relaxed">
                By creating an account, you agree to our 
                <a href="#" class="underline hover:text-gray-600 transition-colors duration-200">Terms of Service</a> 
                and 
                <a href="#" class="underline hover:text-gray-600 transition-colors duration-200">Privacy Policy</a>
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
    input[type="text"]:focus,
    input[type="email"]:focus,
    input[type="password"]:focus {
        box-shadow: none;
    }
    
    /* Password strength indicator (optional enhancement) */
    .password-strength {
        height: 2px;
        background-color: #e5e7eb;
        border-radius: 1px;
        overflow: hidden;
        margin-top: 8px;
    }
    
    .password-strength-bar {
        height: 100%;
        transition: all 0.3s ease;
        border-radius: 1px;
    }
    
    /* Responsive adjustments */
    @media (max-width: 640px) {
        .space-y-10 > * + * {
            margin-top: 2rem;
        }
        
        .space-y-8 > * + * {
            margin-top: 1.5rem;
        }
        
        .space-y-6 > * + * {
            margin-top: 1rem;
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
    
    /* Form field focus animation */
    .group {
        position: relative;
    }
    
    .group input:focus {
        transform: translateY(-1px);
    }
    
    /* Error message styling */
    .text-red-500 {
        animation: fadeInUp 0.3s ease-out;
    }
</style>

<script>
    // Optional: Password strength indicator
    document.addEventListener('DOMContentLoaded', function() {
        const passwordInput = document.getElementById('password');
        const confirmInput = document.getElementById('password_confirmation');
        
        // Add subtle visual feedback for password confirmation
        if (confirmInput) {
            confirmInput.addEventListener('input', function() {
                if (this.value && passwordInput.value) {
                    if (this.value === passwordInput.value) {
                        this.style.borderColor = '#10b981';
                    } else {
                        this.style.borderColor = '#ef4444';
                    }
                } else {
                    this.style.borderColor = '#d1d5db';
                }
            });
        }
    });
</script>
@endsection