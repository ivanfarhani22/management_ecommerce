@extends('layouts.app')

@section('content')
<div class="container">
    <h1>My Addresses</h1>
    @if($addresses->count() > 0)
        <div class="addresses-list">
            @foreach($addresses as $address)
                <div class="address-card">
                    <h3>{{ $address->name }}</h3>
                    <p>{{ $address->street }}</p>
                    <p>{{ $address->city }}, {{ $address->state }} {{ $address->postal_code }}</p>
                    <p>{{ $address->country }}</p>
                    <div class="address-actions">
                        <a href="{{ route('addresses.edit', $address->id) }}" class="btn btn-sm btn-primary">Edit</a>
                        <form action="{{ route('addresses.delete', $address->id) }}" method="POST" class="d-inline">
                            @csrf
                            @method('DELETE')
                            <button type="submit" class="btn btn-sm btn-danger">Delete</button>
                        </form>
                    </div>
                </div>
            @endforeach
        </div>
    @else
        <p>No addresses found. <a href="{{ route('addresses.create') }}">Add a new address</a></p>
    @endif
    <a href="{{ route('addresses.create') }}" class="btn btn-success">Add New Address</a>
</div>
@endsection