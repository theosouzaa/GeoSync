<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MotoristaDocumento extends Model
{
    protected $table = 'motorista_documentos';

    protected $fillable = [
        'user_id',
        'tipo',
        'arquivo_path',
        'arquivo_mime',
        'arquivo_nome',
        'validade',
        'status',
        'motivo_reprovacao',
        'analisado_em',
    ];

    protected $casts = [
        'validade' => 'date:Y-m-d',
        'analisado_em' => 'datetime',
    ];

    protected $hidden = ['arquivo_path'];

    public function motorista(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
