<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AlertaControllerApi;
use App\Http\Controllers\Api\AuthControllerApi;
use App\Http\Controllers\Api\AvaliacaoControllerApi;
use App\Http\Controllers\Api\ContatoControllerApi;
use App\Http\Controllers\Api\PagamentoControllerApi;
use App\Http\Controllers\Api\RemessaControllerApi;
use App\Http\Controllers\Api\LocalizacaoControllerApi;
use App\Http\Controllers\Api\MotoristaDocumentoControllerApi;

Route::prefix('auth')->group(function () {
    Route::post('register', [AuthControllerApi::class, 'register']);
    Route::post('login', [AuthControllerApi::class, 'login']);
});
Route::post('contatos', [ContatoControllerApi::class, 'store']);
Route::get('avaliacoes', [AvaliacaoControllerApi::class, 'index']);
Route::get('avaliacoes/resumo', [AvaliacaoControllerApi::class, 'resumo']);

// Envie Authorization: Bearer {token} nos endpoints abaixo.
Route::middleware('auth:sanctum')->group(function () {
    Route::get('auth/me', [AuthControllerApi::class, 'me']);
    Route::post('auth/logout', [AuthControllerApi::class, 'logout']);
    Route::put('perfil', [AuthControllerApi::class, 'updateProfile']);
    Route::post('perfil/foto', [AuthControllerApi::class, 'uploadProfilePhoto']);
    Route::delete('perfil/foto', [AuthControllerApi::class, 'deleteProfilePhoto']);

    Route::get('motorista/documentos', [MotoristaDocumentoControllerApi::class, 'index']);
    Route::post('motorista/documentos/{tipo}', [MotoristaDocumentoControllerApi::class, 'store']);
    Route::get('admin/motorista-documentos', [MotoristaDocumentoControllerApi::class, 'adminIndex']);
    Route::get('admin/motorista-documentos/{documento}/arquivo', [MotoristaDocumentoControllerApi::class, 'arquivo']);
    Route::patch('admin/motorista-documentos/{documento}', [MotoristaDocumentoControllerApi::class, 'revisar']);

    Route::get('remessas/minhas', [RemessaControllerApi::class, 'minhas']);
    Route::get('remessas/disponiveis', [RemessaControllerApi::class, 'disponiveis']);
    Route::post('remessas/{remessa}/aceitar', [RemessaControllerApi::class, 'aceitar']);
    Route::patch('remessas/{remessa}/status', [RemessaControllerApi::class, 'atualizarStatus']);
    // Os recursos web usam os nomes "remessas.*" e "alertas.*".
    // Prefixar os nomes da API evita que route('remessas.store') no painel
    // administrativo seja resolvido como /api/remessas (rota Sanctum).
    Route::apiResource('remessas', RemessaControllerApi::class)->names('api.remessas');
    Route::apiResource('alertas', AlertaControllerApi::class)->names('api.alertas');

    Route::get('pagamentos', [PagamentoControllerApi::class, 'index']);
    Route::post('pagamentos', [PagamentoControllerApi::class, 'store']);
    Route::get('pagamentos/{pagamento}', [PagamentoControllerApi::class, 'show']);
    Route::post('avaliacoes', [AvaliacaoControllerApi::class, 'store']);
});

Route::post('/localizacao', [LocalizacaoControllerApi::class, 'store']);
Route::get('/localizacao', [LocalizacaoControllerApi::class, 'index']);


// HISTÓRICO DA REMESSA
Route::get('/localizacao/remessa/{remessa_id}', [
    LocalizacaoControllerApi::class,
    'porRemessa'
]);


// ÚLTIMA LOCALIZAÇÃO
Route::get('/localizacao/remessa/{remessa_id}/ultima', [
    LocalizacaoControllerApi::class,
    'ultimaPorRemessa'
]);

