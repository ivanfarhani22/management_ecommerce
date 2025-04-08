<?php

namespace App\Services;

use App\Models\Product;
use App\Models\Order;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class RecommendationService
{
    public function getPersonalizedRecommendations()
    {
        $user = Auth::user();

        // Gunakan query builder untuk performa lebih baik
        $recentCategories = DB::table('orders')
            ->join('order_items', 'orders.id', '=', 'order_items.order_id')
            ->join('products', 'order_items.product_id', '=', 'products.id')
            ->where('orders.user_id', $user->id)
            ->select('products.category_id')
            ->distinct()
            ->pluck('category_id')
            ->toArray();

        // Jika tidak ada kategori dari pesanan sebelumnya, gunakan kategori acak
        if (empty($recentCategories)) {
            return Product::where('is_active', true)
                ->inRandomOrder()
                ->limit(10)
                ->get();
        }

        // Recommend products dari kategori serupa
        return Product::whereIn('category_id', $recentCategories)
            ->where('is_active', true)
            ->inRandomOrder()
            ->limit(10)
            ->get();
    }

    public function getSimilarProducts(Product $product, $limit = 5)
    {
        return Product::where('category_id', $product->category_id)
            ->where('id', '!=', $product->id)
            ->where('is_active', true)
            ->inRandomOrder()
            ->limit($limit)
            ->get();
    }

    public function getMostPopularProducts($limit = 10)
    {
        return Product::withCount('orderItems')
            ->orderBy('order_items_count', 'desc')
            ->where('is_active', true)
            ->limit($limit)
            ->get();
    }

    // Tambahan method untuk rekomendasi berdasarkan harga
    public function getProductsInPriceRange(Product $product, $percentage = 20, $limit = 5)
    {
        $minPrice = $product->price * (1 - $percentage/100);
        $maxPrice = $product->price * (1 + $percentage/100);

        return Product::where('category_id', $product->category_id)
            ->where('id', '!=', $product->id)
            ->where('is_active', true)
            ->whereBetween('price', [$minPrice, $maxPrice])
            ->inRandomOrder()
            ->limit($limit)
            ->get();
    }
}