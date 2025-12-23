# Funcionalidades y Flujos de Usuario

## 1. Venta de Entradas (Ticketing)
El flujo principal de ingresos de la plataforma.

1.  **Selección:** El usuario elige el evento y el tipo de entrada (General o VIP).
2.  **Checkout:** Se integra con Mercado Pago. El usuario puede pagar con dinero en cuenta, tarjetas o efectivo.
3.  **Emisión:** Una vez confirmado el pago (Webhook), el sistema genera el Ticket QR.
4.  **Entrega:** El ticket se envía por Email y queda disponible en la sección "Mi Cuenta".

## 2. Gestión de Mesas (VIP Tables)
Sistema visual para reservas de alto valor.

*   **Mapa Interactivo:** Los usuarios ven un mapa del local con indicadores de estado (Libre, Ocupada, Reservada).
*   **Reserva con Seña:** Permite bloquear una mesa pagando solo una fracción del valor total (Seña/Deposit).
*   **Asignación Inteligente:** El staff puede asignar reservas manuales a mesas específicas.

## 3. Gamificación (Scratch & Win)
Sistema de retención de usuarios.

*   **Mecánica:** Una "Raspadita" digital disponible cada 7 días.
*   **Premios:**
    *   **Puntos:** Canjeables por descuentos.
    *   **Tragos:** Vouchers QR para barra.
    *   **Beneficios Externos:** Descuentos en locales asociados (Partners).

## 4. Inteligencia de Marketing (Cerebro)
El sistema trabaja en segundo plano para optimizar la rentabilidad.

*   **Tracking Avanzado:** Cada compra envía señales al algoritmo de Meta Ads para mejorar el ROAS (Retorno de Inversión Publicitaria).
*   **Reportes Automáticos:** El dueño recibe alertas en Telegram sobre tendencias y perfiles de audiencia detectados por la IA.

## 5. Beneficio de Cumpleaños (Birthday Benefit)
Sistema de incentivo para usuarios que cumplen años cerca de la fecha del evento.

*   **Selección de Evento:** El usuario puede elegir entre múltiples eventos disponibles en una ventana de 14 días alrededor de su cumpleaños.
*   **Opciones:**
    *   **Clásico:** Ingreso gratuito + Lista de hasta 50 invitados.
    *   **VIP:** Ingreso VIP con premio adicional (ej. champagne).
*   **Anti-Fraude (DNI):** Se requiere DNI obligatorio al reclamar. El DNI se almacena en el perfil y se muestra al personal de ingreso/barra al escanear el QR, permitiendo validar identidad físicamente.

## 6. Auto-Validación de Ingreso (Smart Check-In)
Mejora de estadísticas y control de acceso.

*   **Mecánica:** Si un usuario consume algo en la barra (valida un producto o premio con QR) y su entrada de ingreso aún no está validada, el sistema la valida automáticamente.
*   **Beneficio:** Estadísticas de asistencia precisas, sin importar si el control de puerta validó la entrada o no.
