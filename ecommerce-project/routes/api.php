<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;

// API Controllers
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\CategoryController;
use App\Http\Controllers\API\ProductController;
use App\Http\Controllers\API\OrderController;
use App\Http\Controllers\API\UserController;
use App\Http\Controllers\API\CartController;

// ========== Public API Routes ==========
Route::prefix('v1')->group(function () {
    // Authentication
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);

    // Products (Public View)
    Route::get('/products', [ProductController::class, 'index']);
    Route::get('/products/{product}', [ProductController::class, 'show']);

    // Categories
    Route::get('/categories', [CategoryController::class, 'index']);
    
    // User public endpoints (no authentication required)
    Route::get('/users/{id}', [UserController::class, 'show']);
    Route::post('/users/batch', [UserController::class, 'getMultipleUsers']);
    Route::get('/users/batch', [UserController::class, 'getMultipleUsers']); // Added GET support
    
    // Debug route for troubleshooting
    Route::get('/debug/users/batch', function (Request $request) {
        $ids = $request->input('ids', []);
        
        return response()->json([
            'success' => true,
            'received' => [
                'request_method' => $request->method(),
                'content_type' => $request->header('Content-Type'),
                'all_input' => $request->all(),
                'ids_param' => $ids,
                'parsed_ids' => is_string($ids) ? json_decode($ids, true) : $ids
            ]
        ]);
    });
});

// ========== Protected API Routes (with Sanctum) ==========
Route::middleware('auth:sanctum')->prefix('v1')->group(function () {
    // Authenticated User Info
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // Profile
    Route::get('/profile', [UserController::class, 'profile']);
    Route::put('/profile', [UserController::class, 'updateProfile']);

    // Users Management (Admin only)
    Route::get('/users', [UserController::class, 'index']);
    Route::put('/users/{user}', [UserController::class, 'update']);
    Route::delete('/users/{user}', [UserController::class, 'destroy']);

    // Orders
    Route::get('/orders', [OrderController::class, 'index']);
    Route::post('/orders', [OrderController::class, 'store']);
    Route::get('/orders/{order}', [OrderController::class, 'show']);
    Route::put('/orders/{order}/status', [OrderController::class, 'updateStatus']);

    // Cart
    Route::get('/cart', [CartController::class, 'index']);
    Route::post('/cart', [CartController::class, 'store']);
    Route::put('/cart/{cartItem}', [CartController::class, 'update']);
    Route::delete('/cart/{cartItem}', [CartController::class, 'destroy']);

    // Admin-Only Product Management
    Route::post('/products', [ProductController::class, 'store']);
    Route::put('/products/{product}', [ProductController::class, 'update']);
    Route::delete('/products/{product}', [ProductController::class, 'destroy']);
});

// ========== Fallback ==========
Route::fallback(function () {
    return response()->json([
        'message' => 'API route not found'
    ], 404);
});