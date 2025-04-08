<?php
// Migration file: create_orders_table.php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('address_id')->constrained()->onDelete('cascade');
            $table->decimal('total_amount', 10, 2);
            $table->enum('status', [
                'pending', 
                'processing', 
                'shipped', 
                'delivered', 
                'cancelled'
            ])->default('pending');
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('orders');
    }
};