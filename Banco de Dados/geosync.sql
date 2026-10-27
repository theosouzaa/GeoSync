	DROP DATABASE IF EXISTS geosync;
	CREATE DATABASE geosync;
	USE geosync;

	-- 1. TABELA DE USUÁRIOS
	CREATE TABLE users (
		id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
		name VARCHAR(100) NOT NULL,
		email VARCHAR(100) NOT NULL UNIQUE,
		password VARCHAR(255) NOT NULL,
		birth_date DATE NULL,
		foto VARCHAR(255) NULL,
		tipo ENUM('admin', 'cliente', 'motorista') DEFAULT 'cliente',
		telefone VARCHAR(20) NULL,
		cpf VARCHAR(14) NULL,
		dark_mode BOOLEAN DEFAULT FALSE,
		created_at TIMESTAMP NULL,
		updated_at TIMESTAMP NULL
	);

	-- Documentos enviados por motoristas para análise administrativa.
	CREATE TABLE motorista_documentos (
		id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
		user_id BIGINT UNSIGNED NOT NULL,
		tipo ENUM('cnh', 'crlv') NOT NULL,
		arquivo_path VARCHAR(255) NOT NULL,
		arquivo_mime VARCHAR(100) NOT NULL,
		arquivo_nome VARCHAR(255) NOT NULL,
		validade DATE NULL,
		status VARCHAR(20) NOT NULL DEFAULT 'pendente',
		motivo_reprovacao TEXT NULL,
		analisado_em TIMESTAMP NULL,
		created_at TIMESTAMP NULL,
		updated_at TIMESTAMP NULL,
		UNIQUE KEY motorista_documentos_user_tipo_unique (user_id, tipo),
		INDEX motorista_documentos_status_created_idx (status, created_at),
		CONSTRAINT fk_motorista_documentos_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
	);

	-- 2. TABELA DE TOKENS DA API (Laravel Sanctum)
	CREATE TABLE personal_access_tokens (
		id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
		tokenable_type VARCHAR(255) NOT NULL,
		tokenable_id BIGINT UNSIGNED NOT NULL,
		name VARCHAR(255) NOT NULL,
		token VARCHAR(64) NOT NULL UNIQUE,
		abilities TEXT NULL,
		last_used_at TIMESTAMP NULL,
		expires_at TIMESTAMP NULL,
		created_at TIMESTAMP NULL,
		updated_at TIMESTAMP NULL,

		INDEX personal_access_tokens_tokenable_type_tokenable_id_index (
			tokenable_type,
			tokenable_id
		)
	);

	-- 2. TABELA DE REMESSAS (Com os IDs corretos e limpos)
	CREATE TABLE remessas (
		id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
		codigo_rastreio VARCHAR(100) NOT NULL,
		origem VARCHAR(100) NOT NULL,
		destino VARCHAR(100) NOT NULL,
		tipo_carga VARCHAR(100) NULL,
		peso DECIMAL(10,2) NULL,
		previsao_entrega DATE NULL,
		status VARCHAR(50) DEFAULT 'Pendente',
		cliente_id BIGINT UNSIGNED NULL,
		motorista_id BIGINT UNSIGNED NULL,
		created_at TIMESTAMP NULL,
		updated_at TIMESTAMP NULL,
		
		CONSTRAINT fk_cliente FOREIGN KEY (cliente_id) REFERENCES users(id) ON DELETE SET NULL,
		CONSTRAINT fk_motorista FOREIGN KEY (motorista_id) REFERENCES users(id) ON DELETE SET NULL
	);
    
    ALTER TABLE remessas
		MODIFY destino VARCHAR(500) NOT NULL,
		ADD destino_cep VARCHAR(9) NULL,
		ADD destino_rua VARCHAR(255) NULL,
		ADD destino_numero VARCHAR(20) NULL,
		ADD destino_complemento VARCHAR(100) NULL,
		ADD destino_bairro VARCHAR(100) NULL,
		ADD destino_cidade VARCHAR(100) NULL,
		ADD destino_estado VARCHAR(2) NULL,
		ADD latitude_destino DECIMAL(10,7) NULL,
		ADD longitude_destino DECIMAL(10,7) NULL;

	-- 3. TABELA DE ALERTAS (Ajustada com 'tipo' e 'mensagem' para bater com o Controller)
	CREATE TABLE alertas (
		id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
		tipo VARCHAR(100) NOT NULL,
		mensagem TEXT NOT NULL,
		remessa_id BIGINT UNSIGNED NOT NULL,
		created_at TIMESTAMP NULL,
		updated_at TIMESTAMP NULL,
		
		CONSTRAINT fk_alertas_remessa FOREIGN KEY (remessa_id) REFERENCES remessas(id) ON DELETE CASCADE ON UPDATE CASCADE
	);

	-- 4. TABELA DE LOCALIZAÇÕES
	CREATE TABLE localizacoes (
		id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
		latitude DECIMAL(10,8) NOT NULL,
		longitude DECIMAL(11,8) NOT NULL,
		remessa_id BIGINT UNSIGNED NOT NULL,
		created_at TIMESTAMP NULL,
		updated_at TIMESTAMP NULL,
		
		CONSTRAINT fk_localizacoes_remessa FOREIGN KEY (remessa_id) REFERENCES remessas(id) ON DELETE CASCADE ON UPDATE CASCADE
	);

	-- 5. TABELA DE PAGAMENTOS (Atualizada)
	CREATE TABLE pagamentos (
		id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
		user_id BIGINT UNSIGNED NULL,
		email VARCHAR(100) NULL,
		valor DECIMAL(10,2) NOT NULL,
		status VARCHAR(50) NOT NULL,
		created_at TIMESTAMP NULL,
		updated_at TIMESTAMP NULL,
		
		FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
	);

	-- 6. TABELA DE AVALIAÇÕES
	CREATE TABLE avaliacoes (
		id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
		user_id BIGINT UNSIGNED NOT NULL,
		nota INT NOT NULL,
		comentario VARCHAR(255) NULL,
		created_at TIMESTAMP NULL,
		updated_at TIMESTAMP NULL,
		
		FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
	);

	ALTER TABLE avaliacoes ADD COLUMN nome_exibicao VARCHAR(255) NULL AFTER user_id;

	ALTER TABLE avaliacoes DROP FOREIGN KEY avaliacoes_ibfk_1;
	ALTER TABLE avaliacoes DROP COLUMN user_id;

	-- 7. TABELA DE CONTATOS
	CREATE TABLE contatos (
		id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
		nome VARCHAR(100) NOT NULL,
		email VARCHAR(100) NOT NULL,
		mensagem TEXT NOT NULL,
		created_at TIMESTAMP NULL,
		updated_at TIMESTAMP NULL
	);

	select * from users;

	select * from personal_access_tokens;

	select * from remessas;	

	select * from alertas;

	select * from localizacoes;

	select * from pagamentos;

	select * from avaliacoes;

	select * from contatos; 
    
    
