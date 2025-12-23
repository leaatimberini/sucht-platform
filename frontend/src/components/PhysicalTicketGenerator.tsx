'use client';

import { useState, useEffect } from "react";
import { Modal } from "@/components/ui/modal";
import { Printer } from "lucide-react";
import api from "@/lib/axios";
import toast from "react-hot-toast";
import { QRCodeSVG } from "qrcode.react";

interface PhysicalTicketGeneratorProps {
    eventId: string;
    eventName: string;
}

interface TicketTier {
    id: string;
    name: string;
    price: number;
}

interface GeneratedTicket {
    id: string;
    // Add other fields if needed for display
}

export function PhysicalTicketGenerator({ eventId, eventName }: PhysicalTicketGeneratorProps) {
    const [tiers, setTiers] = useState<TicketTier[]>([]);
    const [selectedTierId, setSelectedTierId] = useState<string>("");
    const [quantity, setQuantity] = useState<number>(1);
    const [isGenerating, setIsGenerating] = useState(false);
    const [generatedTickets, setGeneratedTickets] = useState<GeneratedTicket[]>([]);
    const [isOpen, setIsOpen] = useState(false);
    const [printMode, setPrintMode] = useState(false);

    useEffect(() => {
        if (isOpen) {
            api.get(`/events/${eventId}/ticket-tiers/all`)
                .then(res => setTiers(res.data))
                .catch(err => console.error(err));
        }
    }, [isOpen, eventId]);

    const handleGenerate = async () => {
        if (!selectedTierId) {
            toast.error("Selecciona un tipo de entrada");
            return;
        }
        if (quantity < 1) return;

        setIsGenerating(true);
        try {
            const { data } = await api.post('/tickets/generate-physical', {
                eventId,
                ticketTierId: selectedTierId,
                quantity
            });
            setGeneratedTickets(data);
            setPrintMode(true);
            toast.success(`${data.length} entradas generadas.`);
        } catch (error: any) {
            toast.error(error.response?.data?.message || "Error generando entradas");
        } finally {
            setIsGenerating(false);
        }
    };

    const selectedTierName = tiers.find(t => t.id === selectedTierId)?.name || "Entrada";

    if (printMode) {
        return (
            <div className="fixed inset-0 z-[9999] bg-white overflow-auto p-4 print-only-container">
                <div className="no-print fixed top-4 right-4 flex gap-4 bg-white/80 backdrop-blur-sm p-2 rounded-xl border border-zinc-200 shadow-xl">
                    <button
                        onClick={() => window.print()}
                        className="bg-zinc-900 text-white px-6 py-2 rounded-lg font-bold shadow-lg hover:bg-zinc-800 transition-all flex items-center gap-2"
                    >
                        <Printer className="w-4 h-4" /> IMPRIMIR
                    </button>
                    <button
                        onClick={() => { setPrintMode(false); setGeneratedTickets([]); }}
                        className="bg-red-50 text-red-600 border border-red-200 px-6 py-2 rounded-lg font-bold shadow-lg hover:bg-red-100 transition-all"
                    >
                        CERRAR
                    </button>
                </div>

                <div className="w-full max-w-[210mm] mx-auto print:w-full print:max-w-none">
                    <div className="grid grid-cols-2 gap-4 print:gap-4 pb-10 print:pb-0">
                        {generatedTickets.map((ticket) => (
                            <div key={ticket.id} className="ticket-card break-inside-avoid page-break-inside-avoid border border-dashed border-zinc-600 rounded-2xl p-4 flex flex-col items-center justify-between text-center h-[420px] bg-black relative shadow-sm print:m-1">

                                {/* Header: Event Title */}
                                <div className="w-full border-b border-dashed border-zinc-700 pb-3 mb-1">
                                    <div className="font-black text-base uppercase tracking-tight leading-4 text-gray-300 line-clamp-2 h-8 flex items-center justify-center">
                                        {eventName}
                                    </div>
                                </div>

                                {/* Body: Tier, QR, ID */}
                                <div className="flex-1 flex flex-col items-center justify-center w-full space-y-2">
                                    <div className="font-extrabold text-2xl text-[#ec4899] leading-none tracking-tight break-words w-full px-2">
                                        {selectedTierName}
                                    </div>
                                    <div className="text-[9px] uppercase font-bold text-gray-400 tracking-widest">
                                        Acceso Válido
                                    </div>

                                    <div className="bg-transparent p-1 rounded-lg">
                                        <QRCodeSVG
                                            value={ticket.id}
                                            size={130}
                                            bgColor="#000000"
                                            fgColor="#ffffff"
                                            level="Q"
                                            includeMargin={false}
                                        />
                                    </div>

                                    <div className="font-mono text-[10px] font-bold text-gray-400 tracking-[0.2em] uppercase">
                                        {ticket.id.split('-').pop()}
                                    </div>
                                </div>

                                {/* Footer: Logo */}
                                <div className="w-full border-t border-dashed border-zinc-700 pt-3 mt-1 flex justify-center items-center">
                                    <img
                                        src="/suchtblancoq.png"
                                        alt="SUCHT"
                                        className="h-8 w-auto object-contain"
                                    />
                                </div>
                            </div>
                        ))}
                    </div>
                </div>

                <style jsx global>{`
                    @media print {
                        /* Ocultar todo el contenido del body por defecto */
                        body * {
                            visibility: hidden;
                        }
                        
                        /* Hacer visible solo nuestro contenedor y sus hijos */
                        .print-only-container,
                        .print-only-container * {
                            visibility: visible;
                        }
                        
                        /* Posicionar el contenedor sobre todo lo demás */
                        .print-only-container {
                            position: absolute;
                            left: 0;
                            top: 0;
                            width: 100%;
                            height: auto;
                            min-height: 100vh;
                            background: white;
                            overflow: visible !important;
                            padding: 0 !important;
                            margin: 0 !important;
                            z-index: 9999;
                        }

                        /* Ajustar el grid para impresión */
                        .print-only-container .grid {
                            display: grid !important;
                            grid-template-columns: 1fr 1fr !important;
                            gap: 10px !important;
                            width: 100% !important;
                            padding: 10px !important;
                        }

                        /* Ajustar la tarjeta para asegurar saltos de página correctos */
                        .ticket-card {
                            break-inside: avoid !important;
                            page-break-inside: avoid !important;
                            margin: 0 !important;
                            height: 420px !important; /* Altura fija para consistencia */
                        }

                        /* Ocultar elementos marcados como no-print */
                        .no-print {
                            display: none !important;
                        }
                        
                        /* Configuración de página */
                        @page {
                            size: A4;
                            margin: 10mm;
                        }
                        
                        /* Asegurar colores exactos */
                        body {
                            -webkit-print-color-adjust: exact !important;
                            print-color-adjust: exact !important;
                        }
                    }
                `}</style>
            </div>
        );
    }

    return (
        <>
            <button
                onClick={() => setIsOpen(true)}
                className="flex items-center gap-2 bg-zinc-800 hover:bg-zinc-700 text-white px-4 py-2 rounded-lg font-medium transition-colors border border-zinc-700"
            >
                <Printer className="w-4 h-4" />
                <span>Entradas Físicas</span>
            </button>

            <Modal isOpen={isOpen} onClose={() => setIsOpen(false)} title="Generar Entradas Físicas">
                <div className="space-y-4">
                    <p className="text-zinc-400 text-sm">Estas entradas tienen QR único y NO descuentan stock del evento online.</p>

                    <div className="space-y-2">
                        <label className="text-sm font-medium text-white">Tipo de Entrada</label>
                        <select
                            className="w-full bg-zinc-800 border border-zinc-700 rounded-md p-2 text-white"
                            value={selectedTierId}
                            onChange={(e) => setSelectedTierId(e.target.value)}
                        >
                            <option value="">Seleccionar...</option>
                            {tiers.map(tier => (
                                <option key={tier.id} value={tier.id}>{tier.name} ($ {tier.price})</option>
                            ))}
                        </select>
                    </div>

                    <div className="space-y-2">
                        <label className="text-sm font-medium text-white">Cantidad</label>
                        <input
                            type="number"
                            min="1"
                            max="100"
                            className="w-full bg-zinc-800 border border-zinc-700 rounded-md p-2 text-white"
                            value={quantity}
                            onChange={(e) => setQuantity(parseInt(e.target.value))}
                        />
                    </div>

                    <button
                        onClick={handleGenerate}
                        disabled={isGenerating || !selectedTierId}
                        className="w-full bg-pink-600 hover:bg-pink-700 text-white font-bold py-3 rounded-lg mt-4 disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                        {isGenerating ? 'Generando...' : 'Generar y Previsualizar'}
                    </button>
                </div>
            </Modal>
        </>
    );
}
