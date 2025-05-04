<?php

namespace App\Services;

use App\Models\Order;
use App\Models\Payment;
use Stripe\Stripe;
use Stripe\Charge;
use Illuminate\Support\Facades\Log;

class PaymentService
{
    /**
     * Process a payment for an order
     *
     * @param Order $order
     * @param string $paymentMethod
     * @return Payment
     * @throws \Exception
     */
    public function processPayment(Order $order, string $paymentMethod): Payment
    {
        Log::info('Processing payment', [
            'order_id' => $order->id,
            'payment_method' => $paymentMethod,
            'amount' => $order->total_amount
        ]);

        try {
            switch ($paymentMethod) {
                case 'stripe':
                    return $this->processStripePayment($order);
                case 'paypal':
                    return $this->processPayPalPayment($order);
                case 'bank_transfer':
                    return $this->processOfflinePayment($order, 'bank_transfer');
                case 'cash':
                    return $this->processOfflinePayment($order, 'cash');
                case 'credit_card':
                    return $this->processOfflinePayment($order, 'credit_card');
                default:
                    throw new \Exception('Unsupported payment method: ' . $paymentMethod);
            }
        } catch (\Exception $e) {
            Log::error('Payment processing error: ' . $e->getMessage(), [
                'order_id' => $order->id,
                'payment_method' => $paymentMethod,
                'exception' => $e
            ]);
            throw $e;
        }
    }

    /**
     * Process a Stripe payment
     *
     * @param Order $order
     * @return Payment
     * @throws \Exception
     */
    private function processStripePayment(Order $order): Payment
    {
        Log::info('Processing Stripe payment for order', ['order_id' => $order->id]);
        
        // Make sure we have the Stripe token
        $stripeToken = request('stripe_token');
        if (!$stripeToken) {
            throw new \Exception('Stripe token is required');
        }

        Stripe::setApiKey(config('services.stripe.secret'));

        $charge = Charge::create([
            'amount' => (int)($order->total_amount * 100), // Amount in cents
            'currency' => 'usd',
            'source' => $stripeToken,
            'description' => 'Order #' . $order->id
        ]);

        $payment = Payment::create([
            'order_id' => $order->id,
            'payment_method' => 'stripe',
            'amount' => $order->total_amount,
            'status' => 'completed',
            'transaction_id' => $charge->id,
            'transaction_date' => now()
        ]);

        // Update order status
        $order->status = 'paid';
        $order->save();

        Log::info('Stripe payment processed successfully', [
            'payment_id' => $payment->id, 
            'transaction_id' => $charge->id
        ]);

        return $payment;
    }

    /**
     * Process a PayPal payment
     *
     * @param Order $order
     * @return Payment
     */
    private function processPayPalPayment(Order $order): Payment
    {
        Log::info('Processing PayPal payment for order', ['order_id' => $order->id]);
        
        // This would typically integrate with PayPal's API
        // For now, we'll just create a payment record
        $payment = Payment::create([
            'order_id' => $order->id,
            'payment_method' => 'paypal',
            'amount' => $order->total_amount,
            'status' => 'completed',
            'transaction_id' => 'PAYPAL_' . uniqid(),
            'transaction_date' => now()
        ]);

        // Update order payment status
        $order->payment_status = 'paid';
        $order->save();

        Log::info('PayPal payment processed successfully', [
            'payment_id' => $payment->id,
            'transaction_id' => $payment->transaction_id
        ]);

        return $payment;
    }

