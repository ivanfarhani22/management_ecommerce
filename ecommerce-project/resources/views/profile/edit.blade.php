@extends('layouts.app')

@section('show_back_button')
@endsection

@section('content')
<div class="max-w-md mx-auto my-8 px-4 md:my-12 md:px-8">
    <div class="bg-white rounded-xl p-8 md:p-12 shadow-sm border border-gray-50 transition-all duration-300 hover:shadow-lg">
        <h1 class="text-2xl font-light text-gray-900 mb-8 text-center tracking-tight">Edit Profile</h1>
        
        {{-- Success Message --}}
        @if(session('success'))
            <div class="bg-blue-50 text-blue-800 p-4 rounded-lg mb-6 border border-blue-100 font-light">
                {{ session('success') }}
            </div>
        @endif

        {{-- Error Messages --}}
        @if($errors->any())
            <div class="bg-red-50 text-red-700 p-4 rounded-lg mb-6 border border-red-100 font-light">
                @foreach($errors->all() as $error)
                    <div>{{ $error }}</div>
                @endforeach
            </div>
        @endif
        
        <form action="{{ route('profile.update') }}" method="POST" enctype="multipart/form-data" id="profileForm">
            @csrf
            @method('PUT')
            
            {{-- Avatar Section --}}
            <div class="text-center mb-10">
                <div class="w-20 h-20 rounded-full mx-auto mb-4 bg-gray-100 border-2 border-gray-200 overflow-hidden transition-all duration-300 hover:scale-105 hover:shadow-md relative" id="avatarPreview">
                    @php
                        $hasAvatar = false;
                        $avatarUrl = null;
                        
                        if ($user->avatar) {
                            // Check if avatar exists in storage/app/public/avatars
                            if (Storage::disk('public')->exists('avatars/' . $user->avatar)) {
                                $avatarUrl = asset('storage/avatars/' . $user->avatar);
                                $hasAvatar = true;
                            }
                            // Check if avatar exists in public/avatars
                            elseif (file_exists(public_path('avatars/' . $user->avatar))) {
                                $avatarUrl = asset('avatars/' . $user->avatar);
                                $hasAvatar = true;
                            }
                            // Check if avatar is a valid URL
                            elseif (filter_var($user->avatar, FILTER_VALIDATE_URL)) {
                                $avatarUrl = $user->avatar;
                                $hasAvatar = true;
                            }
                            // Fallback: check if it's stored in storage without avatars/ prefix
                            elseif (Storage::disk('public')->exists($user->avatar)) {
                                $avatarUrl = asset('storage/' . $user->avatar);
                                $hasAvatar = true;
                            }
                        }
                        
                        // Generate initials for fallback
                        $names = explode(' ', $user->name);
                        $initials = '';
                        foreach ($names as $name) {
                            $initials .= strtoupper(substr($name, 0, 1));
                        }
                        $initials = substr($initials, 0, 2);
                    @endphp
                    
                    @if($hasAvatar)
                        <img src="{{ $avatarUrl }}" alt="Current Avatar" class="w-full h-full object-cover" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                        <!-- Fallback with initials -->
                        <div class="w-full h-full bg-gradient-to-br from-blue-400 to-purple-500 flex items-center justify-center text-white font-semibold text-sm hidden">
                            {{ $initials }}
                        </div>
                    @else
                        <!-- Default avatar with initials -->
                        <div class="w-full h-full bg-gradient-to-br from-blue-400 to-purple-500 flex items-center justify-center text-white font-semibold text-sm">
                            {{ $initials }}
                        </div>
                    @endif
                </div>
                
                <div class="mb-6">
                    <label class="block text-sm font-normal text-gray-600 mb-2 tracking-wide">Profile Picture</label>
                    <div class="relative inline-block w-full">
                        <input type="file" id="avatar" name="avatar" class="absolute opacity-0 w-full h-full cursor-pointer" accept="image/*">
                        <label for="avatar" class="block py-3.5 px-4 border border-dashed border-gray-300 rounded-lg text-center cursor-pointer transition-all duration-300 text-gray-600 font-light hover:border-gray-900 hover:text-gray-900">
                            Choose a photo or drag here
                        </label>
                    </div>
                </div>
            </div>
            
            {{-- Name Field --}}
            <div class="mb-6">
                <label for="name" class="block text-sm font-normal text-gray-600 mb-2 tracking-wide">Full Name</label>
                <input 
                    type="text" 
                    id="name" 
                    name="name" 
                    class="w-full py-3.5 px-4 border border-gray-200 rounded-lg text-base font-light text-gray-900 bg-white transition-all duration-300 focus:outline-none focus:border-gray-900 focus:shadow-sm focus:ring-3 focus:ring-gray-900 focus:ring-opacity-5" 
                    value="{{ old('name', $user->name) }}" 
                    required
                    placeholder="Enter your full name"
                >
            </div>
            
            {{-- Email Field --}}
            <div class="mb-6">
                <label for="email" class="block text-sm font-normal text-gray-600 mb-2 tracking-wide">Email Address</label>
                <input 
                    type="email" 
                    id="email" 
                    name="email" 
                    class="w-full py-3.5 px-4 border border-gray-200 rounded-lg text-base font-light text-gray-900 bg-white transition-all duration-300 focus:outline-none focus:border-gray-900 focus:shadow-sm focus:ring-3 focus:ring-gray-900 focus:ring-opacity-5" 
                    value="{{ old('email', $user->email) }}" 
                    required
                    placeholder="Enter your email address"
                >
            </div>
            
            {{-- Phone Field --}}
            <div class="mb-6">
                <label for="phone" class="block text-sm font-normal text-gray-600 mb-2 tracking-wide">Phone Number</label>
                <input 
                    type="tel" 
                    id="phone" 
                    name="phone" 
                    class="w-full py-3.5 px-4 border border-gray-200 rounded-lg text-base font-light text-gray-900 bg-white transition-all duration-300 focus:outline-none focus:border-gray-900 focus:shadow-sm focus:ring-3 focus:ring-gray-900 focus:ring-opacity-5" 
                    value="{{ old('phone', $user->phone) }}" 
                    placeholder="Enter your phone number"
                >
            </div>
            
            {{-- Submit Button --}}
            <button type="submit" class="w-full py-4 bg-gray-900 text-white border-0 rounded-lg text-base font-normal cursor-pointer transition-all duration-300 mt-4 tracking-wide hover:bg-gray-700 hover:-translate-y-0.5 hover:shadow-md active:translate-y-0 disabled:bg-gray-400 disabled:cursor-not-allowed disabled:transform-none" id="submitButton">
                Update Profile
            </button>
        </form>
    </div>
