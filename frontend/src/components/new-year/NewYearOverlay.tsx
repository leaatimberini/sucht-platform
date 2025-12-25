'use client';

import { useState, useEffect, useMemo } from 'react';
import { NewYearCountdown } from './NewYearCountdown';
import { FireworksEffect } from './FireworksEffect';
import { NewYearBanner } from './NewYearBanner';
import api from '@/lib/axios';

// ============================================
// 🎆 CONFIGURACIÓN AÑO NUEVO 2026
// ============================================
// Para desactivar los efectos después de la temporada,
// simplemente cambia ENABLED a false
const CONFIG = {
    ENABLED: true, // Cambiar a false para desactivar todo

    // Zona horaria de Buenos Aires
    TIMEZONE_OFFSET: -3,

    // Fechas de las fases (en hora de Buenos Aires)
    PHASES: {
        // Fase 1: Pre-Año Nuevo (partículas + countdown)
        PRE_NEW_YEAR_START: new Date('2025-12-25T00:00:00-03:00'),

        // Fase 2: Momento de Año Nuevo (fuegos artificiales intensos)
        NEW_YEAR_MOMENT: new Date('2026-01-01T00:00:00-03:00'),
        NEW_YEAR_FIREWORKS_END: new Date('2026-01-01T06:00:00-03:00'),

        // Fase 3: Día de Año Nuevo (banner + partículas suaves)
        NEW_YEAR_DAY_END: new Date('2026-01-02T06:00:00-03:00'),
    }
};

type Phase = 'pre_new_year' | 'new_year_moment' | 'new_year_day' | 'ended' | 'disabled';

interface NewYearEvent {
    id: number;
    title: string;
}

export function NewYearOverlay() {
    const [phase, setPhase] = useState<Phase>('disabled');
    const [newYearEvent, setNewYearEvent] = useState<NewYearEvent | null>(null);

    // Calculate current phase
    useEffect(() => {
        if (!CONFIG.ENABLED) {
            setPhase('disabled');
            return;
        }

        const updatePhase = () => {
            const now = new Date();

            if (now < CONFIG.PHASES.PRE_NEW_YEAR_START) {
                setPhase('disabled');
            } else if (now < CONFIG.PHASES.NEW_YEAR_MOMENT) {
                setPhase('pre_new_year');
            } else if (now < CONFIG.PHASES.NEW_YEAR_FIREWORKS_END) {
                setPhase('new_year_moment');
            } else if (now < CONFIG.PHASES.NEW_YEAR_DAY_END) {
                setPhase('new_year_day');
            } else {
                setPhase('ended');
            }
        };

        updatePhase();

        // Check phase every minute
        const interval = setInterval(updatePhase, 60000);
        return () => clearInterval(interval);
    }, []);

    // Fetch event for January 1st
    useEffect(() => {
        const fetchNewYearEvent = async () => {
            try {
                const response = await api.get('/events');
                const events = response.data;

                // Find event on January 1st, 2026
                const newYearEvent = events.find((event: any) => {
                    const eventDate = new Date(event.startDate);
                    return eventDate.getFullYear() === 2026 &&
                        eventDate.getMonth() === 0 &&
                        eventDate.getDate() === 1;
                });

                if (newYearEvent) {
                    setNewYearEvent({
                        id: newYearEvent.id,
                        title: newYearEvent.title
                    });
                }
            } catch (error) {
                console.error('Error fetching new year event:', error);
            }
        };

        if (phase !== 'disabled' && phase !== 'ended') {
            fetchNewYearEvent();
        }
    }, [phase]);

    // Generate particles
    const particles = useMemo(() => {
        if (phase === 'disabled' || phase === 'ended') return [];

        const count = phase === 'new_year_moment' ? 30 : 15;
        return Array.from({ length: count }, (_, i) => ({
            id: i,
            left: Math.random() * 100,
            top: Math.random() * 100,
            size: 2 + Math.random() * 4,
            delay: Math.random() * 5,
            duration: 3 + Math.random() * 4,
            color: Math.random() > 0.5 ? '#FFD700' : '#FF69B4',
        }));
    }, [phase]);

    // Don't render anything if disabled or ended
    if (phase === 'disabled' || phase === 'ended') {
        return null;
    }

    return (
        <>
            {/* Floating particles */}
            <div className="fixed inset-0 pointer-events-none z-20 overflow-hidden">
                {particles.map(particle => (
                    <div
                        key={particle.id}
                        className="new-year-particle rounded-full"
                        style={{
                            left: `${particle.left}%`,
                            top: `${particle.top}%`,
                            width: particle.size,
                            height: particle.size,
                            backgroundColor: particle.color,
                            boxShadow: `0 0 ${particle.size * 2}px ${particle.color}`,
                            animationDelay: `${particle.delay}s`,
                            animationDuration: `${particle.duration}s`,
                        }}
                    />
                ))}
            </div>

            {/* Phase-specific components */}
            {phase === 'pre_new_year' && (
                <NewYearCountdown
                    eventId={newYearEvent?.id}
                    eventTitle={newYearEvent?.title}
                />
            )}

            {phase === 'new_year_moment' && (
                <>
                    <FireworksEffect />
                    <NewYearBanner
                        eventId={newYearEvent?.id}
                        eventTitle={newYearEvent?.title}
                    />
                </>
            )}

            {phase === 'new_year_day' && (
                <NewYearBanner
                    eventId={newYearEvent?.id}
                    eventTitle={newYearEvent?.title}
                />
            )}
        </>
    );
}
