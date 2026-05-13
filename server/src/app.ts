import { configDotenv } from 'dotenv';
import PayGidiServer from './server';

configDotenv();

const server = new PayGidiServer(Number(process.env.PORT) || 3000);

server.run().catch(err => {
    console.error("Unable to start PayGidi server:", err);
    process.exit(1);
});

export default server;
