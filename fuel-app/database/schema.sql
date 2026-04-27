-- =============================================
-- FUELSAVE - SCHEMA COMPLETO SUPABASE
-- =============================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Usuários (vinculado ao auth do Supabase)
CREATE TABLE usuarios (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  auth_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  pontos INT DEFAULT 0,
  premium BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Postos de combustível
CREATE TABLE postos (
  id SERIAL PRIMARY KEY,
  nome TEXT NOT NULL,
  cidade TEXT NOT NULL,
  estado TEXT NOT NULL,
  lat DOUBLE PRECISION NOT NULL,
  lng DOUBLE PRECISION NOT NULL,
  gasolina NUMERIC(6,2) NOT NULL,
  etanol NUMERIC(6,2),
  diesel NUMERIC(6,2),
  updated_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Histórico de preços
CREATE TABLE historico_precos (
  id SERIAL PRIMARY KEY,
  posto_id INT REFERENCES postos(id) ON DELETE CASCADE,
  usuario_id UUID REFERENCES usuarios(id) ON DELETE SET NULL,
  preco NUMERIC(6,2) NOT NULL,
  tipo_combustivel TEXT DEFAULT 'gasolina',
  created_at TIMESTAMP DEFAULT NOW()
);

-- Pagamentos
CREATE TABLE pagamentos (
  id SERIAL PRIMARY KEY,
  usuario_id UUID REFERENCES usuarios(id) ON DELETE SET NULL,
  tipo TEXT,
  valor NUMERIC(8,2),
  status TEXT DEFAULT 'pendente',
  created_at TIMESTAMP DEFAULT NOW()
);

-- Índices de performance
CREATE INDEX idx_postos_lat    ON postos(lat);
CREATE INDEX idx_postos_lng    ON postos(lng);
CREATE INDEX idx_postos_preco  ON postos(gasolina);
CREATE INDEX idx_historico_posto   ON historico_precos(posto_id);
CREATE INDEX idx_historico_usuario ON historico_precos(usuario_id);

-- Função para incrementar pontos
CREATE OR REPLACE FUNCTION incrementar_pontos(uid UUID, qtd INT)
RETURNS VOID AS $$
BEGIN
  UPDATE usuarios SET pontos = pontos + qtd WHERE auth_id = uid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Dados de teste
INSERT INTO postos (nome, cidade, estado, lat, lng, gasolina, etanol, diesel) VALUES


