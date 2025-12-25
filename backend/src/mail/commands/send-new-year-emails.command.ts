// src/mail/commands/send-new-year-emails.command.ts
// ============================================
// 🎆 COMANDO SEGURO PARA ENVIAR EMAILS DE AÑO NUEVO 2026
// ============================================
//
// MODO DE USO:
// npx ts-node -r tsconfig-paths/register src/mail/commands/send-new-year-emails.command.ts
//
// Este script está optimizado para Gmail y evita ser marcado como spam:
// - Envía en lotes pequeños (máximo 50 por ejecución)
// - Delay de 30 segundos entre cada email
// - Guarda progreso para continuar donde quedó
// - Límite seguro de emails por día
//

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../../app.module';
import { MailService } from '../mail.service';
import { UsersService } from '../../users/users.service';
import * as fs from 'fs';
import * as path from 'path';

// ============================================
// 📋 CONFIGURACIÓN - AJUSTAR SEGÚN NECESIDAD
// ============================================
const CONFIG = {
    // Máximo de emails por ejecución del script (recomendado: 50)
    BATCH_SIZE: 50,

    // Segundos de espera entre cada email (recomendado: 30 para Gmail)
    DELAY_BETWEEN_EMAILS_SECONDS: 30,

    // Archivo para guardar progreso (emails ya enviados)
    PROGRESS_FILE: '/tmp/sucht_new_year_emails_progress.json',

    // Si es true, solo muestra qué haría sin enviar (modo prueba)
    DRY_RUN: true,
};

interface ProgressData {
    sentEmails: string[];
    lastRun: string;
    totalSent: number;
}

function loadProgress(): ProgressData {
    try {
        if (fs.existsSync(CONFIG.PROGRESS_FILE)) {
            const data = fs.readFileSync(CONFIG.PROGRESS_FILE, 'utf-8');
            return JSON.parse(data);
        }
    } catch (error) {
        console.log('⚠️  No se pudo cargar el progreso anterior, comenzando desde cero.');
    }
    return { sentEmails: [], lastRun: '', totalSent: 0 };
}

function saveProgress(progress: ProgressData): void {
    fs.writeFileSync(CONFIG.PROGRESS_FILE, JSON.stringify(progress, null, 2));
}

function sleep(seconds: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, seconds * 1000));
}

