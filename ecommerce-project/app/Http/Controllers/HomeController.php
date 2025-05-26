<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Product;
use App\Models\Category;
use App\Services\ProductService;
use App\Services\RecommendationService;

class HomeController extends Controller
{
    protected $productService;
    protected $recommendationService;

    public function __construct(ProductService $productService, RecommendationService $recommendationService)
    {
        $this->productService = $productService;
        $this->recommendationService = $recommendationService;
    }

    public function index()
    {
        // Menggunakan recommendation service untuk featured products
        $featuredProducts = $this->recommendationService->getMostPopularProducts();
        
        // Rekomendasi personal jika user login, jika tidak tampilkan featured products
        $recommendedProducts = auth()->check() 
            ? $this->recommendationService->getPersonalizedRecommendations()
            : $featuredProducts;
        
        // Ambil semua kategori untuk section categories
        $categories = Category::withCount('products')
            ->take(8)
            ->get();
        
        // Hitung statistik
        $stats = [
            'total_products' => Product::count(),
            'total_categories' => Category::count(),
            'happy_customers' => '10K+', // Ini bisa disesuaikan dengan data user atau orders
            'satisfaction' => '98%' // Ini bisa dihitung dari rating atau reviews
        ];
        
        return view('home.index', compact('featuredProducts', 'recommendedProducts', 'categories', 'stats'));
    }
}