<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class ProfileController extends Controller
{
    /**
     * Display the user's profile (alias for show method).
     */
    public function index()
    {
        $user = Auth::user();
        return view('profile.index', compact('user'));
    }

    /**
     * Show the form for editing the user's profile.
     */
    public function edit()
    {
        $user = Auth::user();
        return view('profile.edit', compact('user'));
    }

    /**
     * Update the user's profile information.
     */
    public function update(Request $request)
    {
        $user = Auth::user();

        // Validation rules
        $rules = [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', Rule::unique('users')->ignore($user->id)],
            'phone' => ['nullable', 'string', 'max:20'], // Tambahkan validasi untuk phone
            'avatar' => ['nullable', 'image', 'mimes:jpeg,png,jpg,gif', 'max:2048'], // Max 2MB
        ];

        $validatedData = $request->validate($rules);

        // Handle avatar upload
        if ($request->hasFile('avatar')) {
            // Delete old avatar if exists
            if ($user->avatar && Storage::disk('public')->exists('avatars/' . $user->avatar)) {
                Storage::disk('public')->delete('avatars/' . $user->avatar);
            }

            // Store new avatar
            $avatarFile = $request->file('avatar');
            $avatarName = time() . '_' . $user->id . '.' . $avatarFile->getClientOriginalExtension();
            $avatarPath = $avatarFile->storeAs('avatars', $avatarName, 'public');
            
            // Update user avatar field with just the filename
            $validatedData['avatar'] = $avatarName;
        }

        // Update user data
        $user->update([
            'name' => $validatedData['name'],
            'email' => $validatedData['email'],
            'phone' => $validatedData['phone'], // Pastikan phone di-update
            'avatar' => $validatedData['avatar'] ?? $user->avatar, // Keep existing avatar if no new one uploaded
        ]);

        return redirect()->route('profile.edit')->with('success', 'Profile updated successfully!');
    }

    /**
     * Show the user's profile.
     */
    public function show()
    {
        $user = Auth::user();
        return view('profile.index', compact('user'));
    }
}