import jwt from "jsonwebtoken";

export const generateTokens = (user: { id: string; email: { address: string } }) => {
    const accessToken = jwt.sign(
        { id: user.id, email: user.email.address },
        process.env.ACCESS_TOKEN_SECRET || "access_secret",
        { expiresIn: "15m" }
    );
    const refreshToken = jwt.sign(
        { id: user.id },
        process.env.REFRESH_TOKEN_SECRET || "refresh_secret",
        { expiresIn: "7d" }
    );
    return { accessToken, refreshToken };
};

import crypto from "crypto";

export const generateApiKey = () => {
    return `orl_${crypto.randomBytes(24).toString("hex")}`;
};

export const verifyApiKey = (token: string) => {
    // If we were using JWT, we'd verify here. 
    // Now we rely on the service to check the database for the random string.
    return token.startsWith("orl_") ? { key: token } : null;
};