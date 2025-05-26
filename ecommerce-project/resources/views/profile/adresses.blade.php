@extends('layouts.app')

@section('title', 'My Addresses')

@section('content')
<div class="container">
    <a href="{{ route('profile.index') }}" class="back-link">
        <i class="fas fa-arrow-left"></i>
        Back to Profile
    </a>

    @if(session('success'))
        <div class="alert fade-in">
            {{ session('success') }}
        </div>
    @endif

    <div class="header">
        <h1>My Addresses</h1>
        <p>Manage your delivery addresses</p>
    </div>

    @if($addresses->count() > 0)
        <div class="addresses-grid">
            @foreach($addresses as $address)
                <div class="address-card {{ $address->is_default ? 'default' : '' }} fade-in">
                    @if($address->is_default)
                        <div class="default-badge">Default</div>
                    @endif
                    <div class="address-content">
                        <h3>{{ $address->label ?? 'Address' }}</h3>
                        <div class="address-details">
                            <p>{{ $address->street_address }}</p>
                            <p>{{ $address->city }}, {{ $address->state }} {{ $address->postal_code }}</p>
                            <p>{{ $address->country }}</p>
                        </div>
                        <div class="address-actions">
                            <a href="{{ route('addresses.edit', $address->id) }}" class="btn btn-primary">
                                <i class="fas fa-edit"></i>
                                Edit
                            </a>
                            <form action="{{ route('addresses.delete', $address->id) }}" method="POST" class="delete-form" onsubmit="return confirm('Are you sure you want to delete this address?')">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="btn btn-danger">
                                    <i class="fas fa-trash"></i>
                                    Delete
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            @endforeach
        </div>
    @else
        <div class="empty-state fade-in">
            <div class="empty-icon">
                <i class="fas fa-map-marker-alt"></i>
            </div>
            <h3>No addresses yet</h3>
            <p>Add your first delivery address to get started</p>
            <a href="{{ route('addresses.create') }}" class="btn btn-success">
                <i class="fas fa-plus"></i>
                Add Your First Address
            </a>
        </div>
    @endif

    @if($addresses->count() > 0)
        <a href="{{ route('addresses.create') }}" class="btn btn-success">
            <i class="fas fa-plus"></i>
            Add New Address
        </a>
    @endif
</div>

<style>
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    body {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
        background-color: #fafafa;
        color: #1a1a1a;
        line-height: 1.6;
        font-weight: 300;
    }

    .container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 40px 20px;
    }

    .header {
        text-align: center;
        margin-bottom: 60px;
    }

    .header h1 {
        font-size: 2.5rem;
        font-weight: 200;
        color: #1a1a1a;
        margin-bottom: 12px;
        letter-spacing: -0.02em;
    }

    .header p {
        font-size: 1.1rem;
        color: #666;
        font-weight: 300;
    }

    .addresses-grid {
        display: grid;
        grid-template-columns: 1fr;
        gap: 24px;
        margin-bottom: 40px;
    }

    @media (min-width: 768px) {
        .addresses-grid {
            grid-template-columns: repeat(2, 1fr);
        }
    }

    @media (min-width: 1024px) {
        .addresses-grid {
            grid-template-columns: repeat(3, 1fr);
        }
    }

    .address-card {
        background: white;
        border-radius: 12px;
        padding: 28px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
        border: 1px solid #f0f0f0;
        transition: all 0.3s ease;
        position: relative;
        overflow: hidden;
    }

    .address-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08);
    }

    .address-card.default::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 3px;
        background: linear-gradient(90deg, #1a1a1a, #333);
    }

    .default-badge {
        background: #1a1a1a;
        color: white;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 0.75rem;
        font-weight: 500;
        margin-bottom: 16px;
        display: inline-block;
        letter-spacing: 0.025em;
    }

    .address-content h3 {
        font-size: 1.2rem;
        font-weight: 400;
        color: #1a1a1a;
        margin-bottom: 16px;
        letter-spacing: -0.01em;
    }

    .address-details {
        margin-bottom: 24px;
    }

    .address-details p {
        color: #666;
        margin-bottom: 6px;
        font-size: 0.95rem;
        line-height: 1.5;
    }

    .address-actions {
        display: flex;
        gap: 12px;
        flex-wrap: wrap;
    }

    .btn {
        padding: 10px 20px;
        border: none;
        border-radius: 6px;
        font-size: 0.9rem;
        font-weight: 400;
        cursor: pointer;
        transition: all 0.3s ease;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        letter-spacing: 0.01em;
    }

    .btn-primary {
        background: #1a1a1a;
        color: white;
    }

    .btn-primary:hover {
        background: #333;
        transform: translateY(-1px);
    }

    .btn-danger {
        background: transparent;
        color: #dc3545;
        border: 1px solid #dc3545;
    }

    .btn-danger:hover {
        background: #dc3545;
        color: white;
        transform: translateY(-1px);
    }

    .btn-success {
        background: #1a1a1a;
        color: white;
        padding: 16px 32px;
        font-size: 1rem;
        border-radius: 8px;
        margin: 20px auto;
        display: block;
        width: fit-content;
    }

    .btn-success:hover {
        background: #333;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    }

    .empty-state {
        text-align: center;
        padding: 80px 20px;
        background: white;
        border-radius: 12px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
        border: 1px solid #f0f0f0;
    }

    .empty-icon {
        font-size: 4rem;
        color: #e0e0e0;
        margin-bottom: 24px;
    }

    .empty-state h3 {
        font-size: 1.5rem;
        font-weight: 300;
        color: #1a1a1a;
        margin-bottom: 12px;
    }

    .empty-state p {
        color: #666;
        font-size: 1.1rem;
        margin-bottom: 32px;
    }

    .back-link {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        color: #666;
        text-decoration: none;
        font-size: 0.95rem;
        margin-bottom: 40px;
        transition: color 0.3s ease;
    }

    .back-link:hover {
        color: #1a1a1a;
    }

    .alert {
        padding: 16px 20px;
        border-radius: 8px;
        margin-bottom: 32px;
        border-left: 4px solid #28a745;
        background: #f8fff9;
        color: #155724;
        font-weight: 400;
    }

    .fade-in {
        animation: fadeIn 0.5s ease-out;
    }

    @keyframes fadeIn {
        from {
            opacity: 0;
            transform: translateY(20px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    .delete-form {
        display: inline;
    }

    @media (max-width: 767px) {
        .container {
            padding: 20px 16px;
        }
        
        .header h1 {
            font-size: 2rem;
        }
        
        .address-card {
            padding: 20px;
        }
        
        .address-actions {
            flex-direction: column;
        }
        
        .btn {
            text-align: center;
            justify-content: center;
        }
    }
</style>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const cards = document.querySelectorAll('.address-card');
        cards.forEach((card, index) => {
            setTimeout(() => {
                card.style.opacity = '0';
                card.style.transform = 'translateY(20px)';
                card.style.animation = `fadeIn 0.5s ease-out ${index * 0.1}s forwards`;
            }, 0);
        });

        const alert = document.querySelector('.alert');
        if (alert) {
            setTimeout(() => {
                alert.style.opacity = '0';
                setTimeout(() => alert.remove(), 300);
            }, 5000);
        }
    });
</script>
@endsection