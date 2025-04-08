<?php

namespace App\Http\Middleware;

use Illuminate\Auth\Middleware\Authenticate as Middleware;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

class Authenticate extends Middleware
{
    /**
     * Get the path the user should be redirected to when they are not authenticated.
     */
    protected function redirectTo(Request $request): ?string
    {
        // If it's an API request, return null to send a 401 Unauthorized response
        if ($request->expectsJson()) {
            return null;
        }

        // Redirect to login page with intended URL
        return route('login', [
            'redirect' => $request->fullUrl()
        ]);
    }
}