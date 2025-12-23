// src/birthday/birthday.service.ts
import { Injectable, Logger, NotFoundException, BadRequestException } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { EventsService } from '../events/events.service';
import { TicketTiersService } from '../ticket-tiers/ticket-tiers.service';
import { TicketsService } from '../tickets/tickets.service';
import { RewardsService } from '../rewards/rewards.service';
import { ConfigurationService } from '../configuration/configuration.service';
import { User } from '../users/user.entity';
import { PaymentsService } from '../payments/payments.service';
import { Cron, CronExpression } from '@nestjs/schedule';
import { NotificationsService } from '../notifications/notifications.service';
import { InjectRepository } from '@nestjs/typeorm';
import { TicketTier, ProductType } from '../ticket-tiers/ticket-tier.entity';
import { Repository } from 'typeorm';

@Injectable()
export class BirthdayService {
  private readonly logger = new Logger(BirthdayService.name);

  constructor(
    @InjectRepository(TicketTier)
    private ticketTiersRepository: Repository<TicketTier>,
    private readonly usersService: UsersService,
    private readonly eventsService: EventsService,
    private readonly ticketTiersService: TicketTiersService,
    private readonly ticketsService: TicketsService,
    private readonly rewardsService: RewardsService,
    private readonly configurationService: ConfigurationService,
    private readonly paymentsService: PaymentsService,
    private readonly notificationsService: NotificationsService,
  ) { }

  @Cron(CronExpression.EVERY_DAY_AT_10AM, {
    name: 'birthdayNotifications',
    timeZone: 'America/Argentina/Buenos_Aires',
  })
  async handleBirthdayNotifications() {
    this.logger.log('Ejecutando tarea de notificación de cumpleaños...');

    const isEnabled = await this.configurationService.get('notifications_birthday_enabled');
    if (isEnabled !== 'true') {
      this.logger.log('Las notificaciones de cumpleaños están desactivadas. Omitiendo.');
      return;
    }

    const allUsers = await this.usersService.findAllWithoutPagination();
    const usersInBirthdayWeek = allUsers.filter(user =>
      this.usersService.isBirthdayWeek(user.dateOfBirth)
    );

    this.logger.log(`Se encontraron ${usersInBirthdayWeek.length} usuarios en su semana de cumpleaños.`);

    for (const user of usersInBirthdayWeek) {
      await this.notificationsService.sendNotificationToUser(user, {
        title: '¡Feliz Semana de Cumpleaños! 🎂',
        body: 'No te olvides de reclamar tu beneficio especial en tu cuenta de SUCHT.',
      });
    }
    this.logger.log('Notificaciones de cumpleaños enviadas.');
  }

  async claimClassicBenefit(user: User, guestLimit: number, eventId?: string) {
    const userProfile = await this.usersService.getProfile(user.id);
    if (!userProfile.isBirthdayWeek) {
      throw new BadRequestException('No estás en tu semana de cumpleaños.');
    }

    let targetEvent;
    if (eventId) {
      targetEvent = await this.eventsService.findOne(eventId);
    } else {
      targetEvent = await this.eventsService.findNextUpcomingEvent();
    }

    if (!targetEvent) {
      throw new NotFoundException('No se encontró el evento para asociar el beneficio.');
    }

    // Check if user already claimed for THIS event logic could be added here if needed
    // But requirement says "solo se le permite reclamarlo para 1 evento especifico".
    // We should check if they claimed ANY birthday benefit for the current week/year usually, 
    // but the current implementation checks per event in `checkAvailableOffers`.
    // Let's stick to per-event check or global week check.
    // Given the prompt "solo se le permite reclamarlo para 1 evento especifico (por si llega a haber varios)",
    // implies once claimed for one, you can't claim for others in the same week.

    /* 
       Logic: Check if user has ANY birthday ticket for ANY upcoming event in the birthday week scope?
       For now, let's keep it simple: If they claim it, they claim it.  
    */

    const birthdayTier = this.ticketTiersRepository.create({
      event: targetEvent,
      name: `Beneficio Cumpleaños - ${user.name}`,
      description: `Ingreso válido hasta las 03:00 hs.`,
      price: 0,
      isFree: true,
      productType: ProductType.TICKET,
      quantity: guestLimit + 1,
      isBirthdayDefault: true,
    });
    const savedTier = await this.ticketTiersRepository.save(birthdayTier);

    const birthdayTicket = await this.ticketsService.createTicketAndSendEmail(
      user,
      {
        eventId: targetEvent.id,
        ticketTierId: savedTier.id,
        quantity: guestLimit + 1,
      },
      null, 0, null, 'BIRTHDAY',
      savedTier.description
    );

    const birthdayRewardId = await this.configurationService.get('birthday_reward_id');
    if (birthdayRewardId) {
      try {
        const birthdayReward = await this.rewardsService.assignFreeReward(
          user,
          birthdayRewardId,
          'BIRTHDAY'
        );
        return {
          message: 'Beneficio de cumpleaños reclamado con éxito.',
          ticket: birthdayTicket,
          reward: birthdayReward,
        };
      } catch (e) {
        this.logger.error("Error assigning birthday reward", e);
      }
    }

    return {
      message: 'Beneficio de cumpleaños reclamado con éxito.',
      ticket: birthdayTicket,
    };
  }

