<?php

namespace App\Filament\Pages;

use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use App\Filament\Widgets\AdminLatestOrders;
use App\Filament\Widgets\AdminPopularProducts;
use App\Filament\Widgets\AdminMonthlySalesChart;
use App\Filament\Widgets\AdminCategoryDistribution;
use App\Filament\Widgets\AdminPaymentMethodsChart;
use App\Filament\Widgets\AdminDashboardStats;
use Filament\Actions\Action;
use Filament\Pages\Dashboard;

class AdminDashboard extends Dashboard
{
    // Set max width to improve readability on large screens
    protected ?string $maxContentWidth = 'max-w-7xl';
    
    // This sets the correct navigation label
    protected static ?string $navigationLabel = 'Dashboard';
    
    // This is the route name - ensure it matches your panel configuration
    protected static string $routeName = 'filament.admin.pages.dashboard';
    
    // Add an icon for the dashboard
    public static function getNavigationIcon(): string
    {
        return 'heroicon-o-home';
    }

    // Add a badge showing pending orders count
    public static function getNavigationBadge(): ?string
    {
        // Get count of new orders
        $newOrdersCount = Order::where('status', 'pending')->count();
        
        return $newOrdersCount > 0 ? $newOrdersCount : null;
    }
    
    public static function getNavigationBadgeColor(): ?string
    {
        return 'warning';
    }

    protected function getHeaderActions(): array
    {
        return [
            Action::make('view_store')
                ->label('Lihat Toko')
                ->url(route('home'))
                ->icon('heroicon-o-shopping-bag')
                ->color('success')
                ->button()
                ->openUrlInNewTab(),
                
            Action::make('refresh')
                ->label('Refresh Data')
                ->icon('heroicon-o-arrow-path')
                ->action(fn () => $this->refresh())
                ->color('gray'),
        ];
    }

    protected function getHeaderWidgets(): array
    {
        return [
            AdminDashboardStats::class,
        ];
    }

    public function getWidgets(): array
    {
        return [
            AdminMonthlySalesChart::class,
            AdminLatestOrders::class,
            AdminPopularProducts::class,
            AdminCategoryDistribution::class,
            AdminPaymentMethodsChart::class,
        ];
    }
}