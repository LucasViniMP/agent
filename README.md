# MesaMestre — Flutter App

Sistema de Gestão Profissional de Restaurantes, convertido para Flutter a partir do frontend React/TypeScript original.

---

## 📱 Visão Geral

O app replica fielmente a lógica e visual do sistema web MesaMestre, com design **neo-brutalista** (preto/branco, bordas fortes, tipografia pesada) e suporte a três perfis operacionais:

| Perfil | Acesso | Função |
|--------|--------|--------|
| 🍳 **Cozinha** | `cozinha@mesamestre.com` | Visualiza pedidos em preparo, marca como prontos |
| 🏪 **Balcão** | `balcao@mesamestre.com` | Confirma ou recusa pedidos, marca como entregues |
| 🤵 **Garçom** | `garcom@mesamestre.com` | Visualiza mesas, cria pedidos, fecha contas |

Senha padrão: `123456`

---

## 🏗 Estrutura do Projeto

```
lib/
├── main.dart                  # Entry point + roteamento
├── theme/
│   └── app_theme.dart         # Design tokens, cores, tipografia
├── models/
│   └── models.dart            # Order, Table, Product, Employee, enums
├── services/
│   ├── api_service.dart       # HTTP client para a API REST
│   └── socket_service.dart    # Socket.IO (tempo real)
├── providers/
│   └── app_provider.dart      # Estado global (auth, orders, tables, products)
├── pages/
│   ├── role_selection_page.dart  # Tela inicial (escolha de perfil)
│   ├── login_page.dart           # Login por perfil
│   ├── kitchen_page.dart         # Tela da cozinha
│   ├── counter_page.dart         # Tela do balcão
│   └── waiter_page.dart          # Tela do garçom + modal de pedido
└── widgets/
    ├── widgets.dart           # Componentes reutilizáveis
    ├── app_sidebar.dart       # Drawer lateral
    └── app_shell.dart         # Shell autenticado (header + conteúdo)
```

---

## 🚀 Como Rodar

### Pré-requisitos
- Flutter SDK ≥ 3.10
- Dart ≥ 3.0
- Backend MesaMestre rodando (Node.js + Express + Prisma)

### Instalação

```bash
cd mesamestre_flutter
flutter pub get
flutter run
```

### App de pedidos online

O projeto tambem tem um segundo ponto de entrada para o cliente fazer pedidos
online. Ele usa o mesmo Firebase/Firestore do painel interno e grava pedidos na
colecao `orders` com:

- `source: ONLINE`
- `paymentStatus: PAID`
- `type: DELIVERY`
- `status: PENDING`

Assim que o pagamento for confirmado no app do cliente, o pedido aparece em
tempo real na tela de Balcao como pedido online pago.

Para rodar o painel interno:

```bash
flutter run
```

Para rodar o app do cliente:

```bash
flutter run -t lib/customer_main.dart
```

No Firebase, habilite o provedor de login anonimo se as regras do Firestore
exigirem usuario autenticado para ler produtos e criar pedidos.

### Configurar o servidor

Por padrão o app aponta para `http://localhost:3001/api`.

Para alterar: **pressione e segure** o texto "VERSÃO 1.0.0" na tela de seleção de perfil — um diálogo de configuração aparecerá.

Em produção, configure a URL no código:
```dart
// lib/services/api_service.dart
static const String _defaultBaseUrl = 'https://sua-api.com/api';
```

---

## 🔌 Integração com o Backend

O app consome exatamente os mesmos endpoints do frontend web:

```
POST   /api/auth/login
GET    /api/orders
POST   /api/orders
PUT    /api/orders/:id/status
POST   /api/orders/table/:id/close
GET    /api/tables
POST   /api/tables
PUT    /api/tables/:id/status
GET    /api/products
GET    /api/categories
```

### Socket.IO (Tempo Real)

O app conecta ao servidor Socket.IO e escuta:
- `orderCreated` → novo pedido adicionado à lista
- `orderUpdated` → pedido atualizado no estado
- `tableStatusChanged` → mesa atualizada no grid

---

## 🎨 Design System

O design é **neo-brutalista**, fiel ao original React:

| Token | Valor |
|-------|-------|
| Background | `#F9FAFB` (gray-50) |
| Surface | `#FFFFFF` (white) |
| Primary | `#0A0A0A` (near-black) |
| Border | `2px solid #0A0A0A` |
| Shadow | `3px 3px 0px #0A0A0A` |
| Font | Inter (via google_fonts) |
| Weight | 900 (Black) para títulos |

---

## 📦 Dependências

```yaml
provider: ^6.1.2          # Estado global
http: ^1.2.1               # Chamadas HTTP
socket_io_client: ^2.0.3   # Tempo real
shared_preferences: ^2.2.3 # Persistência local (token JWT)
flutter_animate: ^4.5.0    # Animações suaves
google_fonts: ^6.2.1       # Tipografia Inter
intl: ^0.19.0              # Formatação de datas
```

---

## 📱 Responsividade

| Plataforma | Comportamento |
|------------|---------------|
| Mobile (< 600px) | Grid 1 coluna, modal bottom-sheet |
| Tablet (600-1200px) | Grid 2-3 colunas, layout adaptado |
| Desktop (> 1200px) | Grid 4-5 colunas, sidebar sempre visível |
| Web | Funcional via `flutter build web` |

---

## 🔐 Autenticação

O JWT é salvo via `shared_preferences` e injetado automaticamente em todas as requisições via `ApiService`. No logout, o token é removido e o Socket.IO é desconectado.

---

## 🛠 Build para Produção

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Desktop (Windows/macOS/Linux)
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

---

## 🗃 Fluxo de Estado

```
RoleSelectionPage
    ↓ (seleciona perfil)
LoginPage
    ↓ (login bem-sucedido)
AppShell
    ├── KitchenPage  (role = kitchen)
    ├── CounterPage  (role = counter)
    └── WaiterPage   (role = waiter)
         └── _OrderModal (bottom sheet)
```

O `AppProvider` (ChangeNotifier) centraliza:
- Autenticação e perfil do usuário
- Lista de pedidos, mesas e produtos
- Atualização em tempo real via Socket.IO
- Ações (criar pedido, atualizar status, fechar conta)

---

## 📝 Variáveis de Ambiente (Backend)

O backend precisa de um `.env` com:
```env
DATABASE_URL="postgresql://user:pass@host:5432/mesamestre"
JWT_SECRET="seu_segredo_aqui"
PORT=3001
```

---

*Desenvolvido com Flutter 3.x — Material 3 + Design Neo-Brutalista*
