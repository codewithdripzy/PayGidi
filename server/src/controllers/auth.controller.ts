import { Request, Response } from "express";
import { HTTP_RESPONSE_CODE } from "../core/constants/values";
import { OrelloAccountData } from "../core/interfaces/data";
import authService, { AuthServiceError } from "../services/auth.service";

const resolveBearerToken = (rawToken?: string) => {
    if (!rawToken || typeof rawToken !== "string") return "";

    const normalized = rawToken.trim();
    if (!normalized) return "";

    const tokenValue = normalized.toLowerCase().startsWith("bearer ")
        ? normalized.slice(7).trim()
        : normalized;

    if (!tokenValue || tokenValue === "undefined" || tokenValue === "null") {
        return "";
    }

    return `Bearer ${tokenValue}`;
};

const getAuthTokenFromRequest = (req: Request) => {
    const authHeaderToken = resolveBearerToken(req.headers.authorization);
    if (authHeaderToken) {
        return authHeaderToken;
    }

    const cookieToken = resolveBearerToken(req.cookies?.accessToken);
    if (cookieToken) {
        return cookieToken;
    }

    return "";
};

const getAuthContext = (req: Request) => ({
    token: getAuthTokenFromRequest(req),
    cookie: req.headers.cookie,
});

const LoginController = async (req: Request, res: Response) => {
    try {
        const { email, password } = req.body;

        const authRes: OrelloAccountData = await authService.login({ email, password });

        if (!authRes?.user || !authRes?.accessToken) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Invalid email or password" });
        }

        const { accessToken, user } = authRes;

        res.cookie("accessToken", accessToken, {
            httpOnly: true,
            secure: process.env.NODE_ENV === "production",
            sameSite: "strict",
            maxAge: 24 * 60 * 60 * 1000,
        });

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: authRes.message ?? `Welcome, ${user.firstName}`,
            accessToken,
            user: {
                id: user.id,
                firstName: user.firstName,
                lastName: user.lastName,
                email: user.email,
            },
        });
    } catch (error) {
        if (error instanceof AuthServiceError) {
            return res.status(error.statusCode).json({ message: error.message });
        }

        console.error("Login Error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Something went wrong, it's not your fault!" });
    }
};

const RegisterController = async (req: Request, res: Response) => {
    try {
        const { firstName, lastName, email, password } = req.body;

        const authRes: OrelloAccountData = await authService.register({ firstName, lastName, email, password });
        if (!authRes?.user || !authRes?.accessToken) {
            return res.status(HTTP_RESPONSE_CODE.BAD_REQUEST).json({ message: "Unable to create account at the moment, Something went wrong!" });
        }

        const { accessToken, user } = authRes;

        res.cookie("accessToken", accessToken, {
            httpOnly: true,
            secure: process.env.NODE_ENV === "production",
            sameSite: "strict",
            maxAge: 24 * 60 * 60 * 1000,
        });

        return res.status(HTTP_RESPONSE_CODE.CREATED).json({
            message: authRes.message ?? "Your account has been created successfully, Welcome to Orello",
            accessToken,
            user: {
                id: user.id,
                firstName: user.firstName,
                lastName: user.lastName,
                email: user.email,
            },
        });
    } catch (error) {
        if (error instanceof AuthServiceError) {
            return res.status(error.statusCode).json({ message: error.message });
        }

        console.error("Register Error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Something went wrong, it's not your fault!" });
    }
};

const GoogleController = async (req: Request, res: Response) => {
    try {
        const data = await authService.continueWithGoogle(req.body, getAuthContext(req));
        return res.status(HTTP_RESPONSE_CODE.OK).json(data);
    } catch (error) {
        if (error instanceof AuthServiceError) {
            return res.status(error.statusCode).json({ message: error.message });
        }

        console.error("Google Auth Error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to continue with Google" });
    }
};

const GithubController = async (req: Request, res: Response) => {
    try {
        const data = await authService.continueWithGithub(req.body, getAuthContext(req));
        return res.status(HTTP_RESPONSE_CODE.OK).json(data);
    } catch (error) {
        if (error instanceof AuthServiceError) {
            return res.status(error.statusCode).json({ message: error.message });
        }

        console.error("Github Auth Error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to continue with Github" });
    }
};

