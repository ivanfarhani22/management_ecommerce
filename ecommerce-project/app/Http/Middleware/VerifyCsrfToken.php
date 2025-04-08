<?php

namespace App\Http\Middleware;

use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken as Middleware;

class VerifyCsrfToken extends Middleware
{
    /**
     * The URIs that should be excluded from CSRF verification.
     *
     * @var array<int, string>
     */
    protected $except = [
        // Exclude specific routes from CSRF protection
        // Useful for webhooks, API endpoints, etc.
        // '/webhook/*',
        // '/api/external-service'
    ];

    /**
     * Determine if the request has a valid CSRF token.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return bool
     */
    protected function tokensMatch($request)
    {
        // Optional: Add custom CSRF token validation logic
        // For example, allow certain trusted IP addresses or domains
        
        // Default implementation
        return parent::tokensMatch($request);
    }
}