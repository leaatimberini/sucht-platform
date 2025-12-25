'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { PartyPopper, Calendar, ChevronRight } from 'lucide-react';

interface TimeLeft {
    days: number;
    hours: number;
    minutes: number;
    seconds: number;
}

interface CountdownProps {
    eventId?: number;
    eventTitle?: string;
}

const TARGET_DATE = new Date('2026-01-01T00:00:00-03:00'); // Buenos Aires timezone

export function NewYearCountdown({ eventId, eventTitle }: CountdownProps) {
    const [timeLeft, setTimeLeft] = useState<TimeLeft | null>(null);
    const [isVisible, setIsVisible] = useState(true);

    useEffect(() => {
        const calculateTimeLeft = (): TimeLeft | null => {
            const now = new Date();
            const difference = TARGET_DATE.getTime() - now.getTime();

            if (difference <= 0) {
                return null;
            }

            return {
                days: Math.floor(difference / (1000 * 60 * 60 * 24)),
                hours: Math.floor((difference / (1000 * 60 * 60)) % 24),
                minutes: Math.floor((difference / 1000 / 60) % 60),
                seconds: Math.floor((difference / 1000) % 60),
            };
        };

        // Initial calculation
        setTimeLeft(calculateTimeLeft());

        const timer = setInterval(() => {
            const newTimeLeft = calculateTimeLeft();
            setTimeLeft(newTimeLeft);

            if (!newTimeLeft) {
                clearInterval(timer);
            }
        }, 1000);

        return () => clearInterval(timer);
    }, []);

    // Don't render if countdown is over
    if (!timeLeft) return null;

    // Don't render if user closed it
    if (!isVisible) return null;

    return (
        <div className="fixed bottom-0 left-0 right-0 z-40 pointer-events-auto">
            {/* Gradient background */}
            <div className="bg-gradient-to-r from-zinc-900/95 via-zinc-800/95 to-zinc-900/95 backdrop-blur-md border-t border-amber-500/30">
                <div className="container mx-auto px-4 py-4">
                    <div className="flex flex-col md:flex-row items-center justify-between gap-4">

                        {/* Left: Icon and text */}
                        <div className="flex items-center gap-3">
                            <div className="relative">
                                <PartyPopper className="w-8 h-8 text-amber-400 new-year-sparkle" />
                                <div className="absolute -top-1 -right-1 w-3 h-3 bg-pink-500 rounded-full animate-ping" />
                            </div>
                            <div>
                                <p className="text-white font-bold text-lg">
                                    ¡Recibamos el <span className="text-new-year-gradient">2026</span> juntos!
                                </p>
                                <p className="text-zinc-400 text-sm hidden sm:block">
                                    La mejor fiesta de año nuevo te espera
                                </p>
                            </div>
                        </div>

                        {/* Center: Countdown */}
                        <div className="flex items-center gap-2 md:gap-4">
                            <CountdownUnit value={timeLeft.days} label="días" />
                            <span className="text-amber-400 text-2xl font-bold">:</span>
                            <CountdownUnit value={timeLeft.hours} label="hrs" />
                            <span className="text-amber-400 text-2xl font-bold">:</span>
                            <CountdownUnit value={timeLeft.minutes} label="min" />
                            <span className="text-amber-400 text-2xl font-bold">:</span>
                            <CountdownUnit value={timeLeft.seconds} label="seg" />
                        </div>

                        {/* Right: CTA Button */}
                        <div className="flex items-center gap-2">
                            {eventId ? (
                                <Link
                                    href={`/eventos/${eventId}`}
                                    className="flex items-center gap-2 bg-gradient-to-r from-amber-500 to-pink-500 hover:from-amber-400 hover:to-pink-400 text-black font-bold py-2 px-4 rounded-full transition-all transform hover:scale-105 shadow-lg shadow-amber-500/30"
                                >
                                    <Calendar size={18} />
                                    <span className="hidden sm:inline">{eventTitle || 'Ver Evento'}</span>
                                    <span className="sm:hidden">Ver</span>
                                    <ChevronRight size={16} />
                                </Link>
                            ) : (
                                <Link
                                    href="/eventos"
                                    className="flex items-center gap-2 bg-gradient-to-r from-amber-500 to-pink-500 hover:from-amber-400 hover:to-pink-400 text-black font-bold py-2 px-4 rounded-full transition-all transform hover:scale-105 shadow-lg shadow-amber-500/30"
                                >
                                    <Calendar size={18} />
                                    <span>Ver Eventos</span>
                                    <ChevronRight size={16} />
                                </Link>
                            )}

                            <button
                                onClick={() => setIsVisible(false)}
                                className="text-zinc-500 hover:text-white p-2 transition-colors"
                                aria-label="Cerrar countdown"
                            >
                                ✕
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}

function CountdownUnit({ value, label }: { value: number; label: string }) {
    return (
        <div className="flex flex-col items-center">
            <div className="bg-zinc-900/80 border border-amber-500/30 rounded-lg px-3 py-2 min-w-[50px] md:min-w-[60px]">
                <span className="text-2xl md:text-3xl font-bold text-white tabular-nums">
                    {value.toString().padStart(2, '0')}
                </span>
            </div>
            <span className="text-xs text-zinc-500 mt-1 uppercase tracking-wider">{label}</span>
        </div>
    );
}
