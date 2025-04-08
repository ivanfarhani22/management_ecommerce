<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class CheckRole
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next, ...$roles): Response
    {
        // Check if user is authenticated
        if (!Auth::check()) {
            return redirect()->route('login');
        }

        // Get the current user's role
        $userRole = Auth::user()->role;

        // Check if user's role matches any of the allowed roles
        if (empty($roles) || in_array($userRole, $roles)) {
            return $next($request);
        }

        // Unauthorized access
        return $this->handleUnauthorizedAccess($request);
    }

    /**
     * Handle unauthorized access attempts
     */
    protected function handleUnauthorizedAccess(Request $request): Response
    {
        // If ajax/api request, return 403 Forbidden
        if ($request->expectsJson()) {
            return response()->json([
                'message' => 'Unauthorized access'
            ], 403);
        }

        // For web requests, redirect with error message
        return redirect()->route('home')->with([
            'error' => 'You do not have permission to access this page.',
            'alert-type' => 'error'
        ]);
    }
}