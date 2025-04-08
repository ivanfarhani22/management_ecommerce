@extends('layouts.app')

@section('content')
<div class="container">
    <h1>Order #{{ $order->id }}</h1>
    <div class="order-details">
        <h2>Order Information</h2>
        <p>Date: {{ $order->created_at->format('d M Y H:i') }}</p>
        <p>Status: {{ $order->status }}</p>

        <h2>Items</h2>
        <table class="table">
            <thead>
                <tr>
                    <th>Product</th>
                    <th>Quantity</th>
                    <th>Price</th>
                    <th>Subtotal</th>
                </tr>
            </thead>
            <tbody>
                @foreach($order->items as $item)
                    <tr>
                        <td>{{ $item->product->name }}</td>
                        <td>{{ $item->quantity }}</td>
                        <td>{{ number_format($item->price, 2) }}</td>
                        <td>{{ number_format($item->quantity * $item->price, 2) }}</td>
                    </tr>
                @endforeach
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="3">Total</td>
                    <td>{{ number_format($order->total, 2) }}</td>
                </tr>
            </tfoot>
        </table>
    </div>
</div>
@endsection