async function bootstrap() {
    console.log('\n');
    console.log('='.repeat(60));
    console.log('🎆 ENVÍO SEGURO DE EMAILS - AÑO NUEVO 2026');
    console.log('='.repeat(60));
    console.log(`📧 Proveedor: Gmail (límites seguros activados)`);
    console.log(`📦 Lote máximo: ${CONFIG.BATCH_SIZE} emails por ejecución`);
    console.log(`⏱️  Delay entre emails: ${CONFIG.DELAY_BETWEEN_EMAILS_SECONDS} segundos`);
    console.log(`💾 Archivo de progreso: ${CONFIG.PROGRESS_FILE}`);
    if (CONFIG.DRY_RUN) {
        console.log('🧪 MODO PRUEBA - No se enviarán emails reales');
    }
    console.log('='.repeat(60));
    console.log('\n');

    const app = await NestFactory.createApplicationContext(AppModule);
    const mailService = app.get(MailService);
    const usersService = app.get(UsersService);

    try {
        // Cargar progreso anterior
        const progress = loadProgress();
        console.log(`📊 Emails ya enviados anteriormente: ${progress.sentEmails.length}`);
        if (progress.lastRun) {
            console.log(`📅 Última ejecución: ${progress.lastRun}`);
        }
        console.log('\n');

        // Obtener todos los usuarios
        const allUsers = await usersService.findAllWithoutPagination();
        console.log(`👥 Total de usuarios en el sistema: ${allUsers.length}`);

        // Filtrar usuarios con email válido que NO han sido procesados
        const usersWithEmail = allUsers.filter(
            user => user.email &&
                user.email.includes('@') &&
                !progress.sentEmails.includes(user.email)
        );

        console.log(`📬 Usuarios pendientes de envío: ${usersWithEmail.length}`);

        if (usersWithEmail.length === 0) {
            console.log('\n✅ ¡Todos los emails ya fueron enviados!');
            console.log(`📊 Total enviados: ${progress.totalSent}`);
            await app.close();
            return;
        }

        // Tomar solo el lote de esta ejecución
        const batch = usersWithEmail.slice(0, CONFIG.BATCH_SIZE);
        console.log(`📦 Procesando lote de: ${batch.length} emails`);

        const estimatedTime = (batch.length * CONFIG.DELAY_BETWEEN_EMAILS_SECONDS) / 60;
        console.log(`⏱️  Tiempo estimado: ~${estimatedTime.toFixed(1)} minutos`);
        console.log('\n');

        // Contador de éxitos y errores
        let successCount = 0;
        let errorCount = 0;

        // Enviar emails
        for (let i = 0; i < batch.length; i++) {
            const user = batch[i];
            const progress_str = `[${i + 1}/${batch.length}]`;
            const global_progress = `(${progress.totalSent + successCount + 1} total)`;

            try {
                if (CONFIG.DRY_RUN) {
                    console.log(`${progress_str} 🧪 [PRUEBA] Enviaría a: ${user.email}`);
                } else {
                    await mailService.sendNewYearGreeting(
                        user.email,
                        user.name || 'Amigo/a de SUCHT'
                    );
                    console.log(`${progress_str} ✅ Enviado a: ${user.email} ${global_progress}`);
                }

                successCount++;
                progress.sentEmails.push(user.email);
                progress.totalSent++;
                progress.lastRun = new Date().toISOString();

                // Guardar progreso después de cada email exitoso
                saveProgress(progress);

                // Esperar antes del siguiente email (excepto el último)
                if (i < batch.length - 1) {
                    process.stdout.write(`   ⏳ Esperando ${CONFIG.DELAY_BETWEEN_EMAILS_SECONDS}s...`);
                    await sleep(CONFIG.DELAY_BETWEEN_EMAILS_SECONDS);
                    process.stdout.write(' ✓\n');
                }

            } catch (error: any) {
                console.error(`${progress_str} ❌ Error enviando a ${user.email}:`, error.message);
                errorCount++;

                // Si el error es de límite de Gmail, detener
                if (error.message?.includes('rate') || error.message?.includes('limit')) {
                    console.error('\n🚫 Gmail ha detectado límite de envío. Deteniendo...');
                    console.log('💡 Esperá unas horas antes de ejecutar el script nuevamente.');
                    break;
                }
            }
        }

        // Resumen final
        console.log('\n');
        console.log('='.repeat(60));
        console.log('📊 RESUMEN DE ESTA EJECUCIÓN:');
        console.log('='.repeat(60));
        console.log(`✅ Emails enviados exitosamente: ${successCount}`);
        console.log(`❌ Emails con error: ${errorCount}`);
        console.log(`📬 Total enviados (acumulado): ${progress.totalSent}`);
        console.log(`📋 Pendientes: ${usersWithEmail.length - batch.length}`);
        console.log('='.repeat(60));

        if (usersWithEmail.length > batch.length) {
            console.log('\n⚠️  Quedan emails pendientes.');
            console.log('💡 Ejecutá el script nuevamente en 1-2 horas para continuar.');
            console.log(`   Comando: npx ts-node -r tsconfig-paths/register src/mail/commands/send-new-year-emails.command.ts`);
        } else {
            console.log('\n🎉 ¡Todos los emails fueron procesados!');
        }

    } catch (error) {
        console.error('❌ Error fatal:', error);
    } finally {
        await app.close();
        console.log('\n🎆 ¡Proceso completado!');
    }
}

bootstrap();
