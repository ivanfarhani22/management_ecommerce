<?php

namespace App\Services;

use OpenAI\Client;
use Illuminate\Support\Facades\Log;

class ChatbotService
{
    protected $openai;

    public function __construct()
    {
        $this->openai = new Client(config('services.openai.api_key'));
    }

    public function generateResponse($userMessage)
    {
        try {
            $response = $this->openai->chat()->create([
                'model' => 'gpt-3.5-turbo',
                'messages' => [
                    [
                        'role' => 'system', 
                        'content' => 'You are a helpful customer support chatbot for an e-commerce store.'
                    ],
                    [
                        'role' => 'user', 
                        'content' => $userMessage
                    ]
                ]
            ]);

            return $response->choices[0]->message->content;
        } catch (\Exception $e) {
            Log::error('Chatbot error: ' . $e->getMessage());
            return 'I apologize, but I am unable to process your request at the moment.';
        }
    }

    public function classifyIntent($message)
    {
        $intents = [
            'order_status' => ['track', 'status', 'where', 'shipping'],
            'returns' => ['return', 'refund', 'exchange'],
            'product_inquiry' => ['product', 'details', 'information'],
            'support' => ['help', 'support', 'problem', 'issue']
        ];

        $message = strtolower($message);

        foreach ($intents as $intent => $keywords) {
            foreach ($keywords as $keyword) {
                if (strpos($message, $keyword) !== false) {
                    return $intent;
                }
            }
        }

        return 'general';
    }
}