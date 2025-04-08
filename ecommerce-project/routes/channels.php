<?php

use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('App.Models.User.{id}', function ($user, $id) {
    return (int) $user->id === (int) $id;
});

// Private channel for order updates
Broadcast::channel('orders.{orderId}', function ($user, $orderId) {
    return $user->can('viewOrder', Order::find($orderId));
});

// Private channel for vendor notifications
Broadcast::channel('vendor.{vendorId}', function ($user, $vendorId) {
    return $user->role === 'vendor' && $user->id === (int) $vendorId;
});

// Private channel for admin notifications
Broadcast::channel('admin', function ($user) {
    return $user->role === 'admin';
});