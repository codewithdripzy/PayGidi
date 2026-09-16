import { createPrismaModel } from './prisma.model';
export default createPrismaModel('webhookTransaction', { json: ['rawPayload'] });
