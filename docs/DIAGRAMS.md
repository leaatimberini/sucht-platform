# Diagramas Técnicos y Flujos de Trabajo

Este documento centraliza todos los diagramas visuales del sistema SUCHT para facilitar la comprensión de la arquitectura y los flujos de datos.

## 1. Diagrama de Infraestructura Detallado

Muestra cómo se despliega la aplicación en el servidor AWS EC2 y cómo interactúan los componentes.

```mermaid
graph TD
    subgraph "Internet"
        Client_Mobile[Mobile User]
        Client_Desktop[Desktop User]
        Meta_Webhook[Meta Webhook]
        MP_Webhook[MercadoPago Webhook]
    end

    subgraph "AWS EC2 Instance (Ubuntu)"
        Nginx[Nginx Reverse Proxy]
        
        subgraph "PM2 Process Manager"
            NodeNet[Backend: sucht-api]
            NodeWeb[Frontend: sucht-web]
        end
        
        Cron[System Cron / NestJS Scheduler]
        
        DB[(PostgreSQL Database)]
        Redis[(Redis Cache - Optional)]
    end
    
    Client_Mobile -->|HTTPS / 443| Nginx
    Client_Desktop -->|HTTPS / 443| Nginx
    Meta_Webhook -->|POST /marketing/webhook| Nginx
    MP_Webhook -->|POST /payments/webhook| Nginx
    
    Nginx -->|/api/*| NodeNet
    Nginx -->|/*| NodeWeb
    
    NodeNet -->|SQL Queries| DB
    NodeNet -->|Events| Meta_API[Meta Conversions API]
    NodeNet -->|Notifications| Telegram_API[Telegram Bot]
    
    NodeWeb -->|SSR/API Calls| NodeNet
```

---

## 2. Diagrama de Dependencias de Clases (Backend Core)

Visualización de cómo interactúan los Servicios y Controladores principales del módulo de Tickets y Pagos.

```mermaid
classDiagram
    class TicketsController {
        +create()
        +acquire()
        +redeem()
    }
    
    class TicketsService {
        +createTicketInternal()
        +createTicketAndSendEmail()
        +redeemTicket()
    }
    
    class PaymentsService {
        +createPreference()
        +handleWebhook()
        -processApprovedPayment()
    }
    
    class TicketTiersService {
        +validateStock()
    }
    
    class UsersService {
        +findOne()
        +createUser()
    }

    class MailService {
        +sendTicketEmail()
    }

    TicketsController --> TicketsService : uses
    TicketsService --> TicketTiersService : uses
    TicketsService --> UsersService : uses
    TicketsService --> MailService : uses
    
    PaymentsService --> TicketsService : uses (to issue ticket)
    PaymentsService --> TicketTiersService : uses
    PaymentsService --> UsersService : uses (buyer info)
```

---

## 3. Flujos de Trabajo (Sequence Diagrams)

### 3.1 Flujo de Compra de Entrada (End-to-End)

```mermaid
sequenceDiagram
    participant User
    participant Frontend
    participant Backend (API)
    participant MercadoPago
    participant Database
    participant Mailer

    User->>Frontend: Selecciona Entrada y Clic "Pagar"
    Frontend->>Backend: POST /payments/create-preference
    Backend->>Database: Valida Stock
    Backend->>MercadoPago: Create Preference
    MercadoPago-->>Backend: preference_id
    Backend-->>Frontend: preference_id
    
    Frontend->>MercadoPago: Redirige a Checkout
    User->>MercadoPago: Completa Pago
    
    par Async Process
        MercadoPago->>Backend: Webhook (payment.created)
        Backend->>Database: Busca Usuario & Tier
        Backend->>Database: Crea Ticket (Status: VALID)
        Backend->>Database: Descuenta Stock
        Backend->>Mailer: Envía Email con QR
        Mailer-->>User: Email Recibido
    and User Redirection
        MercadoPago->>Frontend: Redirige a /success
        Frontend->>User: Muestra "Pago Exitoso"
    end
```

### 3.2 Flujo de Validación de Entrada (Scanner)

```mermaid
sequenceDiagram
    participant Portero (Verifier)
    participant Backend
    participant Database

    Portero->>Backend: Escanea QR (POST /tickets/redeem)
    Backend->>Database: Busca Ticket por ID
    
    alt Ticket No Existe
        Backend-->>Portero: 404 Not Found
    else Ticket Ya Usado
        Backend-->>Portero: 400 Bad Request (Already Redeemed)
    end
    
    Backend->>Database: Verifica Event Date
    
    alt Status OK
        Backend->>Database: Update Status = USED
        Backend->>Database: Incrementa RedeemedCount
        Backend-->>Portero: 200 OK (Access Granted + User Name)
    end
```

---

## 4. Diagrama de Arquitectura de Módulos (NestJS)

Cómo se organizan los módulos dentro del Monolito.

```mermaid
graph TD
    AppModule --> ConfigModule
    AppModule --> TypeOrmModule
    
    subgraph "Domain Modules"
        AppModule --> AuthModule
        AppModule --> UsersModule
        AppModule --> EventsModule
        AppModule --> TicketsModule
        AppModule --> PaymentsModule
    end
    
    subgraph "Feature Modules"
        AppModule --> MarketingModule
        AppModule --> CerebroModule[AI Automation]
        AppModule --> ScratchModule[Gamification]
    end
    
    AuthModule --> UsersModule
    TicketsModule --> EventsModule
    TicketsModule --> UsersModule
    PaymentsModule --> TicketsModule
```
