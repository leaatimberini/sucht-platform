
import { IsUUID, IsNumber, Min, IsNotEmpty } from 'class-validator';

export class GeneratePhysicalTicketsDto {
    @IsUUID()
    @IsNotEmpty()
    eventId: string;

    @IsUUID()
    @IsNotEmpty()
    ticketTierId: string;

    @IsNumber()
    @Min(1)
    quantity: number;
}
