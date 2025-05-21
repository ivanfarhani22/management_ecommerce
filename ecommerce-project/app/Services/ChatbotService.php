<?php

namespace App\Services;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use App\Models\Category;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Log;

class ChatbotService
{
    private $intents;
    private $entities;
    private $stopWords;
    
    public function __construct()
    {
        $this->initializeNLPComponents();
    }

    /**
     * Inisialisasi komponen NLP (intent patterns, entity patterns, stop words)
     */
    private function initializeNLPComponents()
    {
        // Intent patterns dengan berbagai variasi ekspresi natural
        $this->intents = [
            'track_order' => [
                'patterns' => [
                    '/(?:dimana|mana|status|kondisi|bagaimana).*(?:pesanan|order|barang|kiriman|pengiriman)/i',
                    '/(?:lacak|track|cek|periksa).*(?:pesanan|order|status)/i',
                    '/(?:pesanan|order).*(?:nomor|no|id|kode)\s*(\d+)/i',
                    '/(?:sudah|belum).*(?:sampai|tiba|dikirim|kirim)/i',
                    '/(?:kapan|berapa lama).*(?:sampai|tiba|diterima)/i'
                ],
                'keywords' => ['status', 'lacak', 'track', 'pesanan', 'order', 'dimana', 'sampai', 'kirim', 'pengiriman']
            ],
            
            'product_recommendation' => [
                'patterns' => [
                    '/(?:recommend|rekomendasi|saran|usul).*(?:produk|barang)/i',
                    '/(?:produk|barang).*(?:terlaris|populer|terbaik|favorit|hits)/i',
                    '/(?:apa|mana).*(?:produk|barang).*(?:bagus|terbaik|recommended)/i',
                    '/(?:best|top|terbaik).*(?:seller|selling|product|produk)/i'
                ],
                'keywords' => ['terlaris', 'populer', 'recommend', 'rekomendasi', 'terbaik', 'favorit', 'hits', 'best', 'top']
            ],
            
            'product_search' => [
                'patterns' => [
                    '/(?:cari|search|find|temukan|carikan).*(?:produk|barang)/i',
                    '/(?:ada|punya|jual).*(?:produk|barang)/i',
                    '/(?:mau|ingin|pengen).*(?:beli|cari|lihat)/i',
                    '/(?:produk|barang).*(?:apa|mana|yang|dengan)/i'
                ],
                'keywords' => ['cari', 'search', 'find', 'temukan', 'produk', 'barang', 'ada', 'jual', 'beli']
            ],
            
            'category_exploration' => [
                'patterns' => [
                    '/(?:kategori|category|jenis|tipe|macam).*(?:apa|mana|ada)/i',
                    '/(?:ada|punya).*(?:kategori|jenis|macam)/i',
                    '/(?:lihat|tampilkan).*(?:kategori|semua|daftar)/i',
                    '/(?:produk|barang).*(?:kategori|jenis|macam)/i'
                ],
                'keywords' => ['kategori', 'category', 'jenis', 'macam', 'tipe', 'klasifikasi']
            ],
            
            'shipping_policy' => [
                'patterns' => [
                    '/(?:pengiriman|shipping|kirim|ongkir|ongkos)/i',
                    '/(?:berapa).*(?:ongkir|biaya|harga).*(?:kirim|pengiriman)/i',
                    '/(?:gratis|free).*(?:ongkir|pengiriman)/i',
                    '/(?:lama|berapa).*(?:hari|waktu).*(?:kirim|sampai)/i'
                ],
                'keywords' => ['pengiriman', 'shipping', 'ongkir', 'kirim', 'gratis', 'biaya', 'lama', 'hari']
            ],
            
            'return_policy' => [
                'patterns' => [
                    '/(?:retur|return|tukar|ganti|kembalikan)/i',
                    '/(?:bisa|boleh).*(?:retur|return|tukar|kembalikan)/i',
                    '/(?:tidak|gak).*(?:cocok|sesuai|pas).*(?:gimana|bagaimana)/i',
                    '/(?:kebijakan|policy).*(?:retur|return)/i'
                ],
                'keywords' => ['retur', 'return', 'tukar', 'ganti', 'kembalikan', 'kebijakan']
            ],
            
            'promotion_info' => [
                'patterns' => [
                    '/(?:promo|diskon|discount|sale|potongan|cashback)/i',
                    '/(?:ada|punya).*(?:promo|diskon|sale|potongan)/i',
                    '/(?:murah|hemat|penawaran)/i',
                    '/(?:kode|voucher|kupon).*(?:diskon|promo)/i'
                ],
                'keywords' => ['promo', 'diskon', 'discount', 'sale', 'potongan', 'cashback', 'murah', 'voucher']
            ]
        ];

        // Entity patterns untuk ekstraksi informasi spesifik
        $this->entities = [
            'order_number' => '/(?:order|pesanan|no|nomor|id|kode)[\s\-:]*(\d+)/i',
            'product_name' => '/(?:produk|barang)\s+([a-zA-Z\s]+)(?:\s|$)/i',
            'category_name' => '/kategori\s+([a-zA-Z\s]+)(?:\s|$)/i',
            'price_range' => '/(?:harga|price)\s*(?:dibawah|under|kurang dari|maksimal)?\s*(\d+)/i',
            'quantity' => '/(\d+)\s*(?:buah|pcs|piece|item)/i'
        ];

        // Stop words untuk preprocessing
        $this->stopWords = [
            'ini', 'itu', 'di', 'ke', 'dari', 'dengan', 'untuk', 'pada', 'dalam', 'sebagai',
            'oleh', 'tentang', 'antara', 'atas', 'bawah', 'dan', 'atau', 'tetapi', 'jika',
            'karena', 'sehingga', 'sambil', 'selagi', 'agar', 'supaya', 'seperti', 'ibarat',
            'bagai', 'adalah', 'ialah', 'yaitu', 'yakni', 'bahwa', 'yang', 'mana', 'dimana',
            'kemana', 'darimana', 'bagaimana', 'mengapa', 'kenapa', 'kapan', 'bilamana'
        ];
    }

