<?php

namespace App\Models;

use Laravel\Sanctum\HasApiTokens;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Facades\Storage;
use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;

class User extends Authenticatable implements FilamentUser
{
    use HasApiTokens, HasFactory, Notifiable;
    
    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'avatar',
        'phone', // Tambahkan phone jika belum ada
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /**
     * Determine if the user can access the given Filament panel.
     */
    public function canAccessPanel(Panel $panel): bool
    {
        return true; // Atau sesuaikan dengan logic authorization Anda
    }

    /**
     * Get the user's avatar URL for Filament.
     */
    public function getFilamentAvatarUrl(): ?string
    {
        if (!$this->avatar) {
            return null;
        }

        // Jika avatar sudah berupa URL lengkap (seperti contoh Anda)
        if (filter_var($this->avatar, FILTER_VALIDATE_URL)) {
            return $this->avatar;
        }

        // Jika avatar berupa nama file saja, coba berbagai kemungkinan lokasi
        if (Storage::disk('public')->exists('avatars/' . $this->avatar)) {
            return Storage::disk('public')->url('avatars/' . $this->avatar);
        }
        
        if (file_exists(public_path('avatars/' . $this->avatar))) {
            return asset('avatars/' . $this->avatar);
        }
        
        if (Storage::exists('avatars/' . $this->avatar)) {
            return Storage::url('avatars/' . $this->avatar);
        }

        if (Storage::disk('public')->exists($this->avatar)) {
            return Storage::disk('public')->url($this->avatar);
        }

        return null;
    }

    /**
     * Get the user's name for Filament.
     */
    public function getFilamentName(): string
    {
        return $this->name;
    }

    /**
     * Get the user's avatar URL.
     * 
     * @return string|null
     */
    public function getAvatarUrlAttribute(): ?string
    {
        if (!$this->avatar) {
            return null;
        }

        // Jika avatar sudah berupa URL lengkap (seperti contoh Anda)
        if (filter_var($this->avatar, FILTER_VALIDATE_URL)) {
            return $this->avatar;
        }

        // Jika avatar berupa nama file saja
        // Coba berbagai kemungkinan lokasi penyimpanan
        
        // 1. Di storage/app/public/avatars (menggunakan Storage facade)
        if (Storage::disk('public')->exists('avatars/' . $this->avatar)) {
            return Storage::disk('public')->url('avatars/' . $this->avatar);
        }
        
        // 2. Di public/avatars
        if (file_exists(public_path('avatars/' . $this->avatar))) {
            return asset('avatars/' . $this->avatar);
        }
        
        // 3. Di storage/avatars (jika langsung di storage tanpa public disk)
        if (Storage::exists('avatars/' . $this->avatar)) {
            return Storage::url('avatars/' . $this->avatar);
        }

        // 4. Coba langsung dengan nama file di root storage
        if (Storage::disk('public')->exists($this->avatar)) {
            return Storage::disk('public')->url($this->avatar);
        }

        return null;
    }

    /**
     * Get initials for fallback avatar
     * 
     * @return string
     */
    public function getInitialsAttribute(): string
    {
        $names = explode(' ', $this->name);
        $initials = '';
        
        foreach ($names as $name) {
            $initials .= strtoupper(substr($name, 0, 1));
        }
        
        return substr($initials, 0, 2);
    }

    /**
     * Get the addresses for the user.
     */
    public function addresses()
    {
        return $this->hasMany(Address::class);
    }

    /**
     * Get the default address for the user.
     */
    public function defaultAddress()
    {
        return $this->hasOne(Address::class)->where('is_default', true);
    }
}