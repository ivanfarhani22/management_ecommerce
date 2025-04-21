@extends('layouts.app')
@section('show_back_button')
@endsection

@section('content')
<div class="container mx-auto px-4 py-8">
    <h1 class="text-3xl font-bold mb-6">Click & Collect</h1>

    <div class="grid md:grid-cols-3 gap-6">
        {{-- Store Locations --}}
        <div class="md:col-span-1 bg-white shadow-md rounded-lg p-4">
            <h3 class="text-xl font-bold mb-4">Select Store Location</h3>
            <div class="space-y-2">
                @foreach($stores as $store)
                    <div class="border rounded-md p-3 hover:bg-gray-50 cursor-pointer"
                         onclick="selectStore({{ $store->id }})">
                        <h4 class="font-semibold">{{ $store->name }}</h4>
                        <p class="text-sm text-gray-600">{{ $store->address }}</p>
                        <p class="text-sm text-gray-600">{{ $store->operating_hours }}</p>
                    </div>
                @endforeach
            </div>
        </div>

        {{-- Click & Collect Details --}}
        <div class="md:col-span-2 bg-white shadow-md rounded-lg p-6">
            <form action="{{ route('checkout.click-collect.process') }}" method="POST">
                @csrf

                <input type="hidden" name="store_id" id="selected_store_id" required>

                <div id="store-details" class="hidden">
                    <h2 class="text-2xl font-bold mb-4">Click & Collect Details</h2>

                    <div class="bg-blue-50 border border-blue-200 p-4 rounded-md mb-4">
                        <h3 class="font-semibold mb-2" id="selected-store-name"></h3>
                        <p id="selected-store-address" class="text-gray-700"></p>
                    </div>

                    <div>
                        <label for="pickup_date" class="block text-gray-700 text-sm font-bold mb-2">Pickup Date</label>
                        <input type="date" name="pickup_date" id="pickup_date"
                               class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                               required>
                    </div>

                    <div class="mt-4">
                        <label for="pickup_time" class="block text-gray-700 text-sm font-bold mb-2">Pickup Time</label>
                        <select name="pickup_time" id="pickup_time"
                                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                                required>
                            <option value="">Select Pickup Time</option>
                            <option value="09:00">09:00 AM</option>
                            <option value="12:00">12:00 PM</option>
                            <option value="15:00">03:00 PM</option>
                            <option value="18:00">06:00 PM</option>
                        </select>
                    </div>

                    <button type="submit" 
                            class="w-full bg-blue-500 text-white py-3 rounded-md hover:bg-blue-600 mt-4">
                        Confirm Click & Collect
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
    const stores = @json($stores);

    function selectStore(storeId) {
        const store = stores.find(s => s.id === storeId);
        
        if (store) {
            document.getElementById('selected_store_id').value = store.id;
            document.getElementById('selected-store-name').textContent = store.name;
            document.getElementById('selected-store-address').textContent = store.address;
            document.getElementById('store-details').classList.remove('hidden');
        }
    }
</script>
@endpush