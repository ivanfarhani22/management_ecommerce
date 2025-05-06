<?php

namespace App\Filament\Widgets;

use App\Models\Order;
use Filament\Widgets\ChartWidget;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class AdminPaymentMethodsChart extends ChartWidget
{
    protected static ?string $heading = 'Metode Pembayaran';
    
    protected static ?int $sort = 5;
    
    // Make it take up less space
    protected int|string|array $columnSpan = 'full';
    
    // Set chart height
    protected static ?string $maxHeight = '300px';

    protected function getType(): string
    {
        return 'pie';
    }
    
    protected function getOptions(): array
    {
        return [
            'plugins' => [
                'legend' => [
                    'position' => 'bottom',
                ],
                'tooltip' => [
                    'enabled' => true,
                ],
            ],
            'maintainAspectRatio' => false,
        ];
    }

    protected function getData(): array
    {
        // Check if the table exists first
        if (!Schema::hasTable('orders')) {
            return $this->getEmptyChartData();
        }
        
        // Get the column names from the orders table
        $columns = Schema::getColumnListing('orders');
        
        // Look for possible payment method column names
        $paymentColumnCandidates = [
            'payment_method',
            'payment_type',
            'payment_gateway',
            'payment_provider',
            'payment_channel',
            'payment_name',
            'payment_id',
            'payment',
            'payment_status',  // Sometimes this contains the method info
        ];
        
        // Find the first matching payment column
        $paymentColumn = null;
        foreach ($paymentColumnCandidates as $candidate) {
            if (in_array($candidate, $columns)) {
                $paymentColumn = $candidate;
                break;
            }
        }
        
        // If no payment column found, use a default approach
        if (!$paymentColumn) {
            return $this->getDefaultChartData();
        }
        
        try {
            $paymentData = Order::where('status', 'paid')
                ->select($paymentColumn, DB::raw('COUNT(*) as count'))
                ->whereNotNull($paymentColumn)
                ->groupBy($paymentColumn)
                ->orderBy('count', 'desc')
                ->get();
                
            if ($paymentData->isEmpty()) {
                return $this->getDefaultChartData();
            }
            
            $labels = $paymentData->pluck($paymentColumn)->toArray();
            $values = $paymentData->pluck('count')->toArray();
            
            // Generate colors for each payment method
            $colors = $this->generateColors(count($labels));
            
            return [
                'labels' => $labels,
                'datasets' => [
                    [
                        'label' => 'Metode Pembayaran',
                        'data' => $values,
                        'backgroundColor' => $colors,
                    ],
                ],
            ];
        } catch (\Exception $e) {
            // If an error occurs, return a default chart
            return $this->getDefaultChartData();
        }
    }
    
    // Return a default chart when no payment data is available
    protected function getDefaultChartData(): array
    {
        return [
            'labels' => ['Belum ada data pembayaran'],
            'datasets' => [
                [
                    'label' => 'Metode Pembayaran',
                    'data' => [1],
                    'backgroundColor' => ['#d1d5db'], // Gray color
                ],
            ],
        ];
    }
    
    // Return an empty chart when the orders table doesn't exist
    protected function getEmptyChartData(): array
    {
        return [
            'labels' => ['Tabel pesanan tidak tersedia'],
            'datasets' => [
                [
                    'label' => 'Metode Pembayaran',
                    'data' => [1],
                    'backgroundColor' => ['#d1d5db'], // Gray color
                ],
            ],
        ];
    }
    
    // Helper function to generate colors for the chart
    protected function generateColors(int $count): array
    {
        $colors = [
            '#3b82f6', // blue
            '#10b981', // green  
            '#f59e0b', // amber
            '#ef4444', // red
            '#8b5cf6', // purple
            '#ec4899', // pink
            '#14b8a6', // teal
            '#f97316', // orange
            '#6366f1', // indigo
            '#84cc16', // lime
        ];
        
        // If we need more colors than we have, repeat the array
        if ($count > count($colors)) {
            $colors = array_merge($colors, $colors);
        }
        
        return array_slice($colors, 0, $count);
    }
}