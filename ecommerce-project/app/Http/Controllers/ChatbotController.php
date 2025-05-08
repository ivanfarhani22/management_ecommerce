<?php

namespace App\Http\Controllers;

use App\Services\ChatbotService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;

class ChatbotController extends Controller
{
    protected $chatbotService;

    public function __construct(ChatbotService $chatbotService)
    {
        $this->chatbotService = $chatbotService;
    }

    public function sendMessage(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'message' => 'required|string|max:500',
                'user_id' => 'sometimes|integer'
            ]);

            $message = $validated['message'];
            $userId = $validated['user_id'] ?? null;

            $response = $this->chatbotService->processMessage($message, $userId);

            return response()->json($response);
        } catch (\Throwable $e) {
            Log::error('Chatbot error: ' . $e->getMessage());

            return response()->json([
                'type' => 'text',
                'content' => config('app.debug')
                    ? 'Error: ' . $e->getMessage()
                    : 'An error occurred while processing your message.'
            ], 500);
        }
    }

    public function getHistory(Request $request): JsonResponse
    {
        $validated = $request->validate(['user_id' => 'required|integer']);
        $history = $this->chatbotService->getChatHistory($validated['user_id']);
        return response()->json(['success' => true, 'history' => $history]);
    }

    public function clearHistory(Request $request): JsonResponse
    {
        $validated = $request->validate(['user_id' => 'required|integer']);
        $this->chatbotService->clearChatHistory($validated['user_id']);
        return response()->json(['success' => true, 'message' => 'Chat history cleared.']);
    }
}
