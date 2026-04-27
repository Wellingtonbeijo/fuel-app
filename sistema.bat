mkdir fuel-app
cd fuel-app

:: MOBILE
mkdir mobile
cd mobile
mkdir lib
cd lib

mkdir core
mkdir core\services

mkdir features
mkdir features\auth
mkdir features\home
mkdir features\mapa
mkdir features\postos
mkdir features\rotas
mkdir features\perfil

mkdir models
mkdir widgets

:: Voltar e criar arquivos
cd ..

type nul > lib\core\theme\app_theme.dart

mkdir lib\core\theme

type nul > lib\core\services\supabase_service.dart
type nul > lib\core\services\auth_service.dart
type nul > lib\core\services\location_service.dart

type nul > lib\features\auth\login_page.dart
type nul > lib\features\home\home_page.dart
type nul > lib\features\mapa\mapa_page.dart

type nul > lib\features\postos\posto_card.dart
type nul > lib\features\postos\posto_list.dart
type nul > lib\features\postos\posto_form.dart

type nul > lib\features\rotas\rota_page.dart
type nul > lib\features\perfil\perfil_page.dart

type nul > lib\models\posto.dart
type nul > lib\models\usuario.dart

type nul > lib\widgets\botao_padrao.dart
type nul > lib\widgets\input_padrao.dart

type nul > lib\main.dart
type nul > pubspec.yaml

cd ..

:: ADMIN
mkdir admin
cd admin
mkdir src
cd src

mkdir pages

type nul > pages\Dashboard.jsx
type nul > pages\Postos.jsx
type nul > pages\Usuarios.jsx

type nul > App.jsx
type nul > main.jsx

cd ..
type nul > package.json

cd ..

:: DATABASE
mkdir database
type nul > database\schema.sql

:: README
type nul > README.md