import http from 'http';
import app from './app';
import prisma from './config/prisma';
const port = Number(process.env.PORT || 3000);
const server = http.createServer(app);
if (require.main === module)
  server.listen(port, () =>
    console.log(`PayGidi monolith listening on ${port}`),
  );

const shutdown = async (signal: string) => {
  console.log(`${signal} received. Shutting down PayGidi server.`);
  server.close(async () => {
    await prisma.$disconnect();
    process.exit(0);
  });
};

process.once('SIGTERM', () => void shutdown('SIGTERM'));
process.once('SIGINT', () => void shutdown('SIGINT'));
export default server;
