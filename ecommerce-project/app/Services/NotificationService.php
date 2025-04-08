<?php

namespace App\Services;

use App\Models\Notification;
use App\Models\User;
use Illuminate\Support\Facades\Auth;

class NotificationService
{
    public function createNotification(User $user, array $data)
    {
        return Notification::create([
            'user_id' => $user->id,
            'title' => $data['title'],
            'message' => $data['message'],
            'type' => $data['type'] ?? 'account',
            'is_read' => false
        ]);
    }

    public function getUserNotifications()
    {
        return Notification::where('user_id', Auth::id())
            ->latest()
            ->paginate(20);
    }

    public function markAsRead(Notification $notification)
    {
        $notification->update(['is_read' => true]);
        return $notification;
    }

    public function markAllAsRead()
    {
        return Notification::where('user_id', Auth::id())
            ->update(['is_read' => true]);
    }

    public function sendOrderNotification(User $user, $order)
    {
        return $this->createNotification($user, [
            'title' => 'Order Status Update',
            'message' => "Your order #$order->id status has been updated to {$order->status}",
            'type' => 'order'
        ]);
    }

    public function sendPaymentNotification(User $user, $payment)
    {
        return $this->createNotification($user, [
            'title' => 'Payment Notification',
            'message' => "Payment for order #{$payment->order_id} is {$payment->status}",
            'type' => 'payment'
        ]);
    }
}