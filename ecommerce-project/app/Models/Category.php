<?php
// Model file: Category.php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    use HasFactory;

    protected $fillable = [
        'name', 
        'description', 
        'slug', 
        'is_active'
    ];

    public function products()
    {
        return $this->hasMany(Product::class);
    }
}
