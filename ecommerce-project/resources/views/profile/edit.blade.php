@extends('layouts.app')

@section('content')
<div class="container">
    <h1>Edit Profile</h1>
    
    <form action="{{ route('profile.update') }}" method="POST" enctype="multipart/form-data">
        @csrf
        @method('PUT')
        
        <div class="form-group">
            <label for="name">Name</label>
            <input type="text" class="form-control" id="name" name="name" value="{{ old('name', $user->name) }}" required>
        </div>
        
        <div class="form-group">
            <label for="email">Email</label>
            <input type="email" class="form-control" id="email" name="email" value="{{ old('email', $user->email) }}" required>
        </div>
        
        <div class="form-group">
            <label for="avatar">Profile Picture</label>
            <input type="file" class="form-control-file" id="avatar" name="avatar">
        </div>
        
        <button type="submit" class="btn btn-primary">Update Profile</button>
    </form>
</div>
@endsection