    /**
     * Memproses pesan menggunakan NLP pipeline
     */
    public function processMessage(string $message): array
    {
        Log::info('Chatbot: Processing message', ['message' => $message]);
        
        // 1. Preprocessing
        $processedMessage = $this->preprocessMessage($message);
        
        // 2. Intent Classification
        $detectedIntent = $this->classifyIntent($processedMessage);
        
        // 3. Entity Extraction
        $extractedEntities = $this->extractEntities($processedMessage);
        
        Log::info('Chatbot: NLP Analysis', [
            'original_message' => $message,
            'processed_message' => $processedMessage,
            'detected_intent' => $detectedIntent,
            'extracted_entities' => $extractedEntities
        ]);
        
        // 4. Generate Response berdasarkan intent dan entities
        return $this->generateResponse($detectedIntent, $extractedEntities, $message);
    }

    /**
     * Preprocessing pesan: normalisasi, tokenisasi, stop word removal
     */
    private function preprocessMessage(string $message): string
    {
        // Konversi ke lowercase
        $processed = strtolower($message);
        
        // Hapus karakter khusus dan multiple spaces
        $processed = preg_replace('/[^\w\s\d]/u', ' ', $processed);
        $processed = preg_replace('/\s+/', ' ', $processed);
        
        // Tokenisasi dan hapus stop words
        $tokens = explode(' ', trim($processed));
        $filteredTokens = array_filter($tokens, function($token) {
            return !in_array($token, $this->stopWords) && strlen($token) > 1;
        });
        
        return implode(' ', $filteredTokens);
    }

