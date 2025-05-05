<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Session;

class ChatbotService
{
    private const SESSION_KEY = 'chatbot_history';
    private $maxHistoryItems;
    private $historyTtlDays;
    private $enableLog;

    /**
     * Constructor with configuration initialization
     */
    public function __construct()
    {
        $this->maxHistoryItems = config('chatbot.max_history_items', 50);
        $this->historyTtlDays = config('chatbot.history_ttl_days', 30);
        $this->enableLog = config('chatbot.enable_log', false);
    }

    /**
     * Process the user's message and generate a response
     *
     * @param string $message
     * @param int|null $userId
     * @return array
     */
    public function processMessage(string $message, ?int $userId = null): array
    {
        // Log the incoming message if logging is enabled
        if ($this->enableLog) {
            Log::info('Chatbot incoming message', [
                'user_id' => $userId ?? 'guest',
                'message' => $message
            ]);
        }

        // Normalize the message
        $message = strtolower(trim($message));

        // Generate response based on message content
        $response = $this->generateResponse($message);

        // Store in history if userId is provided
        if ($userId) {
            $this->storeInHistory($userId, $message, $response);
        }

        return $response;
    }

    /**
     * Generate appropriate response based on message content
     *
     * @param string $message
     * @return array
     */
    private function generateResponse(string $message): array
    {
        // Check for greetings
        if ($this->isGreeting($message)) {
            return [
                'type' => 'text',
                'content' => 'Hello! Welcome to our digital store. How can I help you today? You can ask me about our watches or electronic products.'
            ];
        }

        // Check for product queries
        if ($this->isProductQuery($message)) {
            return $this->handleProductQuery($message);
        }

        // Check for shipping or delivery questions
        if ($this->isShippingQuery($message)) {
            return [
                'type' => 'text',
                'content' => 'We offer standard shipping (3-5 business days), express shipping (1-2 business days), and free shipping on orders over $100. You can also choose our click & collect option at checkout.'
            ];
        }

        // Check for return policy questions
        if ($this->isReturnQuery($message)) {
            return [
                'type' => 'text',
                'content' => 'Our return policy allows returns within 30 days of purchase. Items must be in original condition with tags attached. For electronics, we offer a 14-day return window.'
            ];
        }

        // Check for payment method questions
        if ($this->isPaymentQuery($message)) {
            return [
                'type' => 'text',
                'content' => 'We accept credit/debit cards (Visa, Mastercard, American Express), PayPal, Apple Pay, and Google Pay. All transactions are secure and encrypted.'
            ];
        }

        // Check for warranty questions
        if ($this->isWarrantyQuery($message)) {
            return [
                'type' => 'text',
                'content' => 'Watches come with a 2-year manufacturer warranty. Electronic devices have varying warranty periods, typically 1-2 years depending on the product. Check the product page for specific warranty information.'
            ];
        }

        // If no pattern is matched, provide a default response
        return [
            'type' => 'text',
            'content' => "I'm not sure I understand. You can ask me about our watches, electronic products, shipping, returns, payment methods, or warranty information. How can I assist you today?"
        ];
    }

    /**
     * Store conversation in history
     *
     * @param int $userId
     * @param string $message
     * @param array $response
     * @return void
     */
    private function storeInHistory(int $userId, string $message, array $response): void
    {
        $sessionKey = self::SESSION_KEY . '_' . $userId;
        $history = Session::get($sessionKey, []);
        
        // Add new conversation
        $history[] = [
            'timestamp' => now()->timestamp,
            'user_message' => $message,
            'bot_response' => $response
        ];
        
        // Limit history size
        if (count($history) > $this->maxHistoryItems) {
            $history = array_slice($history, -$this->maxHistoryItems);
        }
        
        // Store in session
        Session::put($sessionKey, $history);
        
        // Set expiration
        Session::put($sessionKey . '_expires', now()->addDays($this->historyTtlDays)->timestamp);
    }

    /**
     * Get chat history for a user
     *
     * @param int $userId
     * @return array
     */
    public function getChatHistory(int $userId): array
    {
        $sessionKey = self::SESSION_KEY . '_' . $userId;
        $history = Session::get($sessionKey, []);
        $expires = Session::get($sessionKey . '_expires');
        
        // Clear expired history
        if ($expires && $expires < now()->timestamp) {
            $this->clearChatHistory($userId);
            return [];
        }
        
        return $history;
    }