</div>

{{-- Custom Styles for Mobile --}}
<style>
    @media (max-width: 480px) {
        .max-w-md {
            max-width: 100%;
        }
    }
</style>

<script>
    // Avatar preview functionality
    const avatarInput = document.getElementById('avatar');
    const avatarPreview = document.getElementById('avatarPreview');
    const fileInputLabel = document.querySelector('label[for="avatar"]');

    avatarInput.addEventListener('change', function(e) {
        const file = e.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = function(e) {
                avatarPreview.innerHTML = `<img src="${e.target.result}" alt="Avatar preview" class="w-full h-full object-cover">`;
            };
            reader.readAsDataURL(file);
            fileInputLabel.textContent = file.name;
        }
    });

    // Form submission with loading state
    const form = document.getElementById('profileForm');
    const submitButton = document.getElementById('submitButton');

    form.addEventListener('submit', function(e) {
        // Show loading state
        submitButton.disabled = true;
        submitButton.textContent = 'Updating...';
        
        // Re-enable after a delay if form doesn't actually submit
        setTimeout(() => {
            if (submitButton.disabled) {
                submitButton.disabled = false;
                submitButton.textContent = 'Update Profile';
            }
        }, 5000);
    });

    // Smooth focus transitions
    const inputs = document.querySelectorAll('input[type="text"], input[type="email"], input[type="tel"]');
    inputs.forEach(input => {
        input.addEventListener('focus', function() {
            this.parentElement.style.transform = 'translateY(-2px)';
        });
        
        input.addEventListener('blur', function() {
            this.parentElement.style.transform = 'translateY(0)';
        });
    });
</script>
@endsection