    /**
     * Klasifikasi intent menggunakan pattern matching dan keyword scoring
     */
    private function classifyIntent(string $processedMessage): string
    {
        $intentScores = [];
        
        foreach ($this->intents as $intentName => $intentData) {
            $score = 0;
            
            // Pattern matching score
            foreach ($intentData['patterns'] as $pattern) {
                if (preg_match($pattern, $processedMessage)) {
                    $score += 3; // Pattern match mendapat score tinggi
                }
            }
            
            // Keyword matching score dengan TF-IDF sederhana
            $messageTokens = explode(' ', $processedMessage);
            $keywordMatches = array_intersect($messageTokens, $intentData['keywords']);
            $score += count($keywordMatches) * 1.5;
            
            // Bonus untuk multiple keyword matches
            if (count($keywordMatches) > 1) {
                $score += 1;
            }
            
            $intentScores[$intentName] = $score;
        }
        
        // Return intent dengan score tertinggi, atau default jika tidak ada yang cocok
        $maxScore = max($intentScores);
        if ($maxScore > 0) {
            return array_search($maxScore, $intentScores);
        }
        
        return 'default';
    }

    /**
     * Ekstraksi entitas dari pesan menggunakan Named Entity Recognition
     */
    private function extractEntities(string $message): array
    {
        $entities = [];
        
        foreach ($this->entities as $entityType => $pattern) {
            if (preg_match($pattern, $message, $matches)) {
                $entities[$entityType] = trim($matches[1]);
            }
        }
        
        return $entities;
    }

    /**
     * Generate response berdasarkan intent dan entities yang terdeteksi
     */
    private function generateResponse(string $intent, array $entities, string $originalMessage): array
    {
        switch ($intent) {
            case 'track_order':
                return $this->handleOrderTracking($entities, $originalMessage);
                
            case 'product_recommendation':
                return $this->handleProductRecommendation($entities);
                
            case 'product_search':
                return $this->handleProductSearch($entities, $originalMessage);
                
            case 'category_exploration':
                return $this->handleCategoryExploration($entities);
                
            case 'shipping_policy':
                return $this->handleShippingPolicy($entities);
                
            case 'return_policy':
                return $this->handleReturnPolicy($entities);
                
            case 'promotion_info':
                return $this->handlePromotionInfo($entities);
                
            default:
                return $this->handleDefaultResponse();
        }
    }

    /**
     * Handle order tracking dengan entity recognition yang lebih baik
     */
    private function handleOrderTracking(array $entities, string $originalMessage): array
    {
        // Coba ekstrak order number dari entities atau regex yang lebih fleksibel
        $orderNumber = $entities['order_number'] ?? null;
        
        if (!$orderNumber) {
            // Fallback regex untuk berbagai format nomor pesanan
            preg_match('/\b(\d{3,10})\b/', $originalMessage, $matches);
            $orderNumber = $matches[1] ?? null;
        }

        if (!$orderNumber) {
            return [
                'type' => 'text',
                'content' => 'Untuk melacak pesanan Anda, saya memerlukan nomor pesanan. Silakan berikan nomor pesanan yang ingin Anda lacak. Contoh: "Lacak pesanan 12345" atau "Status order INV001234".'
            ];
        }

        $order = Order::with('orderItems.product')->find($orderNumber);

        if (!$order) {
            return [
                'type' => 'text',
                'content' => "Maaf, saya tidak dapat menemukan pesanan dengan nomor {$orderNumber}. Pastikan nomor pesanan benar atau hubungi customer service kami untuk bantuan lebih lanjut."
            ];
        }

        // Generate respons yang lebih natural dan informatif
        $statusEmoji = $this->getStatusEmoji($order->status);
        $statusMessage = "🔍 **Informasi Pesanan #{$order->id}**\n\n";
        $statusMessage .= "📦 Status: {$statusEmoji} {$order->status}\n";
        
        if ($order->orderItems->isNotEmpty()) {
            $statusMessage .= "\n📋 **Detail Produk:**\n";
            foreach ($order->orderItems as $item) {
                $productName = $item->product ? $item->product->name : 'Produk tidak diketahui';
                $statusMessage .= "• {$productName} (Qty: {$item->quantity})\n";
            }
        }
        
        if (isset($order->total_amount)) {
            $statusMessage .= "\n💰 Total: Rp " . number_format($order->total_amount, 0, ',', '.');
        }

        // Tambahkan prediksi waktu pengiriman berdasarkan status
        $statusMessage .= "\n" . $this->getDeliveryEstimation($order->status);

        return [
            'type' => 'text',
            'content' => $statusMessage
        ];
    }

