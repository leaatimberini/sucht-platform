import { IsEnum, IsInt, IsNotEmpty, IsOptional, Max, Min, IsUUID } from 'class-validator';

export enum BirthdayOption {
  CLASSIC = 'classic',
  VIP = 'vip',
}

export class SelectBirthdayOptionDto {
  @IsNotEmpty()
  @IsEnum(BirthdayOption)
  choice: BirthdayOption;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(50) // Aumentado límite a 50
  guestLimit?: number;

  @IsNotEmpty()
  dni: string;

  @IsOptional()
  @IsUUID()
  eventId?: string;
}