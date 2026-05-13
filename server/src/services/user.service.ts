import ApiService, { ApiRequestContext } from "./api.service";
import { CurrentUserData } from "../core/interfaces/data";

class UserService extends ApiService {
    constructor() {
        super(process.env.ORELLO_ACCOUNTS_API_URL || "https://api.accounts.orello.space/api/v1");
    }

    async getMe(context?: ApiRequestContext): Promise<CurrentUserData | null> {
        try {
            const res = await this.client.get("/me", this.getRequestConfig(context));
            const data = res.data as { user?: CurrentUserData  } & CurrentUserData;
            return data.user ?? data;
        } catch(error) {
            console.log("Failed to fetch current user data:", error);
            return null;
        }
    }

    async updateMe(payload: Record<string, unknown>, context?: ApiRequestContext) {
        try {
            const res = await this.client.patch("/me", payload, this.getRequestConfig(context));
            return res.data;
        } catch (error) {
            console.error("Failed to update user data:", error);
            throw error;
        }
    }
}

const userService = new UserService();
export default userService;
