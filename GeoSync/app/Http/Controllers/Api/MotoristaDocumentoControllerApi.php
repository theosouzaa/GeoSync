<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MotoristaDocumento;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class MotoristaDocumentoControllerApi extends Controller
{
    public function index(Request $request)
    {
        $this->somenteMotorista($request);

        return response()->json([
            'success' => true,
            'data' => MotoristaDocumento::where('user_id', $request->user()->id)
                ->latest('updated_at')
                ->get(),
        ]);
    }

    public function store(Request $request, string $tipo)
    {
        $this->somenteMotorista($request);
        abort_unless(in_array($tipo, ['cnh', 'crlv'], true), 404);

        $data = $request->validate([
            'arquivo' => [
                'required',
                'file',
                'max:8192',
                'mimes:jpg,jpeg,png,webp,pdf',
                'mimetypes:image/jpeg,image/png,image/webp,application/pdf',
            ],
        ]);

        $arquivo = $data['arquivo'];
        $documento = MotoristaDocumento::firstOrNew([
            'user_id' => $request->user()->id,
            'tipo' => $tipo,
        ]);
        $arquivoAnterior = $documento->arquivo_path;
        $caminho = $arquivo->store("documentos-motoristas/{$request->user()->id}", 'local');

        $documento->fill([
            'arquivo_path' => $caminho,
            'arquivo_mime' => $arquivo->getMimeType() ?: 'application/octet-stream',
            'arquivo_nome' => mb_substr($arquivo->getClientOriginalName(), 0, 255),
            'validade' => null,
            'status' => 'pendente',
            'motivo_reprovacao' => null,
            'analisado_em' => null,
        ])->save();

        if ($arquivoAnterior && $arquivoAnterior !== $caminho) {
            Storage::disk('local')->delete($arquivoAnterior);
        }

        return response()->json([
            'success' => true,
            'message' => 'Documento recebido e enviado para análise.',
            'data' => $documento->fresh(),
        ], 201);
    }

    public function adminIndex(Request $request)
    {
        $this->somenteAdmin($request);

        $documentos = MotoristaDocumento::with('motorista:id,name,email')
            ->latest('updated_at')
            ->paginate(min(max((int) $request->input('per_page', 20), 1), 100));

        return response()->json(['success' => true, 'data' => $documentos]);
    }

    public function arquivo(Request $request, MotoristaDocumento $documento)
    {
        $this->somenteAdmin($request);
        abort_unless(Storage::disk('local')->exists($documento->arquivo_path), 404);

        return Storage::disk('local')->response(
            $documento->arquivo_path,
            $documento->arquivo_nome,
            ['Content-Type' => $documento->arquivo_mime],
        );
    }

    public function revisar(Request $request, MotoristaDocumento $documento)
    {
        $this->somenteAdmin($request);
        $data = $request->validate([
            'status' => ['required', Rule::in(['aprovado', 'reprovado'])],
            'validade' => [
                Rule::requiredIf($request->input('status') === 'aprovado'),
                'nullable',
                'date',
                'after_or_equal:today',
            ],
            'motivo_reprovacao' => [
                Rule::requiredIf($request->input('status') === 'reprovado'),
                'nullable',
                'string',
                'max:1000',
            ],
        ]);

        $documento->update([
            'status' => $data['status'],
            'validade' => $data['status'] === 'aprovado' ? $data['validade'] : null,
            'motivo_reprovacao' => $data['status'] === 'reprovado'
                ? $data['motivo_reprovacao']
                : null,
            'analisado_em' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Documento revisado.',
            'data' => $documento->fresh(),
        ]);
    }

    private function somenteMotorista(Request $request): void
    {
        abort_unless($request->user()->tipo === 'motorista', 403, 'Apenas motoristas podem acessar estes documentos.');
    }

    private function somenteAdmin(Request $request): void
    {
        abort_unless($request->user()->tipo === 'admin', 403, 'Apenas administradores podem revisar documentos.');
    }
}
