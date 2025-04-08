<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Services\AuthService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class UserController extends Controller
{
    protected $authService;

    public function __construct(AuthService $authService)
    {
        $this->middleware('auth:sanctum');
        $this->authService = $authService;
    }

    public function profile()
    {
        $user = Auth::user();
        return response()->json([
            'user' => $user->load(['addresses', 'orders'])
        ]);
    }

    public function updateProfile(Request $request)
    {
        $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|unique:users,email,' . Auth::id(),
        ]);

        $user = Auth::user();
        $updatedUser = $this->authService->updateProfile($user, $request->all());

        return response()->json([
            'message' => 'Profile updated successfully',
            'user' => $updatedUser
        ]);
    }
}