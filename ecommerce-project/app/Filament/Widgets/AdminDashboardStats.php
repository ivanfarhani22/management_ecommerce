<?php

namespace App\Filament\Widgets;

use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class AdminDashboardStats extends StatsOverviewWidget
{
    protected function getStats(): array
    {
        // Recent orders count (last 30 days)
        $recentOrders = Order::where('created_at', '>=', now()->subDays(30))->count();

        // Total revenue
        $totalRevenue = Order::where('status', 'paid')
            ->sum('total_amount');
        
        // Total revenue this month
        $revenueThisMonth = Order::where('status', 'paid')
            ->whereMonth('created_at', now()->month)
            ->whereYear('created_at', now()->year)
            ->sum('total_amount');
        
        // Revenue growth calculation
        $lastMonthRevenue = Order::where('status', 'paid')
            ->whereMonth('created_at', now()->subMonth()->month)
            ->whereYear('created_at', now()->subMonth()->year)
            ->sum('total_amount');
        
        $growthPercentage = $lastMonthRevenue > 0 
            ? round((($revenueThisMonth - $lastMonthRevenue) / $lastMonthRevenue) * 100, 1)
            : 100;
        
        $growthDescription = $growthPercentage >= 0 
            ? "+{$growthPercentage}% dari bulan lalu" 
            : "{$growthPercentage}% dari bulan lalu";

        // Total users
        $totalUsers = User::count();
        $newUsers = User::where('created_at', '>=', now()->subDays(30))->count();
        $userGrowth = $newUsers > 0 ? "{$newUsers} baru dalam 30 hari" : "Tidak ada pengguna baru";

        // Low stock products
        $lowStockProducts = Product::where('stock', '<', 10)
            ->where('is_active', true)
            ->count();
            
        // Get actual sales data for charts
        $salesData = $this->getSalesChartData();
        $orderData = $this->getOrdersChartData();
        $userGrowthData = $this->getUserGrowthData();

        return [
            Stat::make('Total Pendapatan', 'Rp ' . number_format($totalRevenue, 0, ',', '.'))
                ->description('Total dari pesanan yang dibayar')
                ->descriptionIcon('heroicon-o-currency-dollar')
                ->chart($salesData)
                ->color('success'),

            Stat::make('Pendapatan Bulan Ini', 'Rp ' . number_format($revenueThisMonth, 0, ',', '.'))
                ->description($growthDescription)
                ->descriptionIcon($growthPercentage >= 0 ? 'heroicon-o-arrow-trending-up' : 'heroicon-o-arrow-trending-down')
                ->chart($salesData)
                ->color($growthPercentage >= 0 ? 'success' : 'danger'),

            Stat::make('Pesanan Terbaru', $recentOrders)
                ->description('30 hari terakhir')
                ->descriptionIcon('heroicon-o-shopping-cart')
                ->chart($orderData)
                ->color('primary'),

            Stat::make('Total Pengguna', $totalUsers)
                ->description($userGrowth)
                ->descriptionIcon('heroicon-o-users')
                ->chart($userGrowthData)
                ->color('secondary'),

            Stat::make('Produk Stok Menipis', $lowStockProducts)
                ->description('Item dengan stok < 10')
                ->descriptionIcon('heroicon-o-exclamation-circle')
                ->chart($lowStockProducts > 0 ? [8, 7, 6, 5, 4, 3, 2] : [2, 3, 4, 5, 6, 7, 8])
                ->color($lowStockProducts > 0 ? 'danger' : 'success'),
        ];
    }
    
    // Generate real sales data for the chart
    protected function getSalesChartData(): array
    {
        $data = [];
        
        // Get daily sales for the past 7 days
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i);
            
            $dailySales = Order::where('status', 'paid')
                ->whereDate('created_at', $date)
                ->sum('total_amount');
                
            // Convert to a value between 0-100 for the chart
            $scaledValue = $dailySales > 0 ? min(100, $dailySales / 1000) : 0;
            $data[] = $scaledValue;
        }
        
        return $data;
    }
    
    // Generate orders data for the chart
    protected function getOrdersChartData(): array
    {
        $data = [];
        
        // Get daily orders for the past 7 days
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i);
            
            $dailyOrders = Order::whereDate('created_at', $date)->count();
            
            // Convert to a value between 0-100 for the chart
            $scaledValue = $dailyOrders > 0 ? min(100, $dailyOrders * 5) : 0;
            $data[] = $scaledValue;
        }
        
        return $data;
    }
    
    // Generate user growth data for the chart
    protected function getUserGrowthData(): array
    {
        $data = [];
        
        // Get daily new users for the past 7 days
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i);
            
            $dailyUsers = User::whereDate('created_at', $date)->count();
            
            // Convert to a value between 0-100 for the chart
            $scaledValue = $dailyUsers > 0 ? min(100, $dailyUsers * 10) : 0;
            $data[] = $scaledValue;
        }
        
        return $data;
    }
}