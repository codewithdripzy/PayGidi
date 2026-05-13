import { NextFunction, Request, Response } from "express";
import { HTTP_RESPONSE_CODE } from "../core/constants/values";

/**
 * Middleware to verify the presence of the X-Api-Key header for embed requests.
 */
export const embedAuthMiddleware = (req: Request, res: Response, next: NextFunction) => {
    const apiKeyHeader = req.headers["x-api-key"];
    const apiKey = Array.isArray(apiKeyHeader)
        ? apiKeyHeader[0]?.trim()
        : typeof apiKeyHeader === "string"
            ? apiKeyHeader.trim()
            : "";

    if (!apiKey) {
        return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({
            message: "Missing X-Api-Key header",
            success: false,
        });
    }

    // Attach the cleaned API key to the request for controller use
    (req as any).apiKey = apiKey;
    next();
};
