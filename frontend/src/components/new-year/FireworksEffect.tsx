'use client';

import { useEffect, useState, useCallback } from 'react';

interface Particle {
    id: number;
    x: number;
    y: number;
    color: string;
    size: number;
    angle: number;
    speed: number;
    life: number;
}

interface Firework {
    id: number;
    x: number;
    y: number;
    particles: Particle[];
    createdAt: number;
}

const COLORS = [
    '#FFD700', // Gold
    '#FF69B4', // Pink
    '#FFFFFF', // White
    '#00BFFF', // Sky blue
    '#FF6347', // Tomato
    '#9370DB', // Medium purple
];

const FIREWORK_LIFETIME = 2000; // ms
const SPAWN_INTERVAL = 800; // ms

export function FireworksEffect() {
    const [fireworks, setFireworks] = useState<Firework[]>([]);

    const createFirework = useCallback(() => {
        const x = 10 + Math.random() * 80; // 10-90% of viewport width
        const y = 10 + Math.random() * 50; // 10-60% of viewport height
        const particleCount = 20 + Math.floor(Math.random() * 15);
        const baseColor = COLORS[Math.floor(Math.random() * COLORS.length)];

        const particles: Particle[] = [];
        for (let i = 0; i < particleCount; i++) {
            particles.push({
                id: i,
                x: 0,
                y: 0,
                color: Math.random() > 0.3 ? baseColor : COLORS[Math.floor(Math.random() * COLORS.length)],
                size: 2 + Math.random() * 3,
                angle: (Math.PI * 2 * i) / particleCount + (Math.random() - 0.5) * 0.5,
                speed: 50 + Math.random() * 50,
                life: 1,
            });
        }

        const newFirework: Firework = {
            id: Date.now() + Math.random(),
            x,
            y,
            particles,
            createdAt: Date.now(),
        };

        setFireworks(prev => [...prev, newFirework]);
    }, []);

    // Spawn new fireworks
    useEffect(() => {
        const spawnInterval = setInterval(() => {
            createFirework();
        }, SPAWN_INTERVAL);

        // Create initial fireworks
        createFirework();
        setTimeout(createFirework, 200);
        setTimeout(createFirework, 400);

        return () => clearInterval(spawnInterval);
    }, [createFirework]);

    // Cleanup old fireworks
    useEffect(() => {
        const cleanupInterval = setInterval(() => {
            const now = Date.now();
            setFireworks(prev => prev.filter(fw => now - fw.createdAt < FIREWORK_LIFETIME));
        }, 500);

        return () => clearInterval(cleanupInterval);
    }, []);

    return (
        <div className="fixed inset-0 pointer-events-none z-30 overflow-hidden">
            {fireworks.map(firework => (
                <FireworkBurst key={firework.id} firework={firework} />
            ))}
        </div>
    );
}

function FireworkBurst({ firework }: { firework: Firework }) {
    const [progress, setProgress] = useState(0);

    useEffect(() => {
        const startTime = firework.createdAt;

        const animate = () => {
            const elapsed = Date.now() - startTime;
            const newProgress = Math.min(elapsed / FIREWORK_LIFETIME, 1);
            setProgress(newProgress);

            if (newProgress < 1) {
                requestAnimationFrame(animate);
            }
        };

        requestAnimationFrame(animate);
    }, [firework.createdAt]);

    return (
        <div
            className="absolute"
            style={{
                left: `${firework.x}%`,
                top: `${firework.y}%`,
            }}
        >
            {firework.particles.map(particle => {
                const distance = particle.speed * progress;
                const x = Math.cos(particle.angle) * distance;
                const y = Math.sin(particle.angle) * distance + (progress * progress * 30); // gravity
                const opacity = 1 - progress;
                const scale = 1 - progress * 0.5;

                return (
                    <div
                        key={particle.id}
                        className="absolute rounded-full"
                        style={{
                            width: particle.size,
                            height: particle.size,
                            backgroundColor: particle.color,
                            boxShadow: `0 0 ${particle.size * 2}px ${particle.color}`,
                            transform: `translate(${x}px, ${y}px) scale(${scale})`,
                            opacity,
                        }}
                    />
                );
            })}

            {/* Center flash */}
            {progress < 0.2 && (
                <div
                    className="absolute w-4 h-4 -ml-2 -mt-2 rounded-full bg-white"
                    style={{
                        opacity: 1 - progress * 5,
                        boxShadow: '0 0 20px #fff, 0 0 40px #FFD700',
                    }}
                />
            )}
        </div>
    );
}
