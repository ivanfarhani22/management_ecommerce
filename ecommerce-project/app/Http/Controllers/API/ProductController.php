<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Services\ProductService;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    protected $productService;

    public function __construct(ProductService $productService)
    {
        // In Laravel 12, middleware should be defined in routes rather than in the controller
        // Remove the middleware line from the constructor
        $this->productService = $productService;
    }

    public function index(Request $request)
    {
        $filters = $request->only([
            'category_id', 
            'min_price', 
            'max_price', 
            'search', 
            'sort', 
            'per_page'
        ]);

        $products = $this->productService->searchProducts($filters);

        return response()->json([
            'products' => $products->items(),
            'pagination' => [
                'current_page' => $products->currentPage(),
                'total_pages' => $products->lastPage(),
                'total_items' => $products->total()
            ]
        ]);
    }

    public function show(Product $product)
    {
        return response()->json([
            'product' => $product->load('category')
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'stock' => 'required|integer|min:0',
            'category_id' => 'required|exists:categories,id',
            'image' => 'nullable|image|max:2048'
        ]);

        $product = $this->productService->createProduct($request->all());

        return response()->json([
            'message' => 'Product created successfully',
            'product' => $product
        ], 201);
    }

    public function update(Request $request, Product $product)
    {
        $request->validate([
            'name' => 'string|max:255',
            'description' => 'nullable|string',
            'price' => 'numeric|min:0',
            'stock' => 'integer|min:0',
            'category_id' => 'exists:categories,id',
            'image' => 'nullable|image|max:2048'
        ]);

        $updatedProduct = $this->productService->updateProduct($product, $request->all());

        return response()->json([
            'message' => 'Product updated successfully',
            'product' => $updatedProduct
        ]);
    }

    public function destroy(Product $product)
    {
        $product->delete();

        return response()->json([
            'message' => 'Product deleted successfully'
        ]);
    }
}