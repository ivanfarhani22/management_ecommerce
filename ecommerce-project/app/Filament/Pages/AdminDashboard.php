<?php

namespace App\Filament\Pages;

use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use Filament\Actions\Action;
use Filament\Pages\Dashboard;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Filament\Widgets\StatsOverviewWidget;

class AdminDashboard extends Dashboard
{
    // This sets the correct navigation label
    protected static ?string $navigationLabel = 'Dashboard';
    
    // This is important! It sets the correct route identifier
    protected static string $routeName = 'filament.admin.pages.dashboard';
    
    // Override the getNavigationIcon method to customize the icon
    public static function getNavigationIcon(): string
    {
        return 'heroicon-o-home';
    }

    protected function getHeaderActions(): array
    {
        return [
            Action::make('view_store')
                ->label('View Store')
                ->url(route('home'))
                ->icon('heroicon-o-shopping-bag')
                ->openUrlInNewTab(),
        ];
    }

    protected function getHeaderWidgets(): array
    {
        return [
            AdminDashboardStats::class,
        ];
    }
}

class AdminDashboardStats extends StatsOverviewWidget
{
    protected function getStats(): array
    {
        // Recent orders count (last 30 days)
        $recentOrders = Order::where('created_at', '>=', now()->subDays(30))->count();

        // Total revenue - fix for the error
        // Option 1: If "paid" status is stored in the orders table
        $totalRevenue = Order::where('status', 'paid')
            ->sum('total_amount');
        
        // Option 2: If you need to check through payment relationship
        // $totalRevenue = Order::whereHas('payment', function($query) {
        //     $query->where('status', 'paid');
        // })->sum('total_amount');

        // Total users
        $totalUsers = User::count();

        // Low stock products
        $lowStockProducts = Product::where('stock', '<', 10)
            ->where('is_active', true)
            ->count();

        return [
            Stat::make('Total Revenue', 'Rp ' . number_format($totalRevenue, 0, ',', '.'))
                ->description('Total from paid orders')
                ->descriptionIcon('heroicon-o-currency-dollar')
                ->chart([7, 2, 10, 3, 15, 4, 17])
                ->color('success'),

            Stat::make('Recent Orders', $recentOrders)
                ->description('Last 30 days')
                ->descriptionIcon('heroicon-o-shopping-cart')
                ->chart([15, 8, 12, 9, 7, 3, 5])
                ->color('primary'),

            Stat::make('Total Users', $totalUsers)
                ->description(User::where('created_at', '>=', now()->subDays(30))->count() . ' new in 30 days')
                ->descriptionIcon('heroicon-o-users')
                ->chart([8, 10, 12, 15, 16, 17, 18])
                ->color('secondary'),

            Stat::make('Low Stock Products', $lowStockProducts)
                ->description('Items with stock < 10')
                ->descriptionIcon('heroicon-o-exclamation-circle')
                ->color($lowStockProducts > 0 ? 'danger' : 'success'),
        ];
    }
}