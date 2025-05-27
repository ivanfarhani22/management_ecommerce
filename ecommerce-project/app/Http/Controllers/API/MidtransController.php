<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\MidtransService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class MidtransController extends Controller
{
    protected $midtransService;

    public function __construct(MidtransService $midtransService)
    {
        $this->midtransService = $midtransService;
    }

    public function notification(Request $request)
    {
        try {
            Log::info('Midtrans notification webhook received', [
                'headers' => $request->headers->all(),
                'body' => $request->all()
            ]);

            $notification = $request->all();
            
            // Handle the notification
            $result = $this->midtransService->handleNotification($notification);
            
            if ($result) {
                Log::info('Midtrans notification processed successfully');
                return response()->json(['status' => 'success'], 200);
            } else {
                Log::error('Failed to process Midtrans notification');
                return response()->json(['status' => 'failed'], 400);
            }

        } catch (\Exception $e) {
            Log::error('Error processing Midtrans notification', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'request' => $request->all()
            ]);
            
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }
}