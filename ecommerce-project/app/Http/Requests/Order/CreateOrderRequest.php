<?php

namespace App\Http\Requests\Order;

use Illuminate\Foundation\Http\FormRequest;

class CreateOrderRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'shipping_address' => ['required', 'string', 'max:500'],
            'billing_address' => ['sometimes', 'string', 'max:500'],
            'payment_method' => ['required', 'in:credit_card,paypal,bank_transfer,cash'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'exists:products,id'],
            'items.*.quantity' => ['required', 'integer', 'min:1'],
            'items.*.price' => ['required', 'numeric', 'min:0'],
            'total_amount' => ['required', 'numeric', 'min:0'],
            'shipping_method' => ['sometimes', 'string'],
            'notes' => ['nullable', 'string', 'max:1000']
        ];
    }

    /**
     * Get custom error messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'shipping_address.required' => 'Shipping address is required.',
            'shipping_address.max' => 'Shipping address cannot exceed 500 characters.',
            'payment_method.required' => 'Payment method is required.',
            'payment_method.in' => 'Invalid payment method selected.',
            'items.required' => 'Order must contain at least one item.',
            'items.*.product_id.required' => 'Product ID is required for each order item.',
            'items.*.product_id.exists' => 'Selected product does not exist.',
            'items.*.quantity.required' => 'Quantity is required for each order item.',
            'items.*.quantity.min' => 'Quantity must be at least 1.',
            'items.*.price.required' => 'Price is required for each order item.',
            'items.*.price.min' => 'Price cannot be negative.',
            'total_amount.required' => 'Total order amount is required.',
            'total_amount.min' => 'Total order amount cannot be negative.',
            'notes.max' => 'Order notes cannot exceed 1000 characters.'
        ];
    }
}