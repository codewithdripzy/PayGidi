import prisma from './prisma';

class Database {
  async getConnection() {
    await prisma.$connect();
    return prisma;
  }

  async checkHealth() {
    await prisma.$queryRaw`SELECT 1`;
    return true;
  }
}

export default new Database();
