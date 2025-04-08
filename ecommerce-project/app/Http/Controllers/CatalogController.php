<?php

namespace App\Http\Controllers;

use App\Services\ProductService;
use App\Models\Category;
use Illuminate\Http\Request;

class CatalogController extends Controller
{
    protected $productService;

    public function __construct(ProductService $productService)
    {
        $this->productService = $productService;
    }

    public function index(Request $request)
    {
        $filters = $request->only([
            'category_id', 
            'min_price', 
            'max_price', 
            'search', 
            'sort'
        ]);

        $products = $this->productService->searchProducts($filters);
        $categories = Category::all();

        return view('catalog.index', compact('products', 'categories', 'filters'));
    }

    public function category(Category $category)
    {
        $products = $this->productService->searchProducts([
            'category_id' => $category->id
        ]);

        return view('catalog.category', compact('products', 'category'));
    }
}