const GetAppDetailsController = async (req: Request, res: Response) => {
    try {
        const data = await authService.getOAuthDetails(getAuthContext(req));
        return res.status(HTTP_RESPONSE_CODE.OK).json(data);
    } catch (error) {
        if (error instanceof AuthServiceError) {
            return res.status(error.statusCode).json({ message: error.message });
        }

        console.error("Get OAuth App Details Error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to fetch oauth app details" });
    }
};

const AuthorizeController = async (req: Request, res: Response) => {
    try {
        const data = await authService.authorize(req.body, getAuthContext(req));
        return res.status(HTTP_RESPONSE_CODE.OK).json(data);
    } catch (error) {
        if (error instanceof AuthServiceError) {
            return res.status(error.statusCode).json({ message: error.message });
        }

        console.error("Authorize Error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Authorization request failed" });
    }
};

const VerifyAuthorizationController = async (req: Request, res: Response) => {
    try {
        const data = await authService.verifyAuthorization(req.body, getAuthContext(req));
        return res.status(HTTP_RESPONSE_CODE.OK).json(data);
    } catch (error) {
        if (error instanceof AuthServiceError) {
            return res.status(error.statusCode).json({ message: error.message });
        }

        console.error("Verify Authorization Error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to verify authorization" });
    }
};

const TokenController = async (req: Request, res: Response) => {
    try {
        const data = await authService.token(req.body, getAuthContext(req));
        return res.status(HTTP_RESPONSE_CODE.OK).json(data);
    } catch (error) {
        if (error instanceof AuthServiceError) {
            return res.status(error.statusCode).json({ message: error.message });
        }

        console.error("Token Controller Error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to issue token" });
    }
};

const ValidateAccessTokenController = async (req: Request, res: Response) => {
    try {
        const tokenFromBody = typeof req.body?.token === "string" ? req.body.token : "";
        const token = tokenFromBody || getAuthTokenFromRequest(req);

        if (!token) {
            return res.status(HTTP_RESPONSE_CODE.BAD_REQUEST).json({ message: "Access token is required" });
        }

        const data = await authService.validateAccessToken(token, getAuthContext(req));
        return res.status(HTTP_RESPONSE_CODE.OK).json(data);
    } catch (error) {
        if (error instanceof AuthServiceError) {
            return res.status(error.statusCode).json({ message: error.message });
        }

        console.error("Validate Access Token Error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to validate access token" });
    }
};

const LogoutController = async (req: Request, res: Response) => {
    try {
        await authService.logout(getAuthContext(req));
    } catch (error) {
        if (!(error instanceof AuthServiceError)) {
            console.error("Logout Error:", error);
        }
    }

    res.clearCookie("accessToken");
    res.clearCookie("refreshToken");
    return res.status(HTTP_RESPONSE_CODE.OK).json({ message: "Logged out successfully" });
};

const RefreshController = async (req: Request, res: Response) => {
    try {
        const data = await authService.refresh(getAuthContext(req));

        if (typeof data?.accessToken === "string" && data.accessToken) {
            res.cookie("accessToken", data.accessToken, {
                httpOnly: true,
                secure: process.env.NODE_ENV === "production",
                sameSite: "strict",
                maxAge: 24 * 60 * 60 * 1000,
            });
        }

        return res.status(HTTP_RESPONSE_CODE.OK).json(data);
    } catch (error) {
        if (error instanceof AuthServiceError) {
            return res.status(error.statusCode).json({ message: error.message });
        }

        console.error("Refresh Error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to refresh access token" });
    }
};

const SessionValidateController = async (req: Request, res: Response) => {
    // Auth middleware validates the token and attaches req.user
    // If we reach here, the session is valid
    if (!req.user) {
        return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Session is not valid" });
    }

    return res.status(HTTP_RESPONSE_CODE.OK).json({
        message: "Session is valid",
        user: req.user,
    });
};

export {
    LoginController,
    RegisterController,
    GoogleController,
    GithubController,
    GetAppDetailsController,
    AuthorizeController,
    VerifyAuthorizationController,
    TokenController,
    ValidateAccessTokenController,
    LogoutController,
    RefreshController,
    SessionValidateController,
};
