import userService from "../services/user.service";
import { Request, Response, NextFunction } from "express";
import { HTTP_RESPONSE_CODE } from "../core/constants/values";
import authService, { AuthServiceError } from "../services/auth.service";
import { AccessTokenValidationData, CurrentUserData, RequestUserData } from "../core/interfaces/data";

const authMiddleware = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const token = req.cookies?.accessToken;
        if (!token) return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, Please login to continue" });

        const validation = await authService.verifyToken(token, {
            token,
            cookie: req.headers.cookie,
        }) as AccessTokenValidationData;

        if (validation?.valid === false || !validation?.user?.id) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, Please login to continue" });
        }

        const apiUser = await userService.getMe({
            token,
            cookie: req.headers.cookie,
        }) as CurrentUserData | null;

        // console.log("Authenticated User:", { apiUser });
        if (!apiUser?._id) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, Please login to continue" });
        }

        const requestUser: RequestUserData = {
            _id: apiUser._id,
            uid: apiUser.uid ?? apiUser.id ?? "",
            firstName: apiUser.firstName,
            lastName: apiUser.lastName,
            email: {
                address: apiUser.email?.address ?? validation.user?.email ?? "",
                verified: Boolean(apiUser.email?.verified),
            },
            metadata: {
                isFirstTime: Boolean(apiUser.metadata?.isFirstTime),
                profileColors: apiUser.metadata?.profileColors ?? [],
            },
        };

        req.user = requestUser;
        next();
    } catch (error) {
        if (error instanceof AuthServiceError) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, Please login to continue" });
        }

        console.error("Auth Middleware Error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Something went wrong, it's not your fault!" });
    }
}

export default authMiddleware;