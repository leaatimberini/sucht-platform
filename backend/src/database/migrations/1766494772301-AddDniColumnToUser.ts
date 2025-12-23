import { MigrationInterface, QueryRunner } from "typeorm";

export class AddDniColumnToUser1766494772301 implements MigrationInterface {
    name = 'AddDniColumnToUser1766494772301'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "users" ADD "dni" character varying`);
        await queryRunner.query(`ALTER TABLE "users" ADD CONSTRAINT "UQ_5fe9cfa518b76c96518a206b350" UNIQUE ("dni")`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "users" DROP CONSTRAINT "UQ_5fe9cfa518b76c96518a206b350"`);
        await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "dni"`);
    }

}
