<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin Dashboard | {{ config('app.name', 'E-Commerce Platform') }}</title>
    
    <!-- CSRF Token -->
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <!-- Styles -->
    <link href="{{ asset('css/app.css') }}" rel="stylesheet">
    
    <!-- Scripts -->
    <script src="{{ asset('js/app.js') }}" defer></script>
</head>
<body class="bg-gray-100">
    <div id="admin-app">
        <nav class="bg-indigo-700 text-white shadow-md">
            <div class="container mx-auto px-4 py-3 flex justify-between items-center">
                <a href="{{ route('admin.dashboard') }}" class="text-2xl font-bold">
                    Admin Dashboard
                </a>
                
                <div class="flex items-center space-x-4">
                    <a href="{{ route('admin.products') }}" class="hover:text-indigo-200">Products</a>
                    <a href="{{ route('admin.orders') }}" class="hover:text-indigo-200">Orders</a>
                    <a href="{{ route('admin.users') }}" class="hover:text-indigo-200">Users</a>
                    <form action="{{ route('logout') }}" method="POST" class="inline">
                        @csrf
                        <button type="submit" class="text-red-300 hover:text-red-100">Logout</button>
                    </form>
                </div>
            </div>
        </nav>

        <div class="flex">
            <aside class="w-64 bg-white shadow-md p-4">
                <ul>
                    <li class="mb-2"><a href="{{ route('admin.dashboard') }}" class="text-gray-700 hover:text-indigo-600">Dashboard</a></li>
                    <li class="mb-2"><a href="{{ route('admin.products') }}" class="text-gray-700 hover:text-indigo-600">Manage Products</a></li>
                    <li class="mb-2"><a href="{{ route('admin.orders') }}" class="text-gray-700 hover:text-indigo-600">Order Management</a></li>
                    <li class="mb-2"><a href="{{ route('admin.users') }}" class="text-gray-700 hover:text-indigo-600">User Management</a></li>
                    <li class="mb-2"><a href="{{ route('admin.reports') }}" class="text-gray-700 hover:text-indigo-600">Reports</a></li>
                </ul>
            </aside>

            <main class="flex-1 p-6">
                @yield('content')
            </main>
        </div>

        <footer class="bg-white shadow-md mt-6">
            <div class="container mx-auto px-4 py-4 text-center">
                <p>&copy; {{ date('Y') }} {{ config('app.name') }} Admin Panel</p>
            </div>
        </footer>
    </div>
</body>
</html>