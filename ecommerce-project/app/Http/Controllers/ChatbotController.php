<?php

namespace App\Http\Controllers;

use App\Services\ChatbotService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;

class ChatbotController extends Controller
{
    protected $chatbotService;

    /**
     * Constructor with ChatbotService dependency injection
     */
    public function __construct(ChatbotService $chatbotService)
    {
        $this->chatbotService = $chatbotService;
    }

    /**
     * Process incoming chatbot message
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function sendMessage(Request $request): JsonResponse
    {
        try {
            // Validate request
            $validated = $request->validate([
                'message' => 'required|string|max:500',
                'user_id' => 'sometimes|integer'
            ]);

            $message = $validated['message'];
            $userId = $request->input('user_id');

            // Process the message
            $response = $this->chatbotService->processMessage($message, $userId);

            // Return successful response
            return response()->json([
                'success' => true,
                'response' => $response
            ]);
        } catch (\Exception $e) {
            // Log error
            Log::error('Chatbot error: ' . $e->getMessage(), [
                'trace' => $e->getTraceAsString()
            ]);

            // Return error response
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while processing your message.',
                'error' => config('app.debug') ? $e->getMessage() : null
            ], 500);
        }
    }

    /**
     * Get chat history for a user
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function getHistory(Request $request): JsonResponse
    {
        try {
            // Validate request
            $validated = $request->validate([
                'user_id' => 'required|integer'
            ]);

            $userId = $validated['user_id'];
            
            // Get chat history
            $history = $this->chatbotService->getChatHistory($userId);

            // Return successful response
            return response()->json([
                'success' => true,
                'history' => $history
            ]);
        } catch (\Exception $e) {
            // Log error
            Log::error('Chatbot history error: ' . $e->getMessage(), [
                'trace' => $e->getTraceAsString()
            ]);

            // Return error response
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving chat history.',
                'error' => config('app.debug') ? $e->getMessage() : null
            ], 500);
        }
    }

    /**
     * Clear chat history for a user
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function clearHistory(Request $request): JsonResponse
    {
        try {
            // Validate request
            $validated = $request->validate([
                'user_id' => 'required|integer'
            ]);

            $userId = $validated['user_id'];
            
            // Clear chat history
            $this->chatbotService->clearChatHistory($userId);

            // Return successful response
            return response()->json([
                'success' => true,
                'message' => 'Chat history cleared successfully'
            ]);
        } catch (\Exception $e) {
            // Log error
            Log::error('Chatbot clear history error: ' . $e->getMessage(), [
                'trace' => $e->getTraceAsString()
            ]);

            // Return error response
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while clearing chat history.',
                'error' => config('app.debug') ? $e->getMessage() : null
            ], 500);
        }
    }
}