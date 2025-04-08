<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use App\Exceptions\AuthenticationException;

class AuthService
{
    public function register(array $data)
    {
        try {
            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'password' => Hash::make($data['password']),
                'remember_token' => Str::random(10),
            ]);

            return $user;
        } catch (\Exception $e) {
            throw new AuthenticationException('Registration failed: ' . $e->getMessage());
        }
    }

    public function login(array $credentials)
    {
        if (Auth::attempt($credentials)) {
            $user = Auth::user();
            $token = $user->createToken('AuthToken')->plainTextToken;
            
            return [
                'user' => $user,
                'token' => $token
            ];
        }

        throw new AuthenticationException('Invalid credentials');
    }

    public function logout()
    {
        $user = Auth::user();
        $user->tokens()->delete();
        Auth::logout();
    }

    public function resetPassword(User $user, string $newPassword)
    {
        $user->password = Hash::make($newPassword);
        $user->save();

        return $user;
    }

    public function updateProfile(User $user, array $data)
    {
        $user->fill($data);
        $user->save();

        return $user;
    }
}