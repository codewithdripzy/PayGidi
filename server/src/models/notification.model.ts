import { createPrismaModel } from './prisma.model';
export default createPrismaModel('notification', { json: ['metadata'] });
