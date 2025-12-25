'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { PartyPopper, Sparkles, X, Calendar } from 'lucide-react';

interface BannerProps {
    eventId?: number;
    eventTitle?: string;
}

const STORAGE_KEY = 'sucht_new_year_banner_2026_dismissed';

export function NewYearBanner({ eventId, eventTitle }: BannerProps) {
    const [isVisible, setIsVisible] = useState(false);
    const [isAnimating, setIsAnimating] = useState(false);

    useEffect(() => {
        // Check if user already dismissed the banner in this session
        const dismissed = sessionStorage.getItem(STORAGE_KEY);
        if (!dismissed) {
            // Delay showing for dramatic effect
            const timer = setTimeout(() => {
                setIsVisible(true);
                setIsAnimating(true);
            }, 1500);
            return () => clearTimeout(timer);
        }
    }, []);

    const handleClose = () => {
        setIsAnimating(false);
        setTimeout(() => {
            setIsVisible(false);
            sessionStorage.setItem(STORAGE_KEY, 'true');
        }, 300);
    };

    if (!isVisible) return null;

    return (
        <div
            className={`fixed inset-0 z-50 flex items-center justify-center p-4 transition-all duration-300 ${isAnimating ? 'bg-black/80 backdrop-blur-sm' : 'bg-black/0'
                }`}
            onClick={handleClose}
        >
            <div
                className={`relative bg-gradient-to-br from-zinc-900 via-zinc-800 to-zinc-900 rounded-2xl border border-amber-500/50 shadow-2xl shadow-amber-500/20 max-w-md w-full p-8 transition-all duration-500 ${isAnimating ? 'scale-100 opacity-100' : 'scale-90 opacity-0'
                    }`}
                onClick={(e) => e.stopPropagation()}
            >
                {/* Close button */}
                <button
                    onClick={handleClose}
                    className="absolute top-4 right-4 text-zinc-500 hover:text-white transition-colors"
                    aria-label="Cerrar"
                >
                    <X size={24} />
                </button>

                {/* Decorative elements */}
                <div className="absolute -top-3 -left-3">
                    <Sparkles className="w-8 h-8 text-amber-400 new-year-sparkle" />
                </div>
                <div className="absolute -bottom-3 -right-3">
                    <Sparkles className="w-8 h-8 text-pink-400 new-year-sparkle" style={{ animationDelay: '0.5s' }} />
                </div>

                {/* Content */}
                <div className="text-center">
                    {/* Icon */}
                    <div className="relative inline-block mb-4">
                        <PartyPopper className="w-16 h-16 text-amber-400" />
                        <div className="absolute inset-0 animate-ping">
                            <PartyPopper className="w-16 h-16 text-amber-400 opacity-20" />
                        </div>
                    </div>

                    {/* Title */}
                    <h2 className="text-4xl md:text-5xl font-extrabold mb-2">
                        <span className="text-new-year-gradient">¡Feliz 2026!</span>
                    </h2>

                    {/* Subtitle */}
                    <p className="text-xl text-white mb-4">
                        🎉 ¡Bienvenido al nuevo año! 🎉
                    </p>

                    {/* Message */}
                    <div className="bg-zinc-800/50 rounded-xl p-4 mb-6">
                        <p className="text-zinc-300 leading-relaxed">
                            Gracias por hacer de <span className="text-pink-400 font-semibold">SUCHT</span> una fiesta durante el 2025.
                        </p>
                        <p className="text-amber-400 font-semibold mt-2 text-lg">
                            ¡Por más noches juntos en el 2026! 🥂
                        </p>
                    </div>

                    {/* CTA */}
                    {eventId ? (
                        <Link
                            href={`/eventos/${eventId}`}
                            onClick={handleClose}
                            className="inline-flex items-center gap-2 bg-gradient-to-r from-amber-500 to-pink-500 hover:from-amber-400 hover:to-pink-400 text-black font-bold py-3 px-6 rounded-full transition-all transform hover:scale-105 shadow-lg shadow-amber-500/30"
                        >
                            <Calendar size={20} />
                            {eventTitle || '¡Ver Evento de Año Nuevo!'}
                        </Link>
                    ) : (
                        <Link
                            href="/eventos"
                            onClick={handleClose}
                            className="inline-flex items-center gap-2 bg-gradient-to-r from-amber-500 to-pink-500 hover:from-amber-400 hover:to-pink-400 text-black font-bold py-3 px-6 rounded-full transition-all transform hover:scale-105 shadow-lg shadow-amber-500/30"
                        >
                            <Calendar size={20} />
                            Ver Próximos Eventos
                        </Link>
                    )}

                    {/* Skip button */}
                    <button
                        onClick={handleClose}
                        className="block mx-auto mt-4 text-zinc-500 hover:text-zinc-300 text-sm transition-colors"
                    >
                        Cerrar
                    </button>
                </div>
            </div>
        </div>
    );
}
