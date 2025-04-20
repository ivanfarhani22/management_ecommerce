<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Digital Imam Store</title>
    
    <!-- CSRF Token -->
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <!-- Styles -->
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    
    <!-- Scripts -->
    <script src="{{ asset('js/app.js') }}" defer></script>
</head>
<body class="bg-gradient-to-br from-gray-50 to-gray-100 min-h-screen flex flex-col">
    <div id="app" class="flex-grow">
        <nav class="bg-white shadow-lg border-b border-gray-200">
            <div class="container mx-auto px-6 py-4 flex justify-between items-center">
                <a href="{{ route('home') }}" class="text-3xl font-extrabold text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 transition duration-300">
                    Imam Store
                </a>
                
                <div class="flex items-center space-x-6">
                    @guest
                        <a href="{{ route('login') }}" class="text-gray-700 font-medium hover:text-blue-600 transition duration-200 ease-in-out transform hover:-translate-y-0.5">
                            Login
                        </a>
                        <a href="{{ route('register') }}" class="bg-gradient-to-r from-blue-500 to-purple-600 text-white px-5 py-2 rounded-full shadow-md hover:shadow-xl transition duration-300 ease-in-out hover:scale-105">
                            Register
                        </a>
                    @else
                        <div class="flex items-center space-x-4">
                            <a href="{{ route('cart.index') }}" class="text-gray-700 hover:text-blue-600 transition duration-200 flex items-center">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
                                </svg>
                                Cart
                            </a>
                            <a href="{{ route('profile.index') }}" class="text-gray-700 hover:text-blue-600 transition duration-200 flex items-center">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                </svg>
                                Profile
                            </a>
                            <form action="{{ route('logout') }}" method="POST" class="inline">
                                @csrf
                                <button type="submit" class="text-red-500 hover:text-red-700 transition duration-200 flex items-center">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                                    </svg>
                                    Logout
                                </button>
                            </form>
                        </div>
                    @endguest
                </div>
            </div>
        </nav>

        <main class="container mx-auto px-6 py-8 flex-grow">
            <div class="bg-white shadow-xl rounded-lg p-6 min-h-[calc(100vh-300px)]">
                @yield('content')
            </div>
        </main>

        <footer class="bg-white shadow-md mt-8 border-t border-gray-200">
            <div class="container mx-auto px-6 py-6 text-center">
                <p class="text-gray-600 text-sm">
                    &copy; {{ date('Y') }} {{ config('app.name') }}. 
                    <span class="text-gray-500">All rights reserved.</span>
                </p>
                <div class="mt-4 flex justify-center space-x-4 text-gray-500">
                    <a href="#" class="hover:text-blue-600 transition duration-200">Privacy Policy</a>
                    <a href="#" class="hover:text-blue-600 transition duration-200">Terms of Service</a>
                    <a href="#" class="hover:text-blue-600 transition duration-200">Contact Us</a>
                </div>
            </div>
        </footer>
    </div>
</body>
</html>