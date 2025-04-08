<?php

namespace App\Http\Requests\Product;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProductRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        // You might want to add authorization logic here
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
            'name' => ['sometimes', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'price' => ['sometimes', 'numeric', 'min:0'],
            'stock' => ['sometimes', 'integer', 'min:0'],
            'category_id' => ['sometimes', 'exists:categories,id'],
            'brand_id' => ['nullable', 'exists:brands,id'],
            'images' => ['sometimes', 'array', 'max:5'],
            'images.*' => ['image', 'mimes:jpeg,png,jpg,gif', 'max:2048'],
            'is_active' => ['sometimes', 'boolean']
        ];
    }

    /**
     * Get custom error messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'name.max' => 'Product name cannot exceed 255 characters.',
            'price.numeric' => 'Price must be a number.',
            'price.min' => 'Price cannot be negative.',
            'stock.integer' => 'Stock must be a whole number.',
            'stock.min' => 'Stock cannot be negative.',
            'category_id.exists' => 'Selected category is invalid.',
            'images.max' => 'You can upload a maximum of 5 images.',
            'images.*.image' => 'Uploaded files must be images.',
            'images.*.mimes' => 'Images must be in JPEG, PNG, JPG, or GIF format.',
            'images.*.max' => 'Each image cannot exceed 2MB.'
        ];
    }
}