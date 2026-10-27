<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('motorista_documentos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->enum('tipo', ['cnh', 'crlv']);
            $table->string('arquivo_path');
            $table->string('arquivo_mime', 100);
            $table->string('arquivo_nome');
            $table->date('validade')->nullable();
            $table->string('status', 20)->default('pendente');
            $table->text('motivo_reprovacao')->nullable();
            $table->timestamp('analisado_em')->nullable();
            $table->timestamps();
            $table->unique(['user_id', 'tipo']);
            $table->index(['status', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('motorista_documentos');
    }
};
