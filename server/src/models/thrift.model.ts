import { createPrismaModel } from './prisma.model';
export default createPrismaModel('thrift', { json: ['members'] });