    /**
     * Handle product search dengan natural language processing
     */
    private function handleProductSearch(array $entities, string $originalMessage): array
    {
        // Ekstrak kata kunci produk menggunakan metode yang lebih canggih
        $productKeywords = $this->extractProductKeywords($originalMessage);
        
        if (empty($productKeywords)) {
            return [
                'type' => 'text',
                'content' => 'Silakan berikan detail produk yang ingin Anda cari. Contoh: "Cari baju batik pria" atau "Ada sepatu olahraga Nike?"'
            ];
        }

        // Pencarian dengan relevance scoring
        $products = $this->searchProductsWithRelevance($productKeywords);

        if ($products->isEmpty()) {
            $suggestions = $this->generateSearchSuggestions($productKeywords);
            return [
                'type' => 'text',
                'content' => "Maaf, saya tidak menemukan produk yang sesuai dengan '{$originalMessage}'. \n\nSaran pencarian:\n{$suggestions}"
            ];
        }

        $productSuggestions = $products->map(function ($product) {
            return [
                'name' => $product['product']->name,
                'price' => $product['product']->price,
                'url' => route('products.show', $product['product']),
                'image' => $product['product']->image 
                    ? '/storage/products/' . basename($product['product']->image)
                    : '/images/placeholder.png',
                'relevance_score' => round($product['score'], 2) // Untuk debugging
            ];
        });

        return [
            'type' => 'product_suggestion',
            'content' => "🔍 Hasil pencarian untuk '{$originalMessage}':",
            'products' => $productSuggestions
        ];
    }

    /**
     * Handle product recommendation dengan algoritma yang lebih smart
     */
    private function handleProductRecommendation(array $entities): array
    {
        // Ambil produk terlaris dengan algoritma ranking yang lebih baik
        $bestSelling = OrderItem::selectRaw('product_id, SUM(quantity) as total_sold, COUNT(*) as order_count')
            ->groupBy('product_id')
            ->having('total_sold', '>', 0)
            ->orderByDesc('total_sold')
            ->orderByDesc('order_count')
            ->take(8)
            ->with('product')
            ->get();

        if ($bestSelling->isEmpty()) {
            // Fallback ke produk terbaru jika belum ada penjualan
            $latestProducts = Product::latest()->take(5)->get();
            
            if ($latestProducts->isEmpty()) {
                return [
                    'type' => 'text',
                    'content' => 'Saat ini catalog produk sedang diperbarui. Silakan kembali lagi nanti untuk melihat rekomendasi produk terbaik kami!'
                ];
            }

            $productSuggestions = $latestProducts->map(function ($product) {
                return [
                    'name' => $product->name,
                    'price' => $product->price,
                    'url' => route('products.show', $product),
                    'image' => $product->image 
                        ? '/storage/products/' . basename($product->image)
                        : '/images/placeholder.png'
                ];
            });

            return [
                'type' => 'product_suggestion',
                'content' => '✨ Produk terbaru yang mungkin menarik untuk Anda:',
                'products' => $productSuggestions
            ];
        }

        $products = $bestSelling->map(function ($item) {
            if (!$item->product) {
                return null;
            }
            return [
                'name' => $item->product->name,
                'price' => $item->product->price,
                'url' => route('products.show', $item->product),
                'image' => $item->product->image 
                    ? '/storage/products/' . basename($item->product->image)
                    : '/images/placeholder.png',
                'sold_count' => $item->total_sold
            ];
        })->filter()->values();

        return [
            'type' => 'product_suggestion',
            'content' => '🔥 Produk paling populer bulan ini:',
            'products' => $products
        ];
    }