    /**
     * Process an offline payment (bank transfer, cash, or credit card)
     *
     * @param Order $order
     * @param string $paymentMethod
     * @return Payment
     */
    private function processOfflinePayment(Order $order, string $paymentMethod): Payment
    {
        Log::info('Processing offline payment for order', [
            'order_id' => $order->id,
            'payment_method' => $paymentMethod
        ]);

        $payment = Payment::create([
            'order_id' => $order->id,
            'payment_method' => $paymentMethod,
            'amount' => $order->total_amount,
            'status' => 'pending', // Usually offline payments start as pending
            'transaction_id' => 'OFFLINE-' . time(),
            'reference' => request('reference') ?? null,
            'transaction_date' => request('transaction_date') ?? now()
        ]);

        // Update order status to 'pending' for offline payments
        // Since these usually need manual verification
        // Only update if current status is 'pending' to avoid overwriting other statuses
        if ($order->status === 'pending') {
            $order->status = 'pending_payment';
            $order->save();
        }

        Log::info('Offline payment recorded', [
            'payment_id' => $payment->id,
            'payment_method' => $paymentMethod
        ]);

        return $payment;
    }

    /**
     * Refund a payment
     *
     * @param Payment $payment
     * @return Payment
     * @throws \Exception
     */
    public function refundPayment(Payment $payment): Payment
    {
        Log::info('Processing refund request', [
            'payment_id' => $payment->id,
            'payment_method' => $payment->payment_method
        ]);

        if ($payment->status !== 'completed') {
            throw new \Exception('Only completed payments can be refunded');
        }

        try {
            // Process refund based on payment method
            switch ($payment->payment_method) {
                case 'stripe':
                    return $this->processStripeRefund($payment);
                case 'paypal':
                    return $this->processPayPalRefund($payment);
                case 'bank_transfer':
                case 'cash':
                case 'credit_card':
                    return $this->processOfflineRefund($payment);
                default:
                    throw new \Exception('Unsupported payment method for refund');
            }
        } catch (\Exception $e) {
            Log::error('Payment refund failed: ' . $e->getMessage(), [
                'payment_id' => $payment->id,
                'exception' => $e
            ]);
            throw $e;
        }
    }

    /**
     * Process a Stripe refund
     *
     * @param Payment $payment
     * @return Payment
     */
    private function processStripeRefund(Payment $payment): Payment
    {
        Log::info('Processing Stripe refund', ['payment_id' => $payment->id]);

        // Set Stripe API key
        Stripe::setApiKey(config('services.stripe.secret'));

        // Process the refund through Stripe
        $refund = \Stripe\Refund::create([
            'charge' => $payment->transaction_id,
        ]);

        // Update payment status
        $payment->status = 'refunded';
        $payment->refund_id = $refund->id;
        $payment->refunded_at = now();
        $payment->save();

        // Update related order
        $order = $payment->order;
        $order->status = 'refunded';
        $order->save();

        Log::info('Stripe refund processed successfully', [
            'payment_id' => $payment->id,
            'refund_id' => $refund->id
        ]);

        return $payment;
    }

    /**
     * Process a PayPal refund
     *
     * @param Payment $payment
     * @return Payment
     */
    private function processPayPalRefund(Payment $payment): Payment
    {
        Log::info('Processing PayPal refund', ['payment_id' => $payment->id]);

        // This would typically integrate with PayPal's API for refunds
        // For now, we'll just update the payment record

        // Update payment status
        $payment->status = 'refunded';
        $payment->refund_id = 'PAYPAL_REFUND_' . uniqid();
        $payment->refunded_at = now();
        $payment->save();

        // Update related order
        $order = $payment->order;
        $order->status = 'refunded';
        $order->save();

        Log::info('PayPal refund processed successfully', [
            'payment_id' => $payment->id,
            'refund_id' => $payment->refund_id
        ]);

        return $payment;
    }

    /**
     * Process an offline refund
     *
     * @param Payment $payment
     * @return Payment
     */
    private function processOfflineRefund(Payment $payment): Payment
    {
        Log::info('Processing offline refund', [
            'payment_id' => $payment->id,
            'payment_method' => $payment->payment_method
        ]);

        // Update payment status
        $payment->status = 'refunded';
        $payment->refund_id = 'OFFLINE_REFUND_' . time();
        $payment->refunded_at = now();
        $payment->save();

        // Update related order
        $order = $payment->order;
        $order->status = 'refunded';
        $order->save();

        Log::info('Offline refund processed successfully', [
            'payment_id' => $payment->id
        ]);

        return $payment;
    }
}