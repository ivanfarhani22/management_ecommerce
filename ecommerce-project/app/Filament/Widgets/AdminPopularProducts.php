<?php

namespace App\Filament\Widgets;

use App\Models\Order;
use App\Models\Product;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\DB;

class AdminPopularProducts extends BaseWidget
{
    protected static ?int $sort = 3;
    protected int | string | array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                // Fix the GROUP BY issue by using DB::raw and only selecting necessary columns
                Product::select([
                    'products.id', 
                    'products.name', 
                    'products.price',
                    'products.stock',
                    'products.image',
                    DB::raw('COUNT(order_items.id) as total_ordered')
                ])
                ->leftJoin('order_items', 'products.id', '=', 'order_items.product_id')
                ->leftJoin('orders', 'order_items.order_id', '=', 'orders.id')
                ->where(function($query) {
                    $query->where('orders.status', 'paid')
                          ->orWhereNull('orders.id');
                })
                ->groupBy([
                    'products.id', 
                    'products.name',
                    'products.price',
                    'products.stock',
                    'products.image'
                ])
                ->orderByDesc('total_ordered')
            )
            ->heading('Produk Terpopuler')
            ->columns([
                Tables\Columns\ImageColumn::make('image')
                    ->label('Gambar')
                    ->circular(),
                    
                Tables\Columns\TextColumn::make('name')
                    ->label('Nama Produk')
                    ->searchable()
                    ->sortable(),
                    
                Tables\Columns\TextColumn::make('price')
                    ->label('Harga')
                    ->money('IDR')
                    ->sortable(),
                    
                Tables\Columns\TextColumn::make('stock')
                    ->label('Stok')
                    ->sortable(),
                    
                Tables\Columns\TextColumn::make('total_ordered')
                    ->label('Total Terjual')
                    ->sortable(),
            ])
            ->actions([
                Tables\Actions\Action::make('view')
                    ->label('Lihat')
                    ->url(fn (Product $record): string => route('filament.admin.resources.products.edit', $record))
                    ->icon('heroicon-o-eye'),
            ])
            ->paginated([5, 10, 25, 50])
            ->defaultPaginationPageOption(5);
    }
}