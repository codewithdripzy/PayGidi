import { Request, Response, NextFunction } from "express";
import { HTTP_RESPONSE_CODE } from "../core/constants/values";

export const agentAuthMiddleware = (req: Request, res: Response, next: NextFunction) => {
    const agentPassword = process.env.AGENT_SERVICE_PASSWORD;
    
    // If not configured, allow (optional, but safer to require)
    if (!agentPassword) {
        return next();
    }

    const providedPassword = req.headers["x-agent-password"];

    if (providedPassword !== agentPassword) {
        return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({
            message: "Unauthorized: Invalid agent password",
            success: false
        });
    }

    next();
};