    /**
     * Clear chat history for a user
     *
     * @param int $userId
     * @return void
     */
    public function clearChatHistory(int $userId): void
    {
        $sessionKey = self::SESSION_KEY . '_' . $userId;
        Session::forget($sessionKey);
        Session::forget($sessionKey . '_expires');
    }

    /**
     * Check if the message is a greeting
     *
     * @param string $message
     * @return bool
     */
    private function isGreeting(string $message): bool
    {
        $greetings = ['hello', 'hi', 'hey', 'greetings', 'good morning', 'good afternoon', 'good evening', 'howdy'];
        
        foreach ($greetings as $greeting) {
            if (str_contains($message, $greeting)) {
                return true;
            }
        }
        
        return false;
    }

    /**
     * Check if the message is a product query
     *
     * @param string $message
     * @return bool
     */
    private function isProductQuery(string $message): bool
    {
        $productKeywords = [
            'watch', 'watches', 'wristwatch', 'clock', 'wall clock', 
            'electronic', 'electronics', 'gadget', 'device', 'appliance',
            'smartwatch', 'digital watch', 'analog watch', 'smart watch',
            'product', 'item', 'buy', 'purchase', 'price', 'cost'
        ];
        
        foreach ($productKeywords as $keyword) {
            if (str_contains($message, $keyword)) {
                return true;
            }
        }
        
        return false;
    }

    /**
     * Handle product-related queries
     *
     * @param string $message
     * @return array
     */
    private function handleProductQuery(string $message): array
    {
        // Check if query is about watches
        if ($this->isWatchQuery($message)) {
            if (str_contains($message, 'smart') || str_contains($message, 'digital')) {
                return [
                    'type' => 'product_suggestion',
                    'content' => 'We have a great selection of smartwatches and digital watches. Our most popular models include fitness trackers with heart rate monitoring and smartwatches compatible with both iOS and Android.',
                    'products' => $this->getMockProducts('smart watches', 3)
                ];
            } elseif (str_contains($message, 'wall') || str_contains($message, 'clock')) {
                return [
                    'type' => 'product_suggestion',
                    'content' => 'Our wall clock collection includes modern, classic, and designer pieces to match any interior style.',
                    'products' => $this->getMockProducts('wall clocks', 3)
                ];
            } else {
                return [
                    'type' => 'product_suggestion',
                    'content' => 'We offer a wide range of watches including luxury, casual, sports, and fashion timepieces. Would you like to see our bestsellers?',
                    'products' => $this->getMockProducts('watches', 3)
                ];
            }
        }
        
        // Check if query is about electronics
        if ($this->isElectronicsQuery($message)) {
            return [
                'type' => 'product_suggestion',
                'content' => 'Our electronics department features the latest gadgets and home appliances. We have everything from smartphones to kitchen appliances.',
                'products' => $this->getMockProducts('electronics', 3)
            ];
        }

        // Generic product query
        return [
            'type' => 'text',
            'content' => 'We offer a variety of watches and electronic products. Could you specify what type of product you\'re interested in? For example, "smartwatches", "wall clocks", or "home electronics"?'
        ];
    }

