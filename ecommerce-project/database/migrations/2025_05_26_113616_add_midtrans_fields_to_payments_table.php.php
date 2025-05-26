<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddMidtransFieldsToPaymentsTable extends Migration
{
    public function up()
    {
        Schema::table('payments', function (Blueprint $table) {
            $table->string('snap_token')->nullable()->after('transaction_id');
            $table->string('midtrans_transaction_id')->nullable()->after('snap_token');
            $table->string('midtrans_status')->nullable()->after('midtrans_transaction_id');
            $table->timestamp('paid_at')->nullable()->after('midtrans_status');
            $table->json('midtrans_response')->nullable()->after('paid_at');
        });
    }

    public function down()
    {
        Schema::table('payments', function (Blueprint $table) {
            $table->dropColumn([
                'snap_token',
                'midtrans_transaction_id', 
                'midtrans_status',
                'paid_at',
                'midtrans_response'
            ]);
        });
    }
}