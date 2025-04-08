<!DOCTYPE html>
<html>
<head>
    <title>Invoice #{{ $order->id }}</title>
    <style>
        body { font-family: Arial, sans-serif; }
        .invoice-header { text-align: center; }
        .invoice-details { margin-top: 20px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    </style>
</head>
<body>
    <div class="invoice-header">
        <h1>Invoice</h1>
        <p>Invoice #{{ $order->id }}</p>
        <p>Date: {{ $order->created_at->format('d M Y') }}</p>
    </div>

    <div class="invoice-details">
        <h2>Bill To</h2>
        <p>{{ $order->user->name }}</p>
        <p>{{ $order->billingAddress->street }}</p>
        <p>{{ $order->billingAddress->city }}, {{ $order->billingAddress->state }} {{ $order->billingAddress->postal_code }}</p>

        <h2>Order Items</h2>
        <table>
            <thead>
                <tr>
                    <th>Product</th>
                    <th>Quantity</th>
                    <th>Unit Price</th>
                    <th>Total</th>
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
</body>
</html>