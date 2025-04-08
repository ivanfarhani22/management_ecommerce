<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;

// Schedule the inspiring quote command to run daily
Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->describe('Display an inspiring quote');

// Custom command to clear application caches
Artisan::command('app:clear', function () {
    $this->call('config:clear');
    $this->call('cache:clear');
    $this->call('view:clear');
    $this->call('route:clear');

    $this->info('All application caches have been cleared.');
})->describe('Clear all application caches');

// Custom command to reset application state (useful for development)
Artisan::command('app:reset', function () {
    if (app()->environment('local')) {
        $this->call('migrate:fresh');
        $this->call('db:seed');
        $this->call('passport:install');
        
        $this->info('Application reset completed.');
    } else {
        $this->error('This command can only be run in local environment.');
    }
})->describe('Reset application state (local only)');