    /**
     * Handle category exploration
     */
    private function handleCategoryExploration(array $entities): array
    {
        $categories = Category::when(method_exists(Category::class, 'scopeActive'), function ($query) {
            return $query->active();
        })->withCount('products')->get();

        if ($categories->isEmpty()) {
            return [
                'type' => 'text',
                'content' => 'Saat ini catalog kategori sedang diperbarui. Silakan kembali lagi nanti!'
            ];
        }

        $content = "📁 **Kategori Produk Kami:**\n\n";
        foreach ($categories as $category) {
            $productCount = $category->products_count ?? 0;
            $categoryUrl = route('catalog.category', $category) ?? '#';
            $content .= "🏷️ **{$category->name}**";
            
            if ($productCount > 0) {
                $content .= " ({$productCount} produk)";
            }
            
            if (!empty($category->description)) {
                $content .= "\n   _{$category->description}_";
            }
            
            $content .= "\n   [👁️ Lihat Produk]({$categoryUrl})\n\n";
        }

        return [
            'type' => 'text',
            'content' => $content
        ];
    }

    /**
     * Handle shipping policy dengan respons contextual
     */
    private function handleShippingPolicy(array $entities): array
    {
        return [
            'type' => 'text',
            'content' => "🚚 **Informasi Pengiriman:**\n\n" .
                        "✅ **Gratis Ongkir** untuk pembelian minimal Rp 500.000\n" .
                        "📦 Estimasi pengiriman: 2-5 hari kerja\n" .
                        "🌍 Melayani seluruh Indonesia\n" .
                        "🔐 Pengemasan aman dan berkualitas\n" .
                        "📱 Real-time tracking tersedia\n\n" .
                        "Butuh info lebih detail? Tanya aja ke customer service kami!"
        ];
    }

    /**
     * Handle return policy
     */
    private function handleReturnPolicy(array $entities): array
    {
        return [
            'type' => 'text',
            'content' => "🔄 **Kebijakan Retur & Pengembalian:**\n\n" .
                        "⏱️ Masa retur: 14 hari setelah penerimaan\n" .
                        "📦 Kondisi barang: Masih baru dan belum digunakan\n" .
                        "🏷️ Label dan kemasan asli harus ada\n" .
                        "💰 Biaya retur: Ditanggung pembeli\n" .
                        "🔄 Proses refund: 3-7 hari kerja\n\n" .
                        "Punya pertanyaan khusus tentang retur? Hubungi tim support kami!"
        ];
    }

    /**
     * Handle promotion info
     */
    private function handlePromotionInfo(array $entities): array
    {
        $promos = [
            "🎁 **Diskon 20%** untuk first buyer (Kode: WELCOME20)",
            "🚚 **Gratis ongkir** pembelian minimal Rp 500K",
            "💰 **Cashback 15%** max Rp 100K via e-wallet",
            "👥 **Buy 2 Get 10% OFF** kategori fashion",
            "📱 **Follow Instagram** kami untuk promo eksklusif!"
        ];

        $content = "🎉 **Promo Menarik Bulan Ini:**\n\n" . implode("\n", $promos);
        $content .= "\n\n✨ _Syarat dan ketentuan berlaku. Promo terbatas!_";

        return [
            'type' => 'text',
            'content' => $content
        ];
    }

    /**
     * Handle default response dengan random variasi
     */
    private function handleDefaultResponse(): array
    {
        $responses = [
            "👋 Hai! Saya chatbot assistant toko online ini. Saya bisa bantu Anda:",
            "🤖 Halo! Ada yang bisa saya bantu hari ini?",
            "😊 Selamat datang! Saya siap membantu Anda dengan:"
        ];

        $services = [
            "🔍 Melacak status pesanan Anda",
            "🛍️ Mencari produk yang Anda inginkan", 
            "🔥 Memberikan rekomendasi produk terlaris",
            "📁 Informasi kategori produk",
            "🚚 Detail kebijakan pengiriman",
            "💳 Info promo dan diskon menarik"
        ];

        $randomResponse = $responses[array_rand($responses)];
        $content = $randomResponse . "\n\n" . implode("\n", $services);
        $content .= "\n\n💬 Silakan ketik pertanyaan Anda atau pilih salah satu topic di atas!";

        return [
            'type' => 'text',
            'content' => $content
        ];
    }

