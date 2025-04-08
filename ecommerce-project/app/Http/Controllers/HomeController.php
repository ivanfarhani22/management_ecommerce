<?php

namespace App\Http\Controllers;

use App\Services\ProductService;
use App\Services\RecommendationService;

class HomeController extends Controller
{
    protected $productService;
    protected $recommendationService;

    public function __construct(
        ProductService $productService, 
        RecommendationService $recommendationService
    ) {
        $this->productService = $productService;
        $this->recommendationService = $recommendationService;
    }

    public function index()
    {
        $featuredProducts = $this->recommendationService->getMostPopularProducts();
        $recommendedProducts = auth()->check() 
            ? $this->recommendationService->getPersonalizedRecommendations() 
            : $featuredProducts;

        return view('home.index', compact('featuredProducts', 'recommendedProducts'));
    }
}