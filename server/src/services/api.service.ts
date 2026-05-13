import axios, { type AxiosInstance } from "axios";
import { configDotenv } from "dotenv";

export type ApiRequestContext = {
    token?: string;
    cookie?: string;
};

abstract class ApiService {
    protected client: AxiosInstance;

    protected readonly accountsApiUrl: string;
    protected readonly appId: string;
    protected readonly clientKey: string;
    protected readonly clientSecret: string;

    constructor(baseURL?: string) {
        configDotenv();

        this.accountsApiUrl = process.env.ORELLO_ACCOUNTS_API_URL || "https://api.accounts.orello.space/api/v1";
        this.appId = process.env.ORELLO_APP_ID || "orello";
        this.clientKey = process.env.ORELLO_CLIENT_KEY || "";
        this.clientSecret = process.env.ORELLO_CLIENT_SECRET || "";

        this.client = axios.create({
            baseURL: baseURL ?? this.accountsApiUrl,
            withCredentials: true,
            headers: {
                "App-Id": this.appId,
                "Client-Key": this.clientKey,
                "Content-Type": "application/json",
                "Intent": "oauth",
            },
        });
    }

    protected getRequestConfig(context?: ApiRequestContext, params?: Record<string, unknown>) {
        const headers: Record<string, string> = {};

        if (context?.cookie) {
            headers.Cookie = context.cookie;
        }

        if (context?.token) {
            headers.Authorization = `Bearer ${context.token}`;
        }

        return {
            withCredentials: true,
            headers,
            params,
        };
    }

    protected getErrorDetails(error: unknown, fallbackMessage: string) {
        if (axios.isAxiosError(error)) {
            const responseData = error.response?.data as { message?: string } | undefined;
            const message = typeof responseData?.message === "string" && responseData.message.trim()
                ? responseData.message
                : fallbackMessage;

            return {
                message,
                statusCode: error.response?.status ?? 500,
            };
        }

        return {
            message: fallbackMessage,
            statusCode: 500,
        };
    }
}

export default ApiService;
