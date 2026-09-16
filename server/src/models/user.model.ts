import { createPrismaModel } from './prisma.model';
export default createPrismaModel('user', { json: ['metadata'] });
