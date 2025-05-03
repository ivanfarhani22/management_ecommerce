<?php

namespace App\Policies;

use App\Models\Order;
use App\Models\User;

class OrderPolicy
{
    /**
     * Only allow user to view their own orders
     */
    public function view(User $user, Order $order)
    {
        return $user->id === $order->user_id;
    }

    /**
     * Allow user to cancel their own order
     */
    public function cancel(User $user, Order $order)
    {
        return $user->id === $order->user_id;
    }
}
