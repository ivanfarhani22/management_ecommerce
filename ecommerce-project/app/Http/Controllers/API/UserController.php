<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\AuthService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class UserController extends Controller
{
    protected $authService;

    public function __construct(AuthService $authService)
    {
        $this->authService = $authService;
        // Remove middleware from constructor - it will be handled in routes
    }

    /**
     * Get authenticated user's profile
     *
     * @return JsonResponse
     */
    public function profile(): JsonResponse
    {
        $user = Auth::user();
        return response()->json([
            'success' => true,
            'data' => $user->load(['addresses', 'orders'])
        ]);
    }

    /**
     * Update authenticated user's profile
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function updateProfile(Request $request): JsonResponse
    {
        $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|unique:users,email,' . Auth::id(),
        ]);

        $user = Auth::user();
        $updatedUser = $this->authService->updateProfile($user, $request->all());

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data' => $updatedUser
        ]);
    }

    /**
     * Get a user by ID (public method)
     *
     * @param int $id
     * @return JsonResponse
     */
    public function show($id): JsonResponse
    {
        try {
            $user = User::findOrFail($id);
            
            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    // Add other user fields you need, but exclude sensitive data
                ]
            ]);
        } catch (\Exception $e) {
            Log::error('Error fetching user', [
                'user_id' => $id,
                'error' => $e->getMessage()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'User not found'
            ], 404);
        }
    }

    /**
     * Get multiple users by their IDs (public method)
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function getMultipleUsers(Request $request): JsonResponse
    {
        // Check both JSON and form data inputs
        $ids = $request->input('ids', []);
        
        // Add debug logging
        Log::info('Batch user request received', [
            'input' => $request->all(),
            'ids' => $ids
        ]);
        
        // Handle different input formats
        if (is_string($ids)) {
            try {
                $ids = json_decode($ids, true);
                if (json_last_error() !== JSON_ERROR_NONE) {
                    // If not valid JSON, try comma separated
                    $ids = explode(',', $ids);
                }
            } catch (\Exception $e) {
                // If not valid JSON, try comma separated
                $ids = explode(',', $ids);
            }
        }
        
        if (empty($ids)) {
            return response()->json([
                'success' => false,
                'message' => 'No user IDs provided'
            ], 400);
        }
        
        try {
            // Convert all IDs to integers
            $ids = array_map('intval', (array)$ids);
            
            Log::info('Fetching users with IDs', ['ids' => $ids]);
            
            $users = User::whereIn('id', $ids)->get();
            
            if ($users->isEmpty()) {
                Log::warning('No users found for the provided IDs', ['ids' => $ids]);
                return response()->json([
                    'success' => true,
                    'data' => []
                ]);
            }
            
            $userData = $users->map(function ($user) {
                return [
                    'id' => $user->id,
                    'name' => $user->name,
                    // Add other fields as needed
                ];
            });
            
            return response()->json([
                'success' => true,
                'data' => $userData
            ]);
        } catch (\Exception $e) {
            Log::error('Error fetching batch users', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch users: ' . $e->getMessage()
            ], 500);
        }
    }
}