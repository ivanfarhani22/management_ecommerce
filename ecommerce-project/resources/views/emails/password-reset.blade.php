<!DOCTYPE html>
<html>
<head>
    <title>Password Reset</title>
</head>
<body>
    <h1>Password Reset</h1>
    <p>Hello {{ $user->name }},</p>
    <p>You have requested to reset your password. Click the button below to reset:</p>
    
    <a href="{{ $resetUrl }}">Reset Password</a>

    <p>If you did not request a password reset, please ignore this email.</p>
    <p>This link will expire in {{ config('auth.passwords.users.expire') }} minutes.</p>
</body>
</html>
