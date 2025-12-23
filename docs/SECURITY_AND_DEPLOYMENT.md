# Seguridad y Control de Acceso

## 1. Esquema de Autenticación
El sistema utiliza un estándar de industria basado en **JWT (JSON Web Tokens)**.

*   **Token de Acceso:** `Expiration: 24h`. Contiene el `userId` y `roles` en el payload. Firmado con `JWT_SECRET` (HS256).
*   **Protección de Rutas:** Decoradores personalizados en NestJS (`@Roles(...)`) interceptan cada petición. Si el usuario no tiene el rol requerido, se rechaza con `403 Forbidden` antes de ejecutar cualquier lógica.

## 2. Jerarquía de Roles (RBAC)
El sistema implementa un control de acceso basado en roles granular:

| Rol | Permisos Principales |
| :--- | :--- |
| **OWNER** | Acceso total. Ver métricas financieras, gestionar admins, configuración global. |
| **ADMIN** | Gestión operativa. Crear eventos, editar mesas, ver listas de invitados. |
| **RRPP** | Venta de entradas, link de referidos, visualización de sus propias comisiones. |
| **VERIFIER** | Rol técnico limitado. Solo puede acceder al endpoint de escaneo/validación de QR. |
| **CLIENT** | Usuario final. Puede comprar, ver sus tickets y su perfil. |
| **PARTNER** | Acceso limitado para gestionar beneficios y ver estadísticas de canje de sus cupones. |

---

## 3. Seguridad Financiera
Para proteger las transacciones y la integridad de los datos:

*   **Idempotencia:** Se previene el "doble gasto" o "doble ticket" verificando siempre el `paymentId` externo antes de emitir un activo.
*   **Validación de Precios:** El precio a cobrar NUNCA se toma del frontend. Se recalcula en el backend basado en el `TicketTier` almacenado en base de datos.
*   **Audit Logs:** Las transacciones de puntos y cambios de estado en mesas quedan registrados.

---

# Guía de Despliegue (Deployment)

El despliegue está automatizado mediante scripts de Shell para asegurar consistencia.

## Script `deploy.sh`
Ubicado en la raíz, realiza las siguientes acciones de manera secuencial:

1.  **Permisos:** Ajusta ownership de archivos a `ubuntu:www-data`.
2.  **Backend Deploy:**
    *   `git pull`
    *   `npm install`
    *   `npm run build` (Compilación TypeScript nest).
    *   `pm2 reload sucht-api` (Reinicio sin downtime).
3.  **Frontend Deploy:**
    *   `git pull`
    *   Limpieza de caché `.next`.
    *   `npm run build` (Static Generation + Server Components).
    *   `pm2 reload sucht-web`.

## Variables de Entorno Requeridas
El servidor de producción debe contar con el archivo `.env` configurado:

```ini
# Backend
JWT_SECRET=...
DB_PASSWORD=...
MERCADO_PAGO_ACCESS_TOKEN=...
META_CAPI_TOKEN=...
META_PIXEL_ID=...
```
