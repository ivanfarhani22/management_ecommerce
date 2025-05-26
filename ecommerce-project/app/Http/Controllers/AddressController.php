<?php

namespace App\Http\Controllers;

use App\Models\Address;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AddressController extends Controller
{
    public function index()
    {
        $addresses = Auth::user()->addresses()->get();
        return view('addresses.index', compact('addresses'));
    }

    public function create()
    {
        return view('addresses.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'street_address' => 'required|string|max:255',
            'city' => 'required|string|max:100',
            'state' => 'required|string|max:100',
            'postal_code' => 'required|string|max:20',
            'country' => 'required|string|max:100',
            'is_default' => 'sometimes|boolean',
        ]);

        $validated['user_id'] = Auth::id();

        // If this is set as default, remove default from other addresses
        if (isset($validated['is_default']) && $validated['is_default']) {
            Auth::user()->addresses()->update(['is_default' => false]);
        }

        Address::create($validated);

        return redirect()->route('profile.address')->with('success', 'Address added successfully!');
    }

    public function edit(Address $address)
    {
        // Make sure user can only edit their own addresses
        if ($address->user_id !== Auth::id()) {
            abort(403);
        }

        return view('addresses.edit', compact('address'));
    }

    public function update(Request $request, Address $address)
    {
        // Make sure user can only update their own addresses
        if ($address->user_id !== Auth::id()) {
            abort(403);
        }

        $validated = $request->validate([
            'street_address' => 'required|string|max:255',
            'city' => 'required|string|max:100',
            'state' => 'required|string|max:100',
            'postal_code' => 'required|string|max:20',
            'country' => 'required|string|max:100',
            'is_default' => 'sometimes|boolean',
        ]);

        // If this is set as default, remove default from other addresses
        if (isset($validated['is_default']) && $validated['is_default']) {
            Auth::user()->addresses()->where('id', '!=', $address->id)->update(['is_default' => false]);
        }

        $address->update($validated);

        return redirect()->route('profile.address')->with('success', 'Address updated successfully!');
    }

    public function delete(Address $address)
    {
        // Make sure user can only delete their own addresses
        if ($address->user_id !== Auth::id()) {
            abort(403);
        }

        $address->delete();

        return redirect()->route('profile.address')->with('success', 'Address deleted successfully!');
    }
}