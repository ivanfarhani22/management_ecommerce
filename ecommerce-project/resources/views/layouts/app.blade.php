<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Digital Ecommerce</title>
    
    <!-- CSRF Token -->
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <!-- Styles -->
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    
    <!-- Scripts -->
    <script src="{{ asset('js/app.js') }}" defer></script>
    <script src="{{ asset('js/chatbot.js') }}" defer></script>
    
    <style>
        body { font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif; }
        .announcement-slider { animation: slideText 20s linear infinite; }
        @keyframes slideText {
            0% { transform: translateX(100%); }
            100% { transform: translateX(-100%); }
        }
        
        /* Menghilangkan border biru default saat diklik/focus */
        *:focus {
            outline: none !important;
            box-shadow: none !important;
        }
        
        /* Custom focus styles yang lebih subtle */
        input:focus,
        button:focus,
        select:focus,
        textarea:focus {
            outline: none !important;
            border-color: #374151 !important;
            box-shadow: 0 0 0 1px #374151 !important;
        }
    </style>
</head>
<body class="bg-white text-gray-900 antialiased font-light">
    <div id="app" class="min-h-screen flex flex-col">
        <!-- Top Bar -->
        <div class="bg-black border-b border-gray-800 text-white py-2 text-xs">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div class="flex items-center justify-between">
                    <!-- Left side -->
                    <div class="flex items-center space-x-4">
                        <div class="flex items-center space-x-2">
                            <svg class="w-4 h-4 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 8v4.5m0 0l3-3m-3 3l-3-3M12 21a9 9 0 100-18 9 9 0 000 18z"/>
                            </svg>
                            <span class="text-gray-300">Welcome to Digital Ecommerce</span>
                        </div>
                        <div class="hidden md:block text-gray-400">|</div>
                        <div class="hidden md:flex items-center space-x-1 overflow-hidden">
                            <svg class="w-4 h-4 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M7 4V2a1 1 0 011-1h8a1 1 0 011 1v2m-9 0h10a2 2 0 012 2v10a2 2 0 01-2 2H6a2 2 0 01-2-2V6a2 2 0 012-2z"/>
                            </svg>
                            <span class="text-gray-300 whitespace-nowrap announcement-slider">
                                Free shipping on orders over $50 • New arrivals every week • 24/7 customer support
                            </span>
                        </div>
                    </div>
                    
                    <!-- Right side -->
                    <div class="flex items-center space-x-4">
                        <div class="hidden lg:flex items-center space-x-4 text-xs">
                            <a href="tel:+1234567890" class="text-gray-300 hover:text-white transition-colors duration-300 flex items-center space-x-1">
                                <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"/>
                                </svg>
                                <span>+1 (234) 567-890</span>
                            </a>
                            <a href="mailto:support@digitalecommerce.com" class="text-gray-300 hover:text-white transition-colors duration-300 flex items-center space-x-1">
                                <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                                </svg>
                                <span>support@digitalecommerce.com</span>
                            </a>
                        </div>
                        <div class="flex items-center space-x-2">
                            <a href="#" class="text-gray-300 hover:text-white transition-colors duration-300">
                                <i class="fab fa-twitter text-sm"></i>
                            </a>
                            <a href="#" class="text-gray-300 hover:text-white transition-colors duration-300">
                                <i class="fab fa-facebook-f text-sm"></i>
                            </a>
                            <a href="#" class="text-gray-300 hover:text-white transition-colors duration-300">
                                <i class="fab fa-github text-sm"></i>
                            </a>
                            <a href="#" class="text-gray-300 hover:text-white transition-colors duration-300">
                                <i class="fab fa-instagram text-sm"></i>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Navigation -->
        <nav class="bg-white border-b border-gray-100 shadow-sm sticky top-0 z-50">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div class="flex justify-between items-center h-16">
                    <!-- Logo -->
                    <div class="flex-shrink-0">
                        <a href="{{ route('home') }}" class="text-2xl font-light text-black tracking-tight hover:text-gray-700 transition duration-300">
                            Digital Ecommerce
                        </a>
                    </div>
                    
                    <!-- Search Bar (Desktop) -->
                    <div class="hidden md:flex flex-1 max-w-lg mx-8">
                        <div class="relative w-full max-w-md">
                            <form action="{{ route('products.index') }}" method="GET" id="search-form">
                                <input 
                                    type="text" 
                                    name="search" 
                                    id="search-input"
                                    class="w-full py-2.5 pl-12 pr-4 text-sm border border-gray-200 rounded-lg bg-gray-50 focus:outline-none focus:ring-2 focus:ring-black focus:border-black focus:bg-white transition-all duration-300" 
                                    placeholder="Search for products..."
                                    autocomplete="off"
                                    value="{{ request('search') }}"
                                >
                                <svg class="w-4 h-4 absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                                </svg>
                            </form>
                            <!-- Search Results -->
                            <div id="search-results" class="hidden absolute top-full left-0 right-0 bg-white border border-gray-200 border-t-0 rounded-b-lg max-h-80 overflow-y-auto z-50 shadow-lg"></div>
                        </div>
                    </div>
                    
                    <!-- Navigation Links -->
                    <div class="hidden md:flex items-center space-x-8">
                        @guest
                            <a href="{{ route('login') }}" class="text-gray-600 hover:text-black transition-colors duration-300 text-sm">Login</a>
                            <a href="{{ route('register') }}" class="bg-black text-white px-6 py-2 rounded text-sm hover:bg-gray-800 transition-colors duration-300">Register</a>
                        @else
                           <div class="flex items-center gap-x-6">
                            <!-- Cart -->
                            <a href="{{ route('cart.index') }}" class="flex items-center text-sm text-gray-600 hover:text-black transition-colors duration-300 gap-x-1">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                                        d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17M17 17a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
                                </svg>
                                <span>Cart</span>
                            </a>

                            <!-- Profile -->
                            <a href="{{ route('profile.index') }}" class="flex items-center text-sm text-gray-600 hover:text-black transition-colors duration-300 gap-x-1">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                                </svg>
                                <span>Profile</span>
                            </a>

                            <!-- Logout -->
                            <form action="{{ route('logout') }}" method="POST" class="inline">
                                @csrf
                                <button type="submit" class="flex items-center text-sm text-gray-600 hover:text-black transition-colors duration-300 gap-x-1">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                                            d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                                    </svg>
                                    <span>Logout</span>
                                </button>
                            </form>
                        </div>
                        @endguest
                    </div>
                    
                    <!-- Mobile menu button -->
                    <button class="md:hidden text-gray-600 hover:text-black transition-colors duration-300" onclick="toggleMobileMenu()">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4 6h16M4 12h16M4 18h16"/>
                        </svg>
                    </button>
                </div>
                
                <!-- Mobile Search Bar -->
                <div class="md:hidden pb-4">
                    <div class="relative max-w-md mx-4">
                        <form action="{{ route('products.index') }}" method="GET" id="mobile-search-form">
                            <input 
                                type="text" 
                                name="search" 
                                id="mobile-search-input"
                                class="w-full py-2.5 pl-12 pr-4 text-sm border border-gray-200 rounded-lg bg-gray-50 focus:outline-none focus:ring-2 focus:ring-black focus:border-black focus:bg-white transition-all duration-300" 
                                placeholder="Search for products..."
                                autocomplete="off"
                                value="{{ request('search') }}"
                            >
                            <svg class="w-4 h-4 absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                            </svg>
                        </form>
                        <div id="mobile-search-results" class="hidden absolute top-full left-0 right-0 bg-white border border-gray-200 border-t-0 rounded-b-lg max-h-80 overflow-y-auto z-50 shadow-lg"></div>
                    </div>
                </div>
                
                <!-- Mobile Navigation -->
                <div class="md:hidden hidden border-t border-gray-100" id="mobile-menu">
                    <div class="px-2 pt-2 pb-3 space-y-1">
                        @guest
                            <a href="{{ route('login') }}" class="block px-3 py-2 text-gray-600 hover:text-black transition-colors duration-300 text-sm">Login</a>
                            <a href="{{ route('register') }}" class="block px-3 py-2 text-gray-600 hover:text-black transition-colors duration-300 text-sm">Register</a>
                        @else
                            <a href="{{ route('cart.index') }}" class="block px-3 py-2 text-gray-600 hover:text-black transition-colors duration-300 text-sm">Cart</a>
                            <a href="{{ route('profile.index') }}" class="block px-3 py-2 text-gray-600 hover:text-black transition-colors duration-300 text-sm">Profile</a>
                            <form action="{{ route('logout') }}" method="POST" class="block">
                                @csrf
                                <button type="submit" class="w-full text-left px-3 py-2 text-gray-600 hover:text-black transition-colors duration-300 text-sm">Logout</button>
                            </form>
                        @endguest
                    </div>
                </div>
            </div>
        </nav>

        <!-- Main Content -->
        <main class="flex-1">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 lg:py-12">
                <!-- Back Button -->
                @if(View::hasSection('show_back_button'))
                    <div class="mb-8">
                        <button onclick="window.history.back()" class="flex items-center text-gray-600 hover:text-black transition-colors duration-300 text-sm">
                            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M10 19l-7-7m0 0l7-7m-7 7h18"/>
                            </svg>
                            Back
                        </button>
                    </div>
                @endif
                
                <!-- Content Area -->
                <div class="bg-white min-h-96">
                    @yield('content')
                </div>
            </div>
        </main>

        <!-- Chatbot Button -->
        <div id="chatbot-button" class="fixed bottom-6 right-6 w-14 h-14 bg-black hover:bg-gray-800 hover:scale-105 transition-all duration-300 rounded-full flex items-center justify-center cursor-pointer shadow-lg z-50">
            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"/>
            </svg>
        </div>

        <!-- Chatbot Container -->
        <div id="chatbot-container" class="fixed bottom-24 right-6 w-80 md:w-96 bg-white rounded-lg shadow-xl overflow-hidden hidden z-50 border border-gray-100">
            <!-- Chatbot Header -->
            <div class="bg-black text-white p-4 flex justify-between items-center">
                <div class="flex items-center space-x-2">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/>
                    </svg>
                    <h3 class="font-medium text-sm">Shop Assistant</h3>
                </div>
                <button id="chatbot-close" class="text-white hover:text-gray-300 transition-colors duration-300">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M6 18L18 6M6 6l12 12"/>
                    </svg>
                </button>
            </div>
            
            <!-- Chatbot Messages -->
            <div id="chatbot-messages" class="h-80 p-4 overflow-y-auto bg-gray-50"></div>
            
            <!-- Quick Reply Options -->
            <div class="px-4 py-3 bg-white border-t border-gray-100 flex overflow-x-auto space-x-2">
                <button class="chatbot-quick-reply text-xs bg-gray-100 hover:bg-gray-200 border border-gray-200 hover:border-gray-300 text-gray-600 hover:text-gray-700 transition-all duration-200 rounded-full px-3 py-1 whitespace-nowrap">Products</button>
                <button class="chatbot-quick-reply text-xs bg-gray-100 hover:bg-gray-200 border border-gray-200 hover:border-gray-300 text-gray-600 hover:text-gray-700 transition-all duration-200 rounded-full px-3 py-1 whitespace-nowrap">Categories</button>
                <button class="chatbot-quick-reply text-xs bg-gray-100 hover:bg-gray-200 border border-gray-200 hover:border-gray-300 text-gray-600 hover:text-gray-700 transition-all duration-200 rounded-full px-3 py-1 whitespace-nowrap">Orders</button>
                <button class="chatbot-quick-reply text-xs bg-gray-100 hover:bg-gray-200 border border-gray-200 hover:border-gray-300 text-gray-600 hover:text-gray-700 transition-all duration-200 rounded-full px-3 py-1 whitespace-nowrap">Shipping info</button>
                <button class="chatbot-quick-reply text-xs bg-gray-100 hover:bg-gray-200 border border-gray-200 hover:border-gray-300 text-gray-600 hover:text-gray-700 transition-all duration-200 rounded-full px-3 py-1 whitespace-nowrap">Return policy</button>
            </div>
            
            <!-- Chatbot Input -->
            <div class="p-4 border-t border-gray-100 bg-white">
                <div class="flex space-x-2">
                    <input 
                        id="chatbot-input" 
                        type="text" 
                        placeholder="Type your message..." 
                        class="flex-grow px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-gray-300 focus:border-gray-300 text-sm"
                    >
                    <button id="chatbot-send" class="bg-black text-white px-4 py-2 rounded-lg hover:bg-gray-800 transition-colors duration-300">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"/>
                        </svg>
                    </button>
                </div>
            </div>
        </div>

        <!-- Footer -->
        <footer class="bg-white border-t border-gray-100 mt-16">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                <div class="text-center">
                    <p class="text-gray-500 text-sm mb-4">
                        &copy; {{ date('Y') }} {{ config('app.name') }}. All rights reserved.
                    </p>
                    <div class="flex justify-center space-x-6 text-sm">
                        <a href="#" class="text-gray-400 hover:text-gray-600 transition-colors duration-300">Privacy Policy</a>
                        <a href="#" class="text-gray-400 hover:text-gray-600 transition-colors duration-300">Terms of Service</a>
                        <a href="#" class="text-gray-400 hover:text-gray-600 transition-colors duration-300">Contact Us</a>
                    </div>
                </div>
            </div>
        </footer>
    </div>

    <script>
        // Mobile menu toggle
        function toggleMobileMenu() {
            const mobileMenu = document.getElementById('mobile-menu');
            mobileMenu.classList.toggle('hidden');
        }

        // Search functionality - FIXED VERSION
        document.addEventListener('DOMContentLoaded', function() {
            const searchInput = document.getElementById('search-input');
            const mobileSearchInput = document.getElementById('mobile-search-input');
            const searchResults = document.getElementById('search-results');
            const mobileSearchResults = document.getElementById('mobile-search-results');
            let searchTimeout;

            function performSearch(query, resultsContainer) {
                if (query.length < 2) {
                    resultsContainer.classList.add('hidden');
                    return;
                }

                fetch(`/api/v1/products?search=${encodeURIComponent(query)}&limit=5`, {
                    method: 'GET',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                    }
                })
                .then(response => response.json())
                .then(data => {
                    // Menyesuaikan dengan struktur JSON yang benar
                    const products = data.products || data.data || [];
                    displaySearchResults(products, resultsContainer);
                })
                .catch(error => {
                    console.error('Search error:', error);
                    resultsContainer.classList.add('hidden');
                });
            }

            function displaySearchResults(products, container) {
                if (products.length === 0) {
                    container.innerHTML = '<div class="p-4 text-center text-gray-500 text-sm">No products found</div>';
                    container.classList.remove('hidden');
                    return;
                }

                const resultsHTML = products.map(product => `
                    <div class="p-3 border-b border-gray-100 hover:bg-gray-50 cursor-pointer transition-colors duration-200 last:border-b-0" onclick="window.location.href='{{ route('products.detail', '') }}/${product.id}'">
                        <div class="font-normal text-gray-800 text-sm mb-1">${product.name}</div>
                        <div class="text-xs text-gray-500">Rp${parseFloat(product.price).toLocaleString()}</div>
                    </div>
                `).join('');

                container.innerHTML = resultsHTML;
                container.classList.remove('hidden');
            }

            // Desktop search
            if (searchInput) {
                searchInput.addEventListener('input', function() {
                    clearTimeout(searchTimeout);
                    const query = this.value.trim();
                    
                    searchTimeout = setTimeout(() => {
                        performSearch(query, searchResults);
                    }, 300);
                });

                document.addEventListener('click', function(e) {
                    if (!searchInput.contains(e.target) && !searchResults.contains(e.target)) {
                        searchResults.classList.add('hidden');
                    }
                });
            }

            // Mobile search
            if (mobileSearchInput) {
                mobileSearchInput.addEventListener('input', function() {
                    clearTimeout(searchTimeout);
                    const query = this.value.trim();
                    
                    searchTimeout = setTimeout(() => {
                        performSearch(query, mobileSearchResults);
                    }, 300);
                });

                document.addEventListener('click', function(e) {
                    if (!mobileSearchInput.contains(e.target) && !mobileSearchResults.contains(e.target)) {
                        mobileSearchResults.classList.add('hidden');
                    }
                });
            }
        });

        // Chatbot functionality
        document.addEventListener('DOMContentLoaded', function() {
            const chatbotButton = document.getElementById('chatbot-button');
            const chatbotContainer = document.getElementById('chatbot-container');
            const chatbotClose = document.getElementById('chatbot-close');
            const chatbotMessages = document.getElementById('chatbot-messages');
            const chatbotInput = document.getElementById('chatbot-input');
            const chatbotSend = document.getElementById('chatbot-send');
            const quickReplyButtons = document.querySelectorAll('.chatbot-quick-reply');

            let chatInitialized = false;

            chatbotButton.addEventListener('click', function() {
                chatbotContainer.classList.toggle('hidden');
                if (!chatInitialized && !chatbotContainer.classList.contains('hidden')) {
                    initializeChat();
                    chatInitialized = true;
                }
            });

            chatbotClose.addEventListener('click', function() {
                chatbotContainer.classList.add('hidden');
            });

            function initializeChat() {
                addMessage('Hello! I\'m your shopping assistant. How can I help you today?', 'bot');
            }

            function addMessage(text, sender) {
                const messageDiv = document.createElement('div');
                messageDiv.classList.add('mb-3');
                
                if (sender === 'bot') {
                    messageDiv.innerHTML = `
                        <div class="bg-white p-3 rounded-lg shadow-sm inline-block max-w-xs">
                            <p class="text-sm text-gray-700">${text}</p>
                        </div>
                    `;
                } else {
                    messageDiv.innerHTML = `
                        <div class="flex justify-end">
                            <div class="bg-black text-white p-3 rounded-lg inline-block max-w-xs">
                                <p class="text-sm">${text}</p>
                            </div>
                        </div>
                    `;
                }
                
                chatbotMessages.appendChild(messageDiv);
                chatbotMessages.scrollTop = chatbotMessages.scrollHeight;
            }

            function sendMessage() {
                const message = chatbotInput.value.trim();
                if (message === '') return;

                addMessage(message, 'user');
                chatbotInput.value = '';

                // Simulate bot response
                setTimeout(() => {
                    const responses = {
                        'products': 'We have a wide range of products including electronics, clothing, home & garden, and more. What are you looking for?',
                        'categories': 'Our main categories include: Electronics, Fashion, Home & Garden, Sports, Books, and Beauty. Which one interests you?',
                        'orders': 'You can view your order history in your profile page. Would you like me to guide you there?',
                        'shipping info': 'We offer free shipping on orders over $50. Standard delivery takes 3-5 business days, express delivery 1-2 days.',
                        'return policy': 'We accept returns within 30 days of purchase. Items must be in original condition. Would you like more details?',
                        'hello': 'Hello! How can I assist you with your shopping today?',
                        'hi': 'Hi there! What can I help you find?',
                        'help': 'I can help you with product information, order status, shipping details, and more. What do you need help with?'
                    };

                    let botResponse = responses[message.toLowerCase()] || 
                        'I understand you\'re asking about "' + message + '". Let me help you with that. Could you be more specific?';
                    
                    addMessage(botResponse, 'bot');
                }, 1000);
            }

            chatbotSend.addEventListener('click', sendMessage);
            
            chatbotInput.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    sendMessage();
                }
            });

            // Quick reply buttons
            quickReplyButtons.forEach(button => {
                button.addEventListener('click', function() {
                    const text = this.textContent;
                    chatbotInput.value = text;
                    sendMessage();
                });
            });
        });

        // Auto-hide search results when clicking outside
        document.addEventListener('click', function(e) {
            const searchInput = document.getElementById('search-input');
            const mobileSearchInput = document.getElementById('mobile-search-input');
            const searchResults = document.getElementById('search-results');
            const mobileSearchResults = document.getElementById('mobile-search-results');
            
            if (searchInput && searchResults && !searchInput.contains(e.target) && !searchResults.contains(e.target)) {
                searchResults.classList.add('hidden');
            }
            
            if (mobileSearchInput && mobileSearchResults && !mobileSearchInput.contains(e.target) && !mobileSearchResults.contains(e.target)) {
                mobileSearchResults.classList.add('hidden');
            }
        });

        // Form submission handling
        document.addEventListener('DOMContentLoaded', function() {
            const searchForm = document.getElementById('search-form');
            const mobileSearchForm = document.getElementById('mobile-search-form');
            
            if (searchForm) {
                searchForm.addEventListener('submit', function(e) {
                    const searchInput = document.getElementById('search-input');
                    if (searchInput.value.trim() === '') {
                        e.preventDefault();
                    }
                });
            }
            
            if (mobileSearchForm) {
                mobileSearchForm.addEventListener('submit', function(e) {
                    const mobileSearchInput = document.getElementById('mobile-search-input');
                    if (mobileSearchInput.value.trim() === '') {
                        e.preventDefault();
                    }
                });
            }
        });

        // Smooth scroll for anchor links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });

        // Loading state for forms
        document.addEventListener('DOMContentLoaded', function() {
            const forms = document.querySelectorAll('form[method="POST"]');
            forms.forEach(form => {
                form.addEventListener('submit', function() {
                    const submitButton = form.querySelector('button[type="submit"]');
                    if (submitButton) {
                        submitButton.disabled = true;
                        const originalText = submitButton.textContent;
                        submitButton.textContent = 'Loading...';
                        
                        setTimeout(() => {
                            submitButton.disabled = false;
                            submitButton.textContent = originalText;
                        }, 3000);
                    }
                });
            });
        });

        // Toast notification system
        function showToast(message, type = 'info') {
            const toast = document.createElement('div');
            toast.className = `fixed top-4 right-4 z-50 px-6 py-3 rounded-lg shadow-lg text-white text-sm transition-all duration-300 transform translate-x-full`;
            
            switch(type) {
                case 'success':
                    toast.classList.add('bg-green-500');
                    break;
                case 'error':
                    toast.classList.add('bg-red-500');
                    break;
                case 'warning':
                    toast.classList.add('bg-yellow-500');
                    break;
                default:
                    toast.classList.add('bg-blue-500');
            }
            
            toast.textContent = message;
            document.body.appendChild(toast);
            
            setTimeout(() => {
                toast.classList.remove('translate-x-full');
            }, 100);
            
            setTimeout(() => {
                toast.classList.add('translate-x-full');
                setTimeout(() => {
                    document.body.removeChild(toast);
                }, 300);
            }, 3000);
        }

        // Image lazy loading
        document.addEventListener('DOMContentLoaded', function() {
            const images = document.querySelectorAll('img[data-src]');
            const imageObserver = new IntersectionObserver((entries, observer) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        const img = entry.target;
                        img.src = img.dataset.src;
                        img.classList.remove('lazy');
                        imageObserver.unobserve(img);
                    }
                });
            });

            images.forEach(img => imageObserver.observe(img));
        });

        // Keyboard navigation for accessibility
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                // Close mobile menu
                const mobileMenu = document.getElementById('mobile-menu');
                if (mobileMenu && !mobileMenu.classList.contains('hidden')) {
                    mobileMenu.classList.add('hidden');
                }
                
                // Close chatbot
                const chatbotContainer = document.getElementById('chatbot-container');
                if (chatbotContainer && !chatbotContainer.classList.contains('hidden')) {
                    chatbotContainer.classList.add('hidden');
                }
                
                // Hide search results
                const searchResults = document.getElementById('search-results');
                const mobileSearchResults = document.getElementById('mobile-search-results');
                if (searchResults) searchResults.classList.add('hidden');
                if (mobileSearchResults) mobileSearchResults.classList.add('hidden');
            }
        });

        // Price formatting
        function formatPrice(price) {
            return new Intl.NumberFormat('en-US', {
                style: 'currency',
                currency: 'USD'
            }).format(price);
        }

        // Quantity input validation
        document.addEventListener('DOMContentLoaded', function() {
            const quantityInputs = document.querySelectorAll('input[type="number"][name*="quantity"]');
            quantityInputs.forEach(input => {
                input.addEventListener('change', function() {
                    const min = parseInt(this.min) || 1;
                    const max = parseInt(this.max) || 999;
                    let value = parseInt(this.value) || min;
                    
                    if (value < min) value = min;
                    if (value > max) value = max;
                    
                    this.value = value;
                });
            });
        });

        // Cart update functionality
        function updateCartQuantity(productId, quantity) {
            fetch('/cart/update', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                },
                body: JSON.stringify({
                    product_id: productId,
                    quantity: quantity
                })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showToast('Cart updated successfully', 'success');
                    location.reload();
                } else {
                    showToast('Failed to update cart', 'error');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                showToast('An error occurred', 'error');
            });
        }

        // Add to cart functionality
        function addToCart(productId, quantity = 1) {
            fetch('/cart/add', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                },
                body: JSON.stringify({
                    product_id: productId,
                    quantity: quantity
                })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showToast('Product added to cart', 'success');
                } else {
                    showToast(data.message || 'Failed to add product to cart', 'error');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                showToast('An error occurred', 'error');
            });
        }

        // Wishlist functionality
        function toggleWishlist(productId) {
            fetch('/wishlist/toggle', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                },
                body: JSON.stringify({
                    product_id: productId
                })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    const icon = document.querySelector(`[data-wishlist="${productId}"]`);
                    if (icon) {
                        icon.classList.toggle('text-red-500');
                        icon.classList.toggle('text-gray-400');
                    }
                    showToast(data.message, 'success');
                } else {
                    showToast(data.message || 'Failed to update wishlist', 'error');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                showToast('An error occurred', 'error');
            });
        }
    </script>

    <!-- Additional Scripts -->
    @stack('scripts')
</body>
</html>