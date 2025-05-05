<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Chatbot Configuration
    |--------------------------------------------------------------------------
    |
    | This file contains configuration settings for the chatbot functionality.
    |
    */

    // Maximum number of conversation history items to store per user
    'max_history_items' => env('CHATBOT_MAX_HISTORY', 50),

    // Number of days to keep chat history before auto-deleting
    'history_ttl_days' => env('CHATBOT_HISTORY_TTL', 30),

    // Whether to log chatbot interactions
    'enable_log' => env('CHATBOT_ENABLE_LOG', false),

    // OpenAI Configuration (for future expansion)
    'openai' => [
        'api_key' => env('OPENAI_API_KEY'),
        'model' => env('OPENAI_MODEL', 'gpt-3.5-turbo'),
    ],

];