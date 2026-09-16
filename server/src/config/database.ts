import prisma from './prisma';

class Database {
  async getConnection() {
    // Prisma connects lazily on the first query. Explicitly calling $connect
    // for every serverless request can recurse inside the generated client
    // when Vercel reuses a warm function instance.
    return prisma;
  }

  async checkHealth() {
    await prisma.$queryRaw`SELECT 1`;
    return true;
  }
}

export default new Database();
