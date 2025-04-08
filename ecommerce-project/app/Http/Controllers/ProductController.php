<?php

namespace App\Http\Controllers;

use App\Models\Product;
use App\Services\ProductService;
use App\Services\RecommendationService;
use Illuminate\Http\Request;

class ProductController extends Controller
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
        // Gunakan ProductService untuk mengambil produk
        $products = $this->productService->getAllProducts();

        return view('products.index', compact('products'));
    }

    public function show(Product $product)
    {
        $similarProducts = $this->recommendationService->getSimilarProducts($product);

        return view('products.show', compact('product', 'similarProducts'));
    }
}