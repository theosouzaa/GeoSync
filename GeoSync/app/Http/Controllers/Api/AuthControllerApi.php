<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Models\Pagamento;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Str;

class AuthControllerApi extends Controller
{
    public function register(Request $request)
    {
        $request->merge(['email' => strtolower(trim((string) $request->input('email')))]);
        $data = $request->validate([
            'name' => 'required|string|min:3|max:100',
            'email' => 'required|email|max:100|unique:users,email',
            'cpf' => 'required|string|max:14|unique:users,cpf',
            'telefone' => 'required|string|max:20',
            'tipo' => 'required|in:cliente,motorista',
            'password' => 'required|string|min:6|confirmed',
        ]);

        $user = DB::transaction(function () use ($data) {
            $payment = null;
            if ($data['tipo'] === 'cliente') {
                $payment = Pagamento::whereRaw('LOWER(email) = ?', [$data['email']])
                    ->where('status', 'Aprovado')->whereNull('user_id')->lockForUpdate()->first();

                if (!$payment) {
                    throw ValidationException::withMessages([
                        'email' => 'É necessário ter um pagamento aprovado com este e-mail antes de criar a conta de cliente.',
                    ]);
                }
            }

            $user = User::create([...$data, 'password' => Hash::make($data['password'])]);
            if ($payment) {
                $payment->user_id = $user->id;
                $payment->save();
            }

            return $user;
        });

        return $this->authenticated($user, 201);
    }

    public function login(Request $request)
    {
        $data = $request->validate(['email' => 'required|email', 'password' => 'required|string']);
        $user = User::where('email', $data['email'])->first();

        if (!$user || !Hash::check($data['password'], $user->password)) {
            return response()->json(['success' => false, 'message' => 'E-mail ou senha incorretos.'], 401);
        }

        return $this->authenticated($user);
    }

    public function me(Request $request)
    {
        return response()->json(['success' => true, 'data' => $request->user()]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()?->delete();
        return response()->json(['success' => true, 'message' => 'Sessão encerrada.']);
    }

    public function updateProfile(Request $request)
    {
        $user = $request->user();
        $data = $request->validate([
            'name' => 'sometimes|string|min:3|max:100',
            'email' => 'sometimes|email|max:100|unique:users,email,' . $user->id,
            'telefone' => 'sometimes|nullable|string|max:20',
            'birth_date' => 'sometimes|nullable|date',
            'foto' => 'sometimes|nullable|string|max:255',
            'dark_mode' => 'sometimes|boolean',
            'password' => 'sometimes|string|min:6|confirmed',
        ]);
        if (isset($data['password'])) $data['password'] = Hash::make($data['password']);
        $user->update($data);
        return response()->json(['success' => true, 'message' => 'Perfil atualizado.', 'data' => $user->fresh()]);
    }

    public function uploadProfilePhoto(Request $request)
    {
        $request->validate([
            'foto' => 'required|image|mimes:jpg,jpeg,png,webp|max:5120',
        ]);

        $user = $request->user();
        $diretorio = public_path('uploads/perfis');
        if (!is_dir($diretorio)) {
            mkdir($diretorio, 0755, true);
        }

        $arquivo = $request->file('foto');
        $extensao = strtolower($arquivo->getClientOriginalExtension() ?: 'jpg');
        $nome = Str::uuid()->toString().'.'.$extensao;
        $arquivo->move($diretorio, $nome);
        $fotoAnterior = $user->foto;
        $caminho = 'uploads/perfis/'.$nome;

        $user->foto = $caminho;
        $user->save();

        if (is_string($fotoAnterior) && str_starts_with($fotoAnterior, 'uploads/perfis/')) {
            $arquivoAnterior = public_path('uploads/perfis/'.basename($fotoAnterior));
            if (is_file($arquivoAnterior)) {
                @unlink($arquivoAnterior);
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Foto do perfil atualizada.',
            'data' => ['foto' => $user->foto],
        ]);
    }

    public function deleteProfilePhoto(Request $request)
    {
        $user = $request->user();
        $fotoAnterior = $user->foto;
        $user->foto = null;
        $user->save();

        if (is_string($fotoAnterior) && str_starts_with($fotoAnterior, 'uploads/perfis/')) {
            $arquivoAnterior = public_path('uploads/perfis/'.basename($fotoAnterior));
            if (is_file($arquivoAnterior)) {
                @unlink($arquivoAnterior);
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Foto do perfil removida.',
            'data' => ['foto' => null],
        ]);
    }

    private function authenticated(User $user, int $status = 200)
    {
        return response()->json([
            'success' => true,
            'message' => 'Autenticação realizada com sucesso.',
            'token' => $user->createToken('mobile')->plainTextToken,
            'token_type' => 'Bearer',
            'data' => $user,
        ], $status);
    }
}
