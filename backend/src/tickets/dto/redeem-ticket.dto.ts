import { IsNotEmpty, IsInt, Min, IsOptional, IsUUID } from 'class-validator';

export class RedeemTicketDto {
  @IsNotEmpty()
  @IsInt()
  @Min(1)
  quantity: number;

  @IsOptional()
  @IsUUID()
  targetEventId?: string;
}