<?php
namespace App\Services;

use Illuminate\Support\Facades\Cache;

class ChatbotService
{
    public function processMessage(string $message, ?int $userId = null): array
    {
        if ($userId) {
            $this->storeMessage($userId, 'user', $message);
        }

        $responseText = $this->generateResponse($message);

        if ($userId) {
            $this->storeMessage($userId, 'bot', $responseText);
        }

        return [
            'type' => 'text',
            'content' => $responseText
        ];
    }

    public function getChatHistory(int $userId): array
    {
        return Cache::get("chat_history_{$userId}", []);
    }

    public function clearChatHistory(int $userId): void
    {
        Cache::forget("chat_history_{$userId}");
    }

    protected function storeMessage(int $userId, string $sender, string $message): void
    {
        $history = Cache::get("chat_history_{$userId}", []);
        $history[] = [
            'sender' => $sender,
            'message' => $message,
            'timestamp' => now()->toDateTimeString()
        ];
        Cache::put("chat_history_{$userId}", $history, now()->addDays(1));
    }

    protected function generateResponse(string $message): string
    {
        $message = strtolower($message);
        return match (true) {
            str_contains($message, 'hello') => 'Hi there! How can I assist you?',
            str_contains($message, 'watch') => 'We have premium watches starting at $99.',
            str_contains($message, 'shipping') => 'We offer free shipping on orders over $50.',
            str_contains($message, 'payment') => 'We accept Visa, PayPal, and bank transfer.',
            default => "I'm not sure I understand. Could you rephrase?"
        };
    }
}
