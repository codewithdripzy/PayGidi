import { createPrismaModel } from './prisma.model';
export default createPrismaModel('transaction', { json: ['metadata'] });