    /**
     * Get mock products since we're not using a database
     * 
     * @param string $category
     * @param int $count
     * @return array
     */
    private function getMockProducts(string $category, int $count): array
    {
        $products = [];
        
        $mockData = [
            'watches' => [
                ['name' => 'Classic Analog Watch', 'price' => 129.99, 'image' => '/images/products/watch1.jpg'],
                ['name' => 'Sports Chronograph', 'price' => 199.99, 'image' => '/images/products/watch2.jpg'],
                ['name' => 'Luxury Gold Watch', 'price' => 499.99, 'image' => '/images/products/watch3.jpg'],
                ['name' => 'Minimalist Watch', 'price' => 149.99, 'image' => '/images/products/watch4.jpg']
            ],
            'smart watches' => [
                ['name' => 'Fitness Tracker Pro', 'price' => 149.99, 'image' => '/images/products/smartwatch1.jpg'],
                ['name' => 'Health Monitor Watch', 'price' => 199.99, 'image' => '/images/products/smartwatch2.jpg'],
                ['name' => 'Sports Smart Watch', 'price' => 229.99, 'image' => '/images/products/smartwatch3.jpg']
            ],
            'wall clocks' => [
                ['name' => 'Modern Minimalist Clock', 'price' => 59.99, 'image' => '/images/products/clock1.jpg'],
                ['name' => 'Vintage Wall Clock', 'price' => 89.99, 'image' => '/images/products/clock2.jpg'],
                ['name' => 'Designer Statement Clock', 'price' => 129.99, 'image' => '/images/products/clock3.jpg']
            ],
            'electronics' => [
                ['name' => 'Wireless Earbuds', 'price' => 129.99, 'image' => '/images/products/electronics1.jpg'],
                ['name' => 'Bluetooth Speaker', 'price' => 79.99, 'image' => '/images/products/electronics2.jpg'],
                ['name' => 'Smart Home Hub', 'price' => 149.99, 'image' => '/images/products/electronics3.jpg']
            ]
        ];
        
        // Default to watches if category not found
        $categoryData = $mockData[$category] ?? $mockData['watches'];
        
        // Get requested number of products
        for ($i = 0; $i < min($count, count($categoryData)); $i++) {
            $product = $categoryData[$i];
            $products[] = [
                'id' => $i + 1,
                'name' => $product['name'],
                'price' => $product['price'],
                'image' => $product['image'],
                'url' => route('catalog.product', ['product' => strtolower(str_replace(' ', '-', $product['name']))])
            ];
        }
        
        return $products;
    }

    /**
     * Check if the message is related to watches
     *
     * @param string $message
     * @return bool
     */
    private function isWatchQuery(string $message): bool
    {
        $watchKeywords = ['watch', 'watches', 'wristwatch', 'smartwatch', 'digital watch', 'analog watch', 'clock', 'timepiece'];
        
        foreach ($watchKeywords as $keyword) {
            if (str_contains($message, $keyword)) {
                return true;
            }
        }
        
        return false;
    }

    /**
     * Check if the message is related to electronics
     *
     * @param string $message
     * @return bool
     */
    private function isElectronicsQuery(string $message): bool
    {
        $electronicsKeywords = ['electronic', 'electronics', 'gadget', 'device', 'appliance', 'smartphone', 'laptop', 'tv', 'television', 'headphone'];
        
        foreach ($electronicsKeywords as $keyword) {
            if (str_contains($message, $keyword)) {
                return true;
            }
        }
        
        return false;
    }

    /**
     * Check if the message is about shipping or delivery
     *
     * @param string $message
     * @return bool
     */
    private function isShippingQuery(string $message): bool
    {
        $shippingKeywords = ['shipping', 'delivery', 'ship', 'deliver', 'when will it arrive', 'how long does it take', 'shipping cost', 'shipping fee'];
        
        foreach ($shippingKeywords as $keyword) {
            if (str_contains($message, $keyword)) {
                return true;
            }
        }
        
        return false;
    }

    /**
     * Check if the message is about return policy
     *
     * @param string $message
     * @return bool
     */
    private function isReturnQuery(string $message): bool
    {
        $returnKeywords = ['return', 'refund', 'send back', 'exchange', 'money back'];
        
        foreach ($returnKeywords as $keyword) {
            if (str_contains($message, $keyword)) {
                return true;
            }
        }
        
        return false;
    }

    /**
     * Check if the message is about payment methods
     *
     * @param string $message
     * @return bool
     */
    private function isPaymentQuery(string $message): bool
    {
        $paymentKeywords = ['payment', 'pay', 'credit card', 'debit card', 'paypal', 'apple pay', 'google pay', 'payment method'];
        
        foreach ($paymentKeywords as $keyword) {
            if (str_contains($message, $keyword)) {
                return true;
            }
        }
        
        return false;
    }

    /**
     * Check if the message is about warranty
     *
     * @param string $message
     * @return bool
     */
    private function isWarrantyQuery(string $message): bool
    {
        $warrantyKeywords = ['warranty', 'guarantee', 'broken', 'defect', 'repair'];
        
        foreach ($warrantyKeywords as $keyword) {
            if (str_contains($message, $keyword)) {
                return true;
            }
        }
        
        return false;
    }
}