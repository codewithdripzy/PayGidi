import http from "http";
import cors from "cors";
import express from "express";
import cookieParser from "cookie-parser";
import Database from "./config/database";
import { Server } from "socket.io";
import morgan from "morgan";
import logger from "./infrastructure/logging/logger";
import { globalLimiter } from "./api/middlewares/rate-limit.middleware";
import { errorHandler } from "./api/middlewares/error.middleware";

import authRouter from "./api/routes/auth.routes";
import walletRouter from "./api/routes/wallet.routes";
import businessRouter from "./api/routes/business.routes";
import transactionRouter from "./api/routes/transaction.routes";
import trustRouter from "./api/routes/trust.routes";
import userRouter from "./api/routes/user.routes";
import organizationRouter from "./routes/organization.routes";
import analyticsRouter from "./routes/analytics.routes";
import waitlistRouter from "./routes/waitlist.routes";
import { RequestUserData } from "./core/interfaces/data";

declare global {
    namespace Express {
        interface Request {
            user?: RequestUserData;
            apikey?: string;
        }
    }
}

class PayGidiServer {
    port: number;
    app: express.Application;

    allowedOrigins: string[];
    server: http.Server;
    io: Server;

    connectedSessions: Map<string, string>;

    constructor(port = 3000) {
        this.port = port;
        this.app = express();
        this.allowedOrigins = process.env.ALLOWED_ORIGINS?.split(",") ?? [];
        this.server = http.createServer(this.app);

        // Only for users on paid plans
        this.io = new Server(this.server, {
            cors: { origin: this.allowedOrigins.length ? this.allowedOrigins : true, methods: ["GET", "POST", "PATCH", "PUT", "DELETE", "HEAD"] },
        });
        this.connectedSessions = new Map();

        this.setup();
    }

    async setup() {
        this.app.use(cors({
            origin: (origin: any, cb: (arg0: null, arg1: any) => any) => cb(null, origin ?? true),
            credentials: true,
        }));
        this.app.use(morgan('combined', { stream: { write: (message) => logger.info(message.trim()) } }));
        this.app.use(globalLimiter);
        this.app.use(cookieParser());
        this.app.use(express.json());
        this.app.use(express.urlencoded({ extended: true }));

        this.connect();
    }

    async connect() {
        const database = new Database();
        await database.getConnection();

        this.route()
    }

    route() {
        this.app.use("/public/", express.static("public"));
        this.app.get("/api/v:version/health", (_: any, res: { json: (arg0: { status: string; }) => any; }) => res.json({ status: "ok" }));

        // Generated nested routes go here
        this.app.use("/api/v:version/auth", authRouter);
        this.app.use("/api/v:version/wallet", walletRouter);
        this.app.use("/api/v:version/business", businessRouter);
        this.app.use("/api/v:version/transactions", transactionRouter);
        this.app.use("/api/v:version/trust", trustRouter);
        this.app.use("/api/v:version/user", userRouter);
        this.app.use("/api/v:version/organization", organizationRouter);
        this.app.use("/api/v:version/organizations", organizationRouter);
        this.app.use("/api/v:version/analytics", analyticsRouter);
        this.app.use("/api/v:version/waitlist", waitlistRouter);
        
        // Error handling middleware (must be last)
        this.app.use(errorHandler);

        // Legacy routes kept temporarily for backwards compatibility.
    }

    async run() {
        this.server.listen(this.port, () => {
            logger.info(`PayGidi Server running on port ${this.port}`);
        });
    }
}

export default PayGidiServer;
