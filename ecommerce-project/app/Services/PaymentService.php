<?php

namespace App\Services;

use App\Models\Order;
use App\Models\Payment;
use Stripe\Stripe;
use Stripe\Charge;
use Illuminate\Support\Facades\Log;

class PaymentService
{
    public function processPayment(Order $order, string $paymentMethod)
    {
        try {
            switch ($paymentMethod) {
                case 'stripe':
                    return $this->processStripePayment($order);
                case 'paypal':
                    return $this->processPayPalPayment($order);
                default:
                    throw new \Exception('Unsupported payment method');
            }
        } catch (\Exception $e) {
            Log::error('Payment processing error: ' . $e->getMessage());
            throw $e;
        }
    }

    private function processStripePayment(Order $order)
    {
        Stripe::setApiKey(config('services.stripe.secret'));

        $charge = Charge::create([
            'amount' => $order->total_amount * 100, // Amount in cents
            'currency' => 'usd',
            'source' => request('stripe_token'),
            'description' => 'Order #' . $order->id
        ]);

        return Payment::create([
            'order_id' => $order->id,
            'payment_method' => 'stripe',
            'amount' => $order->total_amount,
            'status' => 'completed',
            'transaction_id' => $charge->id
        ]);
    }

    private function processPayPalPayment(Order $order)
    {
        // Implement PayPal payment logic
        // This would typically involve using PayPal's API
        return Payment::create([
            'order_id' => $order->id,
            'payment_method' => 'paypal',
            'amount' => $order->total_amount,
            'status' => 'completed',
            'transaction_id' => 'PAYPAL_' . uniqid()
        ]);
    }

    public function refundPayment(Payment $payment)
    {
        if ($payment->status === 'completed') {
            // Implement refund logic based on payment method
            $payment->update([
                'status' => 'refunded'
            ]);

            return $payment;
        }

        throw new \Exception('Payment cannot be refunded');
    }
}