    // Helper methods untuk NLP processing

    /**
     * Ekstrak kata kunci produk dari teks
     */
    private function extractProductKeywords(string $text): array
    {
        // Hapus kata-kata umum dan ambil kata kunci potensial
        $processed = $this->preprocessMessage($text);
        $tokens = explode(' ', $processed);
        
        // Filter token yang kemungkinan nama produk atau brand
        $keywords = array_filter($tokens, function($token) {
            return strlen($token) >= 2 && 
                   !in_array($token, ['cari', 'search', 'ada', 'punya', 'mau', 'ingin', 'beli', 'lihat']);
        });
        
        return array_values($keywords);
    }

    /**
     * Pencarian produk dengan relevance scoring
     */
    private function searchProductsWithRelevance(array $keywords): \Illuminate\Support\Collection
    {
        $products = Product::all();
        $scoredProducts = [];

        foreach ($products as $product) {
            $score = $this->calculateRelevanceScore($product, $keywords);
            
            if ($score > 0) {
                $scoredProducts[] = [
                    'product' => $product,
                    'score' => $score
                ];
            }
        }

        // Sort by relevance score dan ambil top 5
        usort($scoredProducts, function($a, $b) {
            return $b['score'] <=> $a['score'];
        });

        return collect(array_slice($scoredProducts, 0, 5));
    }

    /**
     * Hitung relevance score produk berdasarkan keywords
     */
    private function calculateRelevanceScore($product, array $keywords): float
    {
        $score = 0;
        $productText = strtolower($product->name . ' ' . ($product->description ?? ''));
        
        foreach ($keywords as $keyword) {
            $keyword = strtolower($keyword);
            
            // Exact match dalam nama produk
            if (str_contains(strtolower($product->name), $keyword)) {
                $score += 10;
            }
            
            // Partial match dalam nama produk
            if (similar_text(strtolower($product->name), $keyword) > strlen($keyword) * 0.6) {
                $score += 5;
            }
            
            // Match dalam deskripsi
            if (str_contains($productText, $keyword)) {
                $score += 3;
            }
        }
        
        return $score;
    }

    /**
     * Generate search suggestions berdasarkan keywords
     */
    private function generateSearchSuggestions(array $keywords): string
    {
        $suggestions = [
            "• Coba gunakan kata kunci yang lebih spesifik",
            "• Gunakan nama brand atau tipe produk",
            "• Lihat kategori produk untuk browsing",
            "• Hubungi customer service untuk bantuan pencarian"
        ];
        
        return implode("\n", $suggestions);
    }

    /**
     * Get emoji berdasarkan status order
     */
    private function getStatusEmoji(string $status): string
    {
        $statusEmojis = [
            'pending' => '🕐',
            'processing' => '⚙️',
            'shipped' => '🚚',
            'delivered' => '✅',
            'cancelled' => '❌',
            'returned' => '🔄'
        ];
        
        return $statusEmojis[strtolower($status)] ?? '📦';
    }

    /**
     * Get delivery estimation berdasarkan status
     */
    private function getDeliveryEstimation(string $status): string
    {
        switch (strtolower($status)) {
            case 'pending':
                return "⏱️ Pesanan sedang diverifikasi (1-2 hari kerja)";
            case 'processing':
                return "📦 Sedang diproses dan dikemas (1-2 hari kerja)";
            case 'shipped':
                return "🚛 Dalam perjalanan (1-3 hari kerja)";
            case 'delivered':
                return "🎉 Pesanan telah diterima";
            case 'cancelled':
                return "❌ Pesanan dibatalkan";
            default:
                return "📞 Hubungi customer service untuk info lebih lanjut";
        }
    }
}