<!DOCTYPE html>
<html>
<head>
    <title>Notification</title>
</head>
<body>
    <h1>{{ $title }}</h1>
    <p>Dear {{ $user->name }},</p>
    
    <p>{{ $message }}</p>

    @if(isset($actionUrl) && isset($actionText))
    <a href="{{ $actionUrl }}">{{ $actionText }}</a>
    @endif

    <p>Thank you!</p>
</body>
</html>