<?php

namespace App\Http\Requests\Order;

use Illuminate\Foundation\Http\FormRequest;

class UpdateOrderRequest extends FormRequest
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
            'shipping_address' => ['sometimes', 'string', 'max:500'],
            'billing_address' => ['sometimes', 'string', 'max:500'],
            'payment_method' => ['sometimes', 'in:credit_card,paypal,bank_transfer,cash'],
            'items' => ['sometimes', 'array', 'min:1'],
            'items.*.product_id' => ['sometimes', 'exists:products,id'],
            'items.*.quantity' => ['sometimes', 'integer', 'min:1'],
            'items.*.price' => ['sometimes', 'numeric', 'min:0'],
            'total_amount' => ['sometimes', 'numeric', 'min:0'],
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
            'shipping_address.max' => 'Shipping address cannot exceed 500 characters.',
            'payment_method.in' => 'Invalid payment method selected.',
            'items.min' => 'Order must contain at least one item.',
            'items.*.product_id.exists' => 'Selected product does not exist.',
            'items.*.quantity.min' => 'Quantity must be at least 1.',
            'items.*.price.min' => 'Price cannot be negative.',
            'total_amount.min' => 'Total order amount cannot be negative.',
            'notes.max' => 'Order notes cannot exceed 1000 characters.'
        ];
    }
}