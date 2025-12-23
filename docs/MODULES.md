# Catálogo de Módulos del Backend

El backend de **SUCHT** está organizado en módulos funcionales bajo la filosofía de NestJS. A continuación se detalla la responsabilidad de cada uno.

## 1. Módulos Core

### `AuthModule`
*   **Responsabilidad:** Gestiona la identificación y autorización de usuarios.
*   **Características:**
    *   Estrategia `Local` (Email/Pass) y `JWT` (Token Bearer).
    *   Guards de Roles (`@Roles(UserRole.ADMIN)`).
    *   Hashing de contraseñas con `bcrypt`.

### `UsersModule`
*   **Responsabilidad:** CRUD de usuarios y perfiles.
*   **Características:**
    *   Gestión de roles (Owner, Admin, RRPP, Verifier, Client).
    *   Sistema de referidos (RRPP tracking).

### `EventsModule`
*   **Responsabilidad:** Gestión del ciclo de vida de un evento.
*   **Características:**
    *   Creación, Edición y Publicación de eventos.
    *   Manejo de imágenes de Flyers (vía Cloudinary).

---

## 2. Módulos de Negocio (Ticketing & Store)

### `TicketsModule`
*   **Responsabilidad:** El corazón transaccional. Genera y valida entradas.
*   **Características:**
    *   Generación de códigos QR únicos.
    *   Envío de correos con PDF/QR adjunto.
    *   Validación de estado (VALID, USED, EXPIRED).
    *   Lógica de "Scanear Entrada" (`redeemTicket`).

### `TicketTiersModule`
*   **Responsabilidad:** Configuración de precios y tipos de entrada.
*   **Características:**
    *   Control de Stock.
    *   Tipos: `TICKET`, `VIP_TABLE`, `VOUCHER`.

### `PaymentsModule`
*   **Responsabilidad:** Pasarela de Pagos (Mercado Pago).
*   **Características:**
    *   Creación de Preferencias de Pago.
    *   **Webhooks:** Escucha notificaciones de pago IPN/Webhook para aprobar tickets asincrónicamente.
    *   Manejo de idempotencia.

### `TablesModule`
*   **Responsabilidad:** Gestión visual y lógica de mesas VIP.
*   **Características:**
    *   Categorización (VIP, General, Booth).
    *   Mapa de coordenadas (X, Y) para el frontend.
    *   Estado de ocupación en tiempo real.

---

## 3. Módulos de Marketing & Gamification

### `MarketingModule`
*   **Responsabilidad:** Inteligencia de Datos y Publicidad.
*   **Características:**
    *   **CAPI Service:** Envía eventos "Server-Side" a Meta (Facebook) para sortear bloqueadores de anuncios.
    *   Optimización de Campañas.

### `ScratchModule` (Gamification)
*   **Responsabilidad:** Sistema de juego "Raspadita" para fidelización.
*   **Características:**
    *   Motor de probabilidad configurable (RNG).
    *   Gestión de premios (Internos o de Partners).
    *   Control de frecuencia (1 intento cada 7 días).

### `PointTransactionsModule`
*   **Responsabilidad:** Billetera virtual de puntos.
*   **Características:**
    *   Suma puntos por asistencia, referidos o compras.
    *   Historial transaccional inmutable.

---

## 4. Módulos de Inteligencia (Advanced)

### `CerebroModule` 🧠
*   **Responsabilidad:** Automatización e Inteligencia Artificial.
*   **Características:**
    *   **Scraper:** Analiza el contenido del propio sitio para entender la "Brand Persona".
    *   **Telegram Integration:** Envía reportes proactivos a los dueños sobre el perfil de la audiencia detectada.

### `NotificationsModule`
*   **Responsabilidad:** Comunicación omnicanal.
*   **Canales:** Email (Nodemailer), Web Push, Telegram.
