// src/app/layout.tsx
import type { Metadata } from 'next';
import { Poppins } from 'next/font/google';
import './globals.css';
import { Toaster } from 'react-hot-toast';
import { Header } from '@/components/header';
import { TrackingScripts } from '@/components/tracking-scripts';
import { MercadoPagoProvider } from '@/components/mercado-pago-provider';
import { AppInitializer } from "@/components/app-initializer";
import { PWAInstallBanner } from '@/components/PWAInstallBanner';
import { SubscriptionManager } from '@/components/SubscriptionManager'; // 1. Importar
import { NewYearOverlay } from '@/components/new-year'; // 🎆 Año Nuevo 2026

const poppins = Poppins({
  subsets: ['latin'],
  weight: ['400', '500', '600', '700', '800'],
  variable: '--font-poppins',
});

export const metadata: Metadata = {
  title: 'SUCHT',
  description: 'El clásico de Castelar, desde 2010.',
  manifest: '/manifest.json',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="es" className={poppins.className}>
      <body
        className={`${poppins.className} bg-zinc-950 text-zinc-50 antialiased`}
      >
        <AppInitializer />
        <MercadoPagoProvider>
          <Toaster position="top-center" />
          <Header />
          <NewYearOverlay /> {/* 🎆 Efectos Año Nuevo 2026 */}
          <PWAInstallBanner />
          <main className="pt-20">{children}</main>
          {/* 2. Añadimos el gestor de suscripciones al final */}
          <SubscriptionManager />
        </MercadoPagoProvider>

        <TrackingScripts />
      </body>
    </html>
  );
}