'use client';

import { useEffect, useState } from "react";
import api from "@/lib/axios";
import { Ticket } from "@/types/ticket.types";
import { UserReward } from "@/types/reward.types";
import { Loader2, PartyPopper, AlertTriangle, Crown, Gift, Users, Calendar } from "lucide-react";
import toast from "react-hot-toast";
import { QRCodeSVG } from "qrcode.react";
import { useAuthStore } from "@/stores/auth-store";
import { useRouter } from 'next/navigation';
import Link from "next/link";
import { format } from "date-fns";
import { es } from "date-fns/locale";

// --- TIPOS ---
interface BirthdayEvent {
  event: { id: string, title: string, date: string };
  hasClassic: boolean;
  hasVip: boolean;
}

// --- COMPONENTE PRINCIPAL ---
export function BirthdayBenefitCard() {
  const [step, setStep] = useState<'loading' | 'event_list' | 'benefit_choice' | 'classic_form' | 'claimed'>('loading');
  const [availableEvents, setAvailableEvents] = useState<BirthdayEvent[]>([]);
  const [selectedEvent, setSelectedEvent] = useState<BirthdayEvent | null>(null);
  const [claimedBenefit, setClaimedBenefit] = useState<{ ticket: Ticket, reward: UserReward, eventId?: string } | null>(null);
  const [guestInput, setGuestInput] = useState<number>(5);
  const [dniInput, setDniInput] = useState<string>(''); // Nuevo estado para DNI
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const { user } = useAuthStore();
  const router = useRouter();

  useEffect(() => {
    const checkOffers = async () => {
      try {
        const { data } = await api.get('/birthday/offers');
        if (data.claimedBenefit) {
          setClaimedBenefit(data.claimedBenefit);
          setStep('claimed');
        } else if (data.availableEvents && data.availableEvents.length > 0) {
          setAvailableEvents(data.availableEvents);
          // Si solo hay un evento, lo seleccionamos automáticamente para simplificar UX
          if (data.availableEvents.length === 1) {
            setSelectedEvent(data.availableEvents[0]);
            setStep('benefit_choice');
          } else {
            setStep('event_list');
          }
        } else {
          // No hay eventos ni beneficios disponibles
          setStep('loading'); // Se queda en loading o podríamos poner un estado 'empty'
        }
      } catch (err) {
        console.error("Error fetching birthday offers", err);
      } finally {
        setIsLoading(false);
      }
    };
    checkOffers();
  }, []);

  const handleSelectOption = async (choice: 'classic' | 'vip') => {
    if (!selectedEvent) return;

    setIsLoading(true);
    setError(null);
    const payload: any = {
      choice,
      eventId: selectedEvent.event.id // ENVIAMOS EL ID DEL EVENTO
    };

    if (choice === 'classic') {
      if (!dniInput || dniInput.length < 7) {
        setError('Por favor ingresa un DNI válido.');
        setIsLoading(false);
        return;
      }
      payload.guestLimit = guestInput;
      payload.dni = dniInput; // Enviar DNI
      try {
        const { data } = await api.post('/birthday/select-option', payload);
        setClaimedBenefit(data);
        setStep('claimed');
        toast.success('¡Beneficio clásico reclamado!');
      } catch (err: any) {
        handleApiError(err);
      }
    } else if (choice === 'vip') {
      if (!user?.whatsappNumber) {
        toast.error("Por favor, añade tu WhatsApp en 'Editar Perfil' para reservar una mesa.", { duration: 4000 });
        setIsLoading(false);
        return;
      }
      try {
        const { data } = await api.post('/birthday/select-option', payload);
        if (data.type === 'paid' && data.preferenceId) {
          window.location.href = `https://www.mercadopago.com.ar/checkout/v1/redirect?pref_id=${data.preferenceId}`;
        }
      } catch (err: any) {
        handleApiError(err);
      }
    }
    setIsLoading(false);
  };

  const handleApiError = (err: any) => {
    let errorMessage = "Ocurrió un error.";
    const errorData = err.response?.data?.message;
    if (Array.isArray(errorData)) errorMessage = errorData.join('. ');
    else if (typeof errorData === 'string') errorMessage = errorData;
    setError(errorMessage);
    toast.error(errorMessage);
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = parseInt(e.target.value, 10);
    setGuestInput(isNaN(value) ? 0 : value);
  };

  // --- RENDERIZADO ---
  if (isLoading) {
    return <div className="bg-zinc-900 rounded-lg p-6 flex justify-center items-center min-h-[200px]"><Loader2 className="animate-spin text-pink-500" /></div>;
  }

  // Si no hay steps definidos y ya cargó, retornamos null (no es semana de cumpleaños o no hay beneficios)
  if (step === 'loading' && !isLoading) return null;

  if (step === 'event_list') {
    return (
      <div className="bg-gradient-to-br from-zinc-900 to-black border border-pink-500/30 rounded-lg p-6 text-white text-center">
        <PartyPopper className="mx-auto text-amber-400 mb-4" size={48} />
        <h2 className="text-2xl font-bold">¡Es tu semana de cumpleaños!</h2>
        <p className="text-zinc-300 mt-2 mb-6">Tienes beneficios disponibles en los siguientes eventos. ¡Elige uno!</p>
        <div className="grid gap-4">
          {availableEvents.map((evt) => (
            <button
              key={evt.event.id}
              onClick={() => { setSelectedEvent(evt); setStep('benefit_choice'); }}
              className="bg-zinc-800 hover:bg-zinc-700 border border-zinc-700 p-4 rounded-lg flex items-center justify-between group transition-all"
            >
              <div className="text-left">
                <h3 className="font-bold text-lg text-white group-hover:text-pink-400 transition-colors">{evt.event.title}</h3>
                <p className="text-zinc-400 text-sm flex items-center gap-2">
                  <Calendar size={14} />
                  {format(new Date(evt.event.date), "EEEE d 'de' MMMM", { locale: es })}
                </p>
              </div>
              <div className="bg-pink-600 text-white px-3 py-1 rounded-full text-sm font-bold opacity-0 group-hover:opacity-100 transition-opacity">
                Ver Beneficios
              </div>
            </button>
          ))}
        </div>
      </div>
    );
  }

  if (step === 'benefit_choice' && selectedEvent) {
    return (
      <div className="bg-gradient-to-br from-zinc-900 to-black border border-pink-500/30 rounded-lg p-6 text-white text-center">
        <div className="flex justify-between items-center mb-4">
          {availableEvents.length > 1 && (
            <button onClick={() => setStep('event_list')} className="text-sm text-zinc-400 hover:text-white underline">Wait, cambiar evento</button>
          )}
        </div>

        <h2 className="text-xl md:text-2xl font-bold mb-2">Celebrá en <span className="text-pink-500">{selectedEvent.event.title}</span></h2>
        <p className="text-zinc-300 mb-6">Elige tu beneficio exclusivo:</p>

        <div className="grid md:grid-cols-2 gap-6">
          {/* Opción Clásica */}
          <div className={`border ${selectedEvent.hasClassic ? 'border-zinc-700' : 'border-zinc-800 opacity-50'} p-4 rounded-lg flex flex-col text-left`}>
            <div className='flex items-center gap-3 mb-2'>
              <Gift size={24} className="text-pink-400" />
              <h3 className="font-bold text-lg">Beneficio Clásico</h3>
            </div>
            <p className="text-sm text-zinc-400 flex-grow my-2">Entrada GRATIS para vos y tus invitados + 1 Champagne de regalo.</p>
            <button
              onClick={() => setStep('classic_form')}
              disabled={!selectedEvent.hasClassic}
              className="w-full mt-4 bg-pink-600 hover:bg-pink-700 text-white font-bold py-2 px-4 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {selectedEvent.hasClassic ? 'Elegir' : 'No Disponible'}
            </button>
          </div>

          {/* Opción VIP */}
          <div className={`border ${selectedEvent.hasVip ? 'border-zinc-700' : 'border-zinc-800 opacity-50'} p-4 rounded-lg flex flex-col text-left`}>
            <div className='flex items-center gap-3 mb-2'>
              <Crown size={24} className="text-amber-400" />
              <h3 className="font-bold text-lg">Upgrade a Mesa VIP</h3>
            </div>
            <p className="text-sm text-zinc-400 flex-grow my-2">Pagá $150.000 y te damos $200.000 en consumo. Válido señando con $15.000.</p>
            <button
              onClick={() => handleSelectOption('vip')}
              disabled={!selectedEvent.hasVip}
              className="w-full mt-4 bg-amber-500 hover:bg-amber-600 text-black font-bold py-2 px-4 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {selectedEvent.hasVip ? 'Reservar VIP' : 'Agotado'}
            </button>
          </div>
        </div>
        {error && <p className="text-red-500 text-sm mt-4">{error}</p>}
      </div>
    );
  }

  if (step === 'classic_form') {
    return (
      <div className="bg-zinc-900 border border-zinc-700 rounded-lg p-6 text-white text-center">
        <Users className="mx-auto text-pink-400 mb-4" size={48} />
        <h2 className="text-2xl font-bold">Lista de Invitados</h2>
        <p className="text-zinc-300 mt-2 mb-4">Ingresa tu DNI y la cantidad de invitados (Máximo 50).</p>

        <div className="flex flex-col gap-4 items-center justify-center">
          <div>
            <label className="block text-zinc-400 text-sm mb-1">Tu DNI (Sin puntos)</label>
            <input
              type="text"
              placeholder="Ej: 40123456"
              value={dniInput}
              onChange={(e) => setDniInput(e.target.value)}
              className="bg-zinc-800 text-white p-2 rounded-md w-48 text-center text-lg font-bold border border-zinc-700 focus:border-pink-500 outline-none"
            />
          </div>
          <div>
            <label className="block text-zinc-400 text-sm mb-1">Cantidad Invitados</label>
            <input
              id="guest-input"
              type="number"
              min="0"
              max="50"
              value={guestInput}
              onChange={handleInputChange}
              className="bg-zinc-800 text-white p-2 rounded-md w-24 text-center text-xl font-bold border border-zinc-700 focus:border-pink-500 outline-none"
            />
          </div>
        </div>

        {error && <p className="text-red-500 text-sm mt-4">{error}</p>}
        <div className="mt-6 flex gap-4 justify-center">
          <button onClick={() => setStep('benefit_choice')} className="bg-zinc-700 hover:bg-zinc-600 text-white font-bold py-2 px-4 rounded-lg">Volver</button>
          <button onClick={() => handleSelectOption('classic')} className="bg-green-600 hover:bg-green-700 text-white font-bold py-2 px-4 rounded-lg">Confirmar</button>
        </div>
      </div>
    )
  }

  if (step === 'claimed' && claimedBenefit) {
    return (
      <div className="bg-gradient-to-br from-zinc-900 to-black border border-green-500/30 rounded-lg p-6 text-white">
        <h2 className="text-2xl font-bold mb-4">¡Beneficio Reclamado!</h2>
        <p className="text-zinc-300 mb-6">
          Has elegido la opción clásica. Tu entrada y tu premio de regalo se han generado.
        </p>
        <div className="grid md:grid-cols-2 gap-6">
          {claimedBenefit.ticket && (
            <Link href="/mi-cuenta/entradas" className="bg-white p-4 rounded-lg flex flex-col items-center text-center hover:scale-105 transition-transform">
              <QRCodeSVG value={claimedBenefit.ticket.id} size={150} fgColor="#000000" bgColor="#ffffff" />
              <p className="font-bold text-black mt-4 text-lg">QR de Ingreso</p>
              <p className="text-sm text-zinc-600">Para vos y {claimedBenefit.ticket.quantity - 1} invitados</p>
            </Link>
          )}
          {claimedBenefit.reward && (
            <Link href="/mi-cuenta/premios" className="bg-white p-4 rounded-lg flex flex-col items-center text-center hover:scale-105 transition-transform">
              <QRCodeSVG value={claimedBenefit.reward.id} size={150} fgColor="#000000" bgColor="#ffffff" />
              <p className="font-bold text-black mt-4 text-lg">QR de Regalo</p>
              <p className="text-sm text-zinc-600">{claimedBenefit.reward.reward.name}</p>
            </Link>
          )}
        </div>
      </div>
    );
  }

  return null;
}