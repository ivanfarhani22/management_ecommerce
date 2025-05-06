<?php

namespace App\Filament\Widgets;

use App\Models\Category;
use App\Models\Product;
use Filament\Widgets\ChartWidget;
use Illuminate\Support\Facades\DB;

class AdminCategoryDistribution extends ChartWidget
{
    protected static ?string $heading = 'Distribusi Produk Berdasarkan Kategori';
    
    protected static ?int $sort = 4;
    
    // Make widget slightly wider
    protected int | string | array $columnSpan = 'full';
    
    // Use nice color scheme
    protected static ?array $options = [
        'plugins' => [
            'legend' => [
                'display' => true,
                'position' => 'right',
            ],
        ],
        'maintainAspectRatio' => false,
    ];

    protected function getData(): array
    {
        $categories = Category::withCount('products')->get();
        
        // Create a color palette
        $colors = [
            '#22c55e', // green-500
            '#3b82f6', // blue-500
            '#f97316', // orange-500
            '#ec4899', // pink-500
            '#8b5cf6', // violet-500
            '#06b6d4', // cyan-500
            '#f43f5e', // rose-500
            '#eab308', // yellow-500
            '#14b8a6', // teal-500
            '#a855f7', // purple-500
        ];
        
        return [
            'datasets' => [
                [
                    'label' => 'Produk per Kategori',
                    'data' => $categories->pluck('products_count')->toArray(),
                    'backgroundColor' => array_slice($colors, 0, $categories->count()),
                    'borderColor' => '#ffffff',
                    'borderWidth' => 2,
                    'hoverOffset' => 10,
                ],
            ],
            'labels' => $categories->pluck('name')->toArray(),
        ];
    }

    protected function getType(): string
    {
        return 'doughnut';
    }
}