<?php

namespace App\Services;

use App\Models\Product;
use App\Models\Category;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Storage;

class ProductService
{
    public function createProduct(array $data)
    {
        $data['slug'] = Str::slug($data['name']);

        if (isset($data['image'])) {
            $imagePath = $data['image']->store('products', 'public');
            $data['image'] = $imagePath;
        }

        return Product::create($data);
    }

    public function updateProduct(Product $product, array $data)
    {
        if (isset($data['name'])) {
            $data['slug'] = Str::slug($data['name']);
        }

        // Hapus gambar lama jika ada gambar baru
        if (isset($data['image'])) {
            if ($product->image) {
                Storage::disk('public')->delete($product->image);
            }
            $imagePath = $data['image']->store('products', 'public');
            $data['image'] = $imagePath;
        }

        $product->update($data);
        return $product;
    }

    public function searchProducts(array $filters = [])
    {
        $query = Product::query()->where('is_active', true);

        if (isset($filters['category_id'])) {
            $query->where('category_id', $filters['category_id']);
        }

        if (isset($filters['min_price'])) {
            $query->where('price', '>=', $filters['min_price']);
        }

        if (isset($filters['max_price'])) {
            $query->where('price', '<=', $filters['max_price']);
        }

        if (isset($filters['search'])) {
            $query->where(function($q) use ($filters) {
                $q->where('name', 'like', '%' . $filters['search'] . '%')
                  ->orWhere('description', 'like', '%' . $filters['search'] . '%');
            });
        }

        if (isset($filters['sort'])) {
            switch ($filters['sort']) {
                case 'price_asc':
                    $query->orderBy('price', 'asc');
                    break;
                case 'price_desc':
                    $query->orderBy('price', 'desc');
                    break;
                case 'newest':
                    $query->latest();
                    break;
            }
        }

        return $query->paginate($filters['per_page'] ?? 15);
    }

    public function checkStock(Product $product, int $quantity)
    {
        return $product->stock >= $quantity;
    }

    public function updateStock(Product $product, int $quantity)
    {
        $product->decrement('stock', $quantity);
        return $product;
    }

    // Tambahan method untuk menghapus produk beserta gambarnya
    public function deleteProduct(Product $product)
    {
        if ($product->image) {
            Storage::disk('public')->delete($product->image);
        }
        return $product->delete();
    }
    public function getAllProducts(array $filters = [])
{
    $query = Product::query()->where('is_active', true);

    // Optional: Add sorting if needed
    $query->latest();

    // Optional: Allow pagination
    return $query->paginate($filters['per_page'] ?? 15);
}
}
