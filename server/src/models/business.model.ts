import { createPrismaModel } from './prisma.model';
export default createPrismaModel('business', { json: ['metadata', 'directors', 'documents'] });
