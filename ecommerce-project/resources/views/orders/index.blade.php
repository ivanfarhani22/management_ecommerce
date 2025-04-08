@extends('layouts.app')

@section('content')
<div class="container">
    <h1>My Orders</h1>
    @if($orders->count() > 0)
        <table class="table">
            <thead>
                <tr>
                    <th>Order ID</th>
                    <th>Date</th>
                    <th>Total</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach($orders as $order)
                    <tr>
                        <td>{{ $order->id }}</td>
                        <td>{{ $order->created_at->format('d M Y') }}</td>
                        <td>{{ number_format($order->total, 2) }}</td>
                        <td>{{ $order->status }}</td>
                        <td>
                            <a href="{{ route('orders.detail', $order->id) }}" class="btn btn-sm btn-info">View Details</a>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    @else
        <p>No orders found.</p>
    @endif
</div>
@endsection