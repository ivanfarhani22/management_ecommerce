<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Category; // pastikan modelnya ada

class CategoryController extends Controller
{
    public function index()
    {
        return response()->json([
            'data' => Category::all()
        ]);
    }
    
}