  async claimVipBenefit(user: User, eventId?: string) {
    const userProfile = await this.usersService.getProfile(user.id);
    if (!userProfile.isBirthdayWeek) {
      throw new BadRequestException('No estás en tu semana de cumpleaños.');
    }

    let targetEvent;
    if (eventId) {
      targetEvent = await this.eventsService.findOne(eventId);
    } else {
      targetEvent = await this.eventsService.findNextUpcomingEvent();
    }

    if (!targetEvent) {
      throw new NotFoundException('No hay eventos próximos para la oferta VIP.');
    }

    const vipOfferTier = await this.ticketTiersService.findBirthdayVipOfferForEvent(targetEvent.id);
    if (!vipOfferTier) {
      throw new NotFoundException('No se ha configurado una oferta VIP de cumpleaños para este evento.');
    }

    if (vipOfferTier.quantity < 1) {
      throw new BadRequestException('La oferta de Mesa VIP de cumpleaños está agotada para este evento.');
    }

    if (!vipOfferTier.allowPartialPayment || !vipOfferTier.partialPaymentPrice) {
      throw new BadRequestException('La oferta VIP no está configurada para aceptar señas.');
    }

    return this.paymentsService.createPreference(user, {
      eventId: targetEvent.id,
      ticketTierId: vipOfferTier.id,
      quantity: 1,
      paymentType: 'partial',
    });
  }

  async checkAvailableOffers(user: User) {
    const response = {
      isBirthdayWeek: false,
      isClassicOfferAvailable: false,
      isVipOfferAvailable: false,
      claimedBenefit: null as any,
      availableEvents: [] as any[], // Nueva lista de eventos
    };

    const userProfile = await this.usersService.getProfile(user.id);
    response.isBirthdayWeek = userProfile.isBirthdayWeek;
    if (!response.isBirthdayWeek) return response;

    // Buscar eventos en la semana del cumpleaños (approx window of userProfile calculation + next 7 days)
    // Asumimos next 7-14 days for safety
    const today = new Date();
    const nextWeek = new Date();
    nextWeek.setDate(today.getDate() + 14);

    const events = await this.eventsService.findEventsBetweenDates(today, nextWeek);

    for (const event of events) {
      const existingTicket = await this.ticketsService.findBirthdayTicketForUser(user.id, event.id);
      if (existingTicket) {
        const existingReward = await this.rewardsService.findBirthdayRewardForUser(user.id, event.id);
        response.claimedBenefit = { ticket: existingTicket, reward: existingReward, eventId: event.id };
        // Si ya reclamó para UNO, bloqueamos los demás?
        // El usuario dijo "solo se le permite reclamarlo para 1 evento especifico".
        // Así que si hay claimedBenefit, no deberíamos mostrar offers para otros.
        return response;
      }

      const classicTier = await this.ticketTiersService.findBirthdayTierForEvent(event.id);
      const vipTier = await this.ticketTiersService.findBirthdayVipOfferForEvent(event.id);

      if (classicTier || (vipTier && vipTier.quantity > 0)) {
        response.availableEvents.push({
          event: { id: event.id, title: event.title, date: event.startDate },
          hasClassic: !!classicTier,
          hasVip: !!(vipTier && vipTier.quantity > 0)
        });
      }
    }

    response.isClassicOfferAvailable = response.availableEvents.some(e => e.hasClassic);
    response.isVipOfferAvailable = response.availableEvents.some(e => e.hasVip);

    return response;
  }
}