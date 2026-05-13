import ApiService, { ApiRequestContext } from "./api.service";

export class AuthServiceError extends Error {
    statusCode: number;

    constructor(message: string, statusCode = 500) {
        super(message);
        this.name = "AuthServiceError";
        this.statusCode = statusCode;
    }
}

class AuthService extends ApiService {
    constructor() {
        super(((process.env.ORELLO_ACCOUNTS_API_URL || "https://api.accounts.orello.space/api/v1") + "/auth").replace(/\/+$/, ""));
    }

    async login({ email, password }: { email: string, password: string }) {
        try {
            const res = await this.client.post("/login", { email, password });
            return res.data;
        } catch (error) {
            // console.log(error)
            const { message, statusCode } = this.getErrorDetails(error, "Something went wrong, it's not your fault!");
            console.error("Login Error:", message);
            throw new AuthServiceError(message, statusCode);
        }
    }

    async register({ firstName, lastName, email, password }: { firstName: string, lastName: string, email: string, password: string }) {
        try {
            const res = await this.client.post("/register", { firstName, lastName, email, password });
            return res.data;
        } catch (error) {
            const { message, statusCode } = this.getErrorDetails(error, "Unable to create account at the moment, Something went wrong!");
            console.error("Registration Error:", message);
            throw new AuthServiceError(message, statusCode);
        }
    }

    async continueWithGoogle(payload: Record<string, unknown>, context?: ApiRequestContext) {
        try {
            const res = await this.client.post("/continue/with/google", payload, this.getRequestConfig(context));
            return res.data;
        } catch (error) {
            const { message, statusCode } = this.getErrorDetails(error, "Something went wrong with Google authentication, please try again!");
            throw new AuthServiceError(message, statusCode);
        }
    }

    async continueWithGithub(payload: Record<string, unknown>, context?: ApiRequestContext) {
        try {
            const res = await this.client.post("/continue/with/github", payload, this.getRequestConfig(context));
            return res.data;
        } catch (error) {
            const { message, statusCode } = this.getErrorDetails(error, "Something went wrong with GitHub authentication, please try again!");
            throw new AuthServiceError(message, statusCode);
        }
    }

    async getOAuthDetails(context?: ApiRequestContext) {
        try {
            const res = await this.client.get("/oauth/details", this.getRequestConfig(context));
            return res.data;
        } catch (error) {
            const { message, statusCode } = this.getErrorDetails(error, "Unable to fetch oauth app details");
            throw new AuthServiceError(message, statusCode);
        }
    }

    async authorize(payload: Record<string, unknown>, context?: ApiRequestContext) {
        try {
            const res = await this.client.post("/oauth/authorize", payload, this.getRequestConfig(context));
            return res.data;
        } catch (error) {
            const { message, statusCode } = this.getErrorDetails(error, "Authorization request failed");
            throw new AuthServiceError(message, statusCode);
        }
    }

    async verifyAuthorization(payload: Record<string, unknown>, context?: ApiRequestContext) {
        try {
            const res = await this.client.post("/oauth/verify", payload, this.getRequestConfig(context));
            return res.data;
        } catch (error) {
            const { message, statusCode } = this.getErrorDetails(error, "Unable to verify oauth token");
            throw new AuthServiceError(message, statusCode);
        }
    }

    async token(payload: Record<string, unknown>, context?: ApiRequestContext) {
        try {
            const res = await this.client.post("/oauth/token", payload, this.getRequestConfig(context));
            return res.data;
        } catch (error) {
            const { message, statusCode } = this.getErrorDetails(error, "Unable to issue oauth token");
            throw new AuthServiceError(message, statusCode);
        }
    }

    async logout(context?: ApiRequestContext) {
        try {
            const res = await this.client.post("/logout", {}, this.getRequestConfig(context));
            return res.data;
        } catch (error) {
            const { message, statusCode } = this.getErrorDetails(error, "Unable to logout at the moment");
            throw new AuthServiceError(message, statusCode);
        }
    }

    async refresh(context?: ApiRequestContext) {
        try {
            const res = await this.client.post("/refresh", {}, this.getRequestConfig(context));
            return res.data;
        } catch (error) {
            const { message, statusCode } = this.getErrorDetails(error, "Unable to refresh access token");
            throw new AuthServiceError(message, statusCode);
        }
    }

    async getMe(context?: ApiRequestContext) {
        try {
            const res = await this.client.get("/me", this.getRequestConfig(context));
            return res.data;
        } catch (error) {
            const { message, statusCode } = this.getErrorDetails(error, "Unable to fetch authenticated user");
            throw new AuthServiceError(message, statusCode);
        }
    }

    async verifyToken(token: string, context?: ApiRequestContext) {
        return this.validateAccessToken(token, context);
    }

    async validateAccessToken(token: string, context?: ApiRequestContext) {
        try {
            const res = await this.client.post(
                "/access-token/validate",
                { token },
                this.getRequestConfig({ ...context, token })
            );
            return res.data;
        } catch (error) {
            const { message, statusCode } = this.getErrorDetails(error, "Invalid or expired access token");
            throw new AuthServiceError(message, statusCode);
        }
    }
}

const authService = new AuthService();
export default authService;