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
    }

    /**
     * Get list of all users (public method)
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(): JsonResponse
    {
        try {
            $users = User::all(['id', 'name', 'email'])->map(function ($user) {
                return [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $users
            ], 200, [
                'Content-Type' => 'application/json'
            ]);
        } catch (\Exception $e) {
            Log::error('Error fetching all users', [
                'error' => $e->getMessage()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch users'
            ], 500);
        }
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
                    'phone' => $user->phone
                ]
            ], 200, [
                'Content-Type' => 'application/json'
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
        $ids = $request->input('ids', []);
        
        Log::info('Batch user request received', [
            'input' => $request->all(),
            'ids' => $ids
        ]);
        
        if (is_string($ids)) {
            try {
                $ids = json_decode($ids, true);
                if (json_last_error() !== JSON_ERROR_NONE) {
                    $ids = explode(',', $ids);
                }
            } catch (\Exception $e) {
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
            $ids = array_map('intval', (array)$ids);
            
            $users = User::whereIn('id', $ids)->get(['id', 'name', 'email']);
            
            if ($users->isEmpty()) {
                return response()->json([
                    'success' => true,
                    'data' => []
                ]);
            }
            
            $userData = $users->map(function ($user) {
                return [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
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