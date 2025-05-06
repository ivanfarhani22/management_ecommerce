<?php

namespace App\Filament\Widgets;

use App\Models\Order;
use Filament\Widgets\ChartWidget;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class AdminMonthlySalesChart extends ChartWidget
{
    protected static ?string $heading = 'Penjualan Bulanan';
    
    protected static ?int $sort = 3;
    
    // Make widget wider
    protected int | string | array $columnSpan = 'full';
    
    // Add dropdown filter for timeframe
    protected function getFilters(): ?array
    {
        return [
            'all' => 'Semua Waktu',
            'year' => 'Tahun Ini',
            'quarter' => '3 Bulan Terakhir',
            'month' => 'Bulan Ini',
        ];
    }

    protected function getData(): array
    {
        $activeFilter = $this->filter ?? 'year';
        
        // Determine the start date based on the filter
        $startDate = match ($activeFilter) {
            'year' => now()->startOfYear(),
            'quarter' => now()->subMonths(3)->startOfMonth(),
            'month' => now()->startOfMonth(),
            default => now()->subYear()->startOfMonth(), // default to last 12 months
        };
        
        // Get monthly sales and order counts
        $data = Order::select(
                DB::raw('YEAR(created_at) as year'),
                DB::raw('MONTH(created_at) as month'),
                DB::raw('SUM(total_amount) as revenue'),
                DB::raw('COUNT(*) as order_count')
            )
            ->where('status', 'paid')
            ->where('created_at', '>=', $startDate)
            ->groupBy('year', 'month')
            ->orderBy('year')
            ->orderBy('month')
            ->get();
        
        // Format the labels as month names
        $labels = $data->map(function ($item) {
            return Carbon::createFromDate($item->year, $item->month, 1)->format('M Y');
        })->toArray();
        
        // Format the dataset values
        $revenueData = $data->pluck('revenue')->toArray();
        $orderCountData = $data->pluck('order_count')->toArray();
        
        // Generate gradient colors
        return [
            'datasets' => [
                [
                    'label' => 'Pendapatan (Rp)',
                    'data' => $revenueData,
                    'borderColor' => '#3b82f6', // blue-500
                    'backgroundColor' => 'rgba(59, 130, 246, 0.1)', // blue-500 with opacity
                    'fill' => true,
                    'tension' => 0.4,
                    'yAxisID' => 'y',
                ],
                [
                    'label' => 'Jumlah Pesanan',
                    'data' => $orderCountData,
                    'borderColor' => '#22c55e', // green-500
                    'backgroundColor' => 'rgba(34, 197, 94, 0.1)', // green-500 with opacity
                    'fill' => true,
                    'tension' => 0.4,
                    'yAxisID' => 'y1',
                ],
            ],
            'labels' => $labels,
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }
    
    protected function getOptions(): array
    {
        return [
            'plugins' => [
                'legend' => [
                    'display' => true,
                    'position' => 'top',
                ],
            ],
            'scales' => [
                'y' => [
                    'type' => 'linear',
                    'display' => true,
                    'position' => 'left',
                    'title' => [
                        'display' => true,
                        'text' => 'Pendapatan (Rp)',
                    ],
                    'grid' => [
                        'display' => false,
                    ],
                ],
                'y1' => [
                    'type' => 'linear',
                    'display' => true,
                    'position' => 'right',
                    'title' => [
                        'display' => true,
                        'text' => 'Jumlah Pesanan',
                    ],
                    'grid' => [
                        'display' => false,
                    ],
                ],
                'x' => [
                    'grid' => [
                        'display' => false,
                    ],
                ],
            ],
            'maintainAspectRatio' => false,
            'responsive' => true,
        ];
    }
}