<?php

use Illuminate\Support\Facades\Route;

// Authentication Controllers
use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\Auth\ForgotPasswordController;
use App\Http\Controllers\Auth\ResetPasswordController;

// Main Controllers
use App\Http\Controllers\HomeController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\CatalogController;
use App\Http\Controllers\CheckoutController;
use App\Http\Controllers\CartController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\ChatbotController;
use App\Http\Controllers\AddressController;
use App\Http\Controllers\MidtransController;

// API Controllers
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\CartController as APICartController;
use App\Http\Controllers\API\CategoryController as APICategoryController;
use App\Http\Controllers\API\OrderController as APIOrderController;
use App\Http\Controllers\API\ProductController as APIProductController;
use App\Http\Controllers\API\UserController;

// Public Routes
Route::get('/', [HomeController::class, 'index'])->name('home');

// Catalog Routes
Route::get('/catalog', [CatalogController::class, 'index'])->name('catalog.index');
Route::get('/catalog/category/{category}', [CatalogController::class, 'category'])->name('catalog.category');

// Product Routes
Route::get('/products', [ProductController::class, 'index'])->name('products.index');
Route::get('/products/{product}', [ProductController::class, 'show'])->name('products.show');

// Authentication Routes
Route::middleware(['guest'])->group(function () {
    // Login Routes
    Route::get('/login', [LoginController::class, 'showLoginForm'])->name('login');
    Route::post('/login', [LoginController::class, 'login'])->name('login.attempt');

    // Registration Routes
    Route::get('/register', [RegisterController::class, 'showRegistrationForm'])->name('register');
    Route::post('/register', [RegisterController::class, 'register'])->name('register.store');

    // Password Reset Routes
    Route::get('/forgot-password', [ForgotPasswordController::class, 'showLinkRequestForm'])->name('password.request');
    Route::post('/forgot-password', [ForgotPasswordController::class, 'sendResetLinkEmail'])->name('password.email');
    Route::get('/reset-password/{token}', [ResetPasswordController::class, 'showResetForm'])->name('password.reset');
    Route::post('/reset-password', [ResetPasswordController::class, 'reset'])->name('password.update');
});

// Authenticated User Routes
Route::middleware(['auth'])->group(function () {
    // Logout Route
    Route::post('/logout', [LoginController::class, 'logout'])->name('logout');

    // Cart Routes
    Route::get('/cart', [CartController::class, 'index'])->name('cart.index');
    Route::post('/cart', [CartController::class, 'store'])->name('cart.store');
    Route::put('/cart/{cartItem}', [CartController::class, 'update'])->name('cart.update');
    Route::delete('/cart/{cartItem}', [CartController::class, 'destroy'])->name('cart.destroy');
    Route::post('/cart/add', [CartController::class, 'add'])->name('cart.add');
    Route::get('/cart/debug', [CartController::class, 'debug'])->name('cart.debug');
    Route::delete('/cart/clear', [CartController::class, 'clear'])->name('cart.clear');

    // Multi-step Checkout Routes
    Route::prefix('checkout')->group(function () {
        // Step 1: Customer Information
        Route::get('/', [CheckoutController::class, 'index'])->name('checkout.index');
        Route::post('/customer-info', [CheckoutController::class, 'processCustomerInfo'])->name('checkout.customer-info');
        
        // Step 2: Delivery Method
        Route::get('/delivery', [CheckoutController::class, 'delivery'])->name('checkout.delivery');
        Route::post('/delivery', [CheckoutController::class, 'storeDelivery'])->name('checkout.store-delivery');
        
        // Step 3: Payment
        Route::get('/payment', [CheckoutController::class, 'payment'])->name('checkout.payment');
        Route::post('/payment', [CheckoutController::class, 'storePayment'])->name('checkout.store-payment');
        
        // Step 4: Confirmation
        Route::get('/confirmation', [CheckoutController::class, 'confirmation'])->name('checkout.confirmation');
        Route::post('/complete', [CheckoutController::class, 'complete'])->name('checkout.complete');
        
        // Success page
        Route::get('/success/{order}', [CheckoutController::class, 'success'])->name('checkout.success');
        
        // Additional checkout status pages
        Route::get('/pending/{order}', function($orderId) {
            return view('checkout.pending', compact('orderId'));
        })->name('checkout.pending');
        
        Route::get('/failed/{order}', function($orderId) {
            return view('checkout.failed', compact('orderId'));
        })->name('checkout.failed');
        
        // Midtrans Payment Processing Routes (Fixed)
        Route::get('/payment/midtrans/{order}/{snap_token}', [CheckoutController::class, 'midtransPaymentProcess'])
            ->name('midtrans.payment.process');
            
        // Payment status check
        Route::get('/payment/status/{order}', [CheckoutController::class, 'checkPaymentStatus'])
            ->name('checkout.payment.status');
            
        // Clear checkout session
        Route::post('/clear-session', [CheckoutController::class, 'clearSession'])
            ->name('checkout.clear-session');
    });

    // Order Routes
    Route::get('/orders', [OrderController::class, 'index'])->name('orders.index');
    Route::get('/orders/{order}', [OrderController::class, 'show'])->name('orders.show');
    Route::post('/orders', [OrderController::class, 'store'])->name('orders.store');
    Route::post('/orders/{order}/cancel', [OrderController::class, 'cancel'])->name('orders.cancel');

    // Order confirmation email endpoint
    Route::post('/orders/{order}/send-confirmation', [OrderController::class, 'sendConfirmation'])->name('orders.send-confirmation');
});

// Midtrans Routes (Public - No authentication required for callbacks)
Route::prefix('midtrans')->group(function () {
    // Midtrans webhook notification (public)
    Route::post('/notification', [CheckoutController::class, 'midtransCallback'])
        ->name('midtrans.notification');
    
    // Midtrans redirect routes (public)
    Route::get('/finish', [CheckoutController::class, 'midtransFinish'])
        ->name('midtrans.finish');
        
    Route::get('/unfinish', [CheckoutController::class, 'midtransUnfinish'])
        ->name('midtrans.unfinish');
        
    Route::get('/error', [CheckoutController::class, 'midtransError'])
        ->name('midtrans.error');
        
    // Status check (can be public for webhook verification)
    Route::get('/status/{transaction_id}', [MidtransController::class, 'checkStatus'])
        ->name('midtrans.status');
});

// Profile Routes
Route::middleware(['auth'])->group(function () {
    Route::get('/profile', [ProfileController::class, 'index'])->name('profile.index');
    Route::get('/profile/edit', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::put('/profile/update', [ProfileController::class, 'update'])->name('profile.update');

     // Address routes
    Route::get('/profile/addresses', [AddressController::class, 'index'])->name('profile.address');
    Route::get('/addresses/create', [AddressController::class, 'create'])->name('addresses.create');
    Route::post('/addresses', [AddressController::class, 'store'])->name('addresses.store');
    Route::get('/addresses/{address}/edit', [AddressController::class, 'edit'])->name('addresses.edit');
    Route::put('/addresses/{address}', [AddressController::class, 'update'])->name('addresses.update');
    Route::delete('/addresses/{address}', [AddressController::class, 'delete'])->name('addresses.delete');
});

// API Routes
Route::prefix('api')->group(function () {
    // API Authentication Routes
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth');

    // API User Routes
    Route::middleware('auth')->group(function () {
        Route::get('/user', [UserController::class, 'show']);
        Route::put('/user', [UserController::class, 'update']);
    });

    // API Product Routes
    Route::get('/products', [APIProductController::class, 'index']);
    Route::get('/products/{product}', [APIProductController::class, 'show']);

    // API Cart Routes
    Route::middleware('auth')->group(function () {
        Route::get('/cart', [APICartController::class, 'index']);
        Route::post('/cart', [APICartController::class, 'store']);
        Route::put('/cart/{cartItem}', [APICartController::class, 'update']);
        Route::delete('/cart/{cartItem}', [APICartController::class, 'destroy']);
    });

    // API Order Routes
    Route::middleware('auth')->group(function () {
        Route::get('/orders', [APIOrderController::class, 'index']);
        Route::get('/orders/{order}', [APIOrderController::class, 'show']);
        Route::post('/orders', [APIOrderController::class, 'store']);
        Route::post('/orders/{order}/cancel', [APIOrderController::class, 'cancel']);
    });
});

// Chatbot API Routes
Route::prefix('chatbot')->controller(ChatbotController::class)->group(function () {
    Route::post('/', 'sendMessage');
    Route::get('/history', 'getHistory');
    Route::post('/clear-history', 'clearHistory');
});

// Development/Testing Routes (Remove in production)
Route::get('/test-midtrans', function() {
    if (!app()->environment('local')) {
        abort(404);
    }
    
    $midtransService = new App\Services\MidtransService();
    return response()->json($midtransService->testConfiguration());
});

Route::get('/test-snap-token', function() {
    if (!app()->environment('local')) {
        abort(404);
    }
    
    try {
        // Ambil order dan payment yang ada untuk test
        $order = App\Models\Order::with(['items', 'user'])->first();
        $payment = App\Models\Payment::where('order_id', $order->id)->first();
        
        if (!$order || !$payment) {
            return response()->json([
                'status' => 'error',
                'message' => 'No order or payment found for testing'
            ]);
        }
        
        $midtransService = new App\Services\MidtransService();
        $snapToken = $midtransService->createSnapToken($order, $payment);
        
        return response()->json([
            'status' => 'success',
            'snap_token' => $snapToken,
            'order_id' => $order->id,
            'payment_id' => $payment->id
        ]);
        
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => $e->getMessage(),
            'trace' => $e->getTraceAsString()
        ]);
    }
});

Route::get('/debug-midtrans-config', function() {
    if (!app()->environment('local')) {
        abort(404);
    }
    
    return response()->json([
        'env_server_key' => env('MIDTRANS_SERVER_KEY'),
        'env_client_key' => env('MIDTRANS_CLIENT_KEY'),
        'config_server_key' => config('midtrans.server_key'),
        'config_client_key' => config('midtrans.client_key'),
        'config_file_exists' => file_exists(config_path('midtrans.php')),
        'midtrans_config_full' => config('midtrans')
    ]);
});

// Error Routes
Route::fallback(function () {
    return view('errors.404');
});