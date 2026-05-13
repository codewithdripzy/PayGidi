import ApiService, { ApiRequestContext } from "./api.service";

type OrganizationPayload = {
    name: string;
    description?: string;
    type?: "public" | "private";
};

export class OrganizationServiceError extends Error {
    statusCode: number;

    constructor(message: string, statusCode = 500) {
        super(message);
        this.name = "OrganizationServiceError";
        this.statusCode = statusCode;
    }
}

class OrganizationService extends ApiService {
    constructor() {
        super(process.env.ORELLO_ACCOUNTS_API_URL || "https://api.accounts.orello.space/api/v1");
    }

    private extractOrganizationsList(data: unknown) {
        if (Array.isArray(data)) {
            return data as Record<string, unknown>[];
        }

        if (data && typeof data === "object") {
            const payload = data as {
                data?: unknown;
                organizations?: unknown;
                items?: unknown;
            };

            if (Array.isArray(payload.data)) return payload.data as Record<string, unknown>[];
            if (Array.isArray(payload.organizations)) return payload.organizations as Record<string, unknown>[];
            if (Array.isArray(payload.items)) return payload.items as Record<string, unknown>[];
        }

        return [];
    }

    private extractOrganizationPayload(data: unknown) {
        if (!data || typeof data !== "object") {
            return null;
        }

        const payload = data as {
            data?: unknown;
            organization?: unknown;
        };

        if (payload.data && typeof payload.data === "object") {
            return payload.data as Record<string, unknown>;
        }

        if (payload.organization && typeof payload.organization === "object") {
            return payload.organization as Record<string, unknown>;
        }

        return data as Record<string, unknown>;
    }

    async createOrganization(payload: OrganizationPayload, context?: ApiRequestContext) {
        try {
            const res = await this.client.post(
                "/organizations",
                payload,
                this.getRequestConfig(context)
            );

            const organization = this.extractOrganizationPayload(res.data);
            if (!organization) {
                throw new OrganizationServiceError("Organization creation succeeded but payload is invalid", 500);
            }

            return {
                organization,
                trackedOrganization: null,
            };
        } catch (error) {
            const { message, statusCode } = this.getErrorDetails(error, "Unable to create organization at the moment");
            throw new OrganizationServiceError(message, statusCode);
        }
    }

    async deleteOrganization(organizationId: string, context?: ApiRequestContext) {
        try {
            const res = await this.client.delete(
                `/organizations/${organizationId}`,
                this.getRequestConfig(context)
            );

            return res.data;
        } catch (error) {
            const { message, statusCode } = this.getErrorDetails(error, "Unable to delete organization");
            throw new OrganizationServiceError(message, statusCode);
        }
    }

    async updateOrganization(organizationId: string, payload: Partial<OrganizationPayload>, context?: ApiRequestContext) {
        try {
            const res = await this.client.patch(
                `/organizations/${organizationId}`,
                payload,
                this.getRequestConfig(context)
            );

            return this.extractOrganizationPayload(res.data);
        } catch (error) {
            const { message, statusCode } = this.getErrorDetails(error, "Unable to update organization");
            throw new OrganizationServiceError(message, statusCode);
        }
    }

    async listOrganizationsForUser(context?: ApiRequestContext): Promise<{ organizations: Record<string, unknown>[]; trackedOrganizations: unknown[] }> {
        try {
            const res = await this.client.get(
                "/organization",
                this.getRequestConfig(context)
            );

            const organizations = this.extractOrganizationsList(res.data);

            return {
                organizations,
                trackedOrganizations: [],
            };
        } catch (error) {
            const { message, statusCode } = this.getErrorDetails(error, "Unable to fetch organizations");
            throw new OrganizationServiceError(message, statusCode);
        }
    }

    async getOrganizationForUser(organizationId: string, context?: ApiRequestContext) {
        try {
            const res = await this.client.get(
                `/organization/${organizationId}`,
                this.getRequestConfig(context)
            );

            return this.extractOrganizationPayload(res.data);
        } catch (error) {
            const { message, statusCode } = this.getErrorDetails(error, "Unable to fetch organization");
            throw new OrganizationServiceError(message, statusCode);
        }
    }

    async createInvitation(organizationId: string, payload: { email: string; role: "admin" | "member" }, context?: ApiRequestContext) {
        try {
            const res = await this.client.post(
                `/organizations/${organizationId}/invites`,
                payload,
                this.getRequestConfig(context)
            );

            return res.data;
        } catch (error) {
            const { message, statusCode } = this.getErrorDetails(error, "Unable to invite member");
            throw new OrganizationServiceError(message, statusCode);
        }
    }

    async listInvitations(organizationId: string, context?: ApiRequestContext) {
        try {
            const res = await this.client.get(
                `/organizations/${organizationId}/invites`,
                this.getRequestConfig(context)
            );

            return res.data;
        } catch (error) {
            const { message, statusCode } = this.getErrorDetails(error, "Unable to fetch invitations");
            throw new OrganizationServiceError(message, statusCode);
        }
    }

    async acceptInvitation(token: string, context?: ApiRequestContext) {
        try {
            const res = await this.client.post(
                `/organizations/invites/accept/${token}`,
                {},
                this.getRequestConfig(context)
            );

            return res.data;
        } catch (error) {
            const { message, statusCode } = this.getErrorDetails(error, "Unable to accept invitation");
            throw new OrganizationServiceError(message, statusCode);
        }
    }

    async addAssistantToOrganization(organizationId: unknown, assistantId: unknown) {
        try {
            const res = await this.client.patch(
                `/organizations/${String(organizationId)}/assistants`,
                { assistantId }
            );
            return res.data;
        } catch {
            return null;
        }
    }
}

const organizationService = new OrganizationService();

export default organizationService;
