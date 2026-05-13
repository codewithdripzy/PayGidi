import integrations from "../data/integrations.json";

type IntegrationFieldType = "text" | "password" | "toggle" | "select";
type IntegrationAvailability = "stable" | "beta" | "coming-soon";

type IntegrationField = {
    id: string;
    label: string;
    type: IntegrationFieldType;
    required?: boolean;
    placeholder?: string;
    options?: string[];
    defaultValue?: string | boolean;
};

type IntegrationRecord = {
    id: string;
    key?: string;
    name: string;
    description?: string;
    category?: string;
    provider?: string;
    icon?: string;
    status?: {
        enabled?: boolean;
        connected?: boolean;
        availability?: IntegrationAvailability;
    };
    capabilities?: string[];
    authorization?: {
        type?: string;
        fields?: IntegrationField[];
    };
    settings?: IntegrationField[];
    actions?: {
        allowEnable?: boolean;
        allowConfigure?: boolean;
    };
};

const asString = (value: unknown, fallback = "") => {
    if (typeof value === "string") {
        const trimmed = value.trim();
        return trimmed || fallback;
    }

    return fallback;
};

const asBoolean = (value: unknown, fallback = false) => {
    if (typeof value === "boolean") return value;
    return fallback;
};

const isFieldType = (value: unknown): value is IntegrationFieldType => {
    return value === "text" || value === "password" || value === "toggle" || value === "select";
};

class IntegrationService {
    private normalizeField(field: unknown): IntegrationField | null {
        if (!field || typeof field !== "object") return null;

        const candidate = field as Record<string, unknown>;
        const type = isFieldType(candidate.type) ? candidate.type : "text";

        const normalized: IntegrationField = {
            id: asString(candidate.id),
            label: asString(candidate.label),
            type,
            required: asBoolean(candidate.required, false),
        };

        const placeholder = asString(candidate.placeholder);
        if (placeholder) normalized.placeholder = placeholder;

        if (Array.isArray(candidate.options)) {
            normalized.options = candidate.options.filter((option) => typeof option === "string" && option.trim().length > 0);
        }

        if (typeof candidate.defaultValue === "string" || typeof candidate.defaultValue === "boolean") {
            normalized.defaultValue = candidate.defaultValue;
        }

        if (!normalized.id || !normalized.label) return null;
        return normalized;
    }

    private normalizeIntegration(item: unknown) {
        if (!item || typeof item !== "object") return null;

        const candidate = item as IntegrationRecord;
        const id = asString(candidate.id);
        const name = asString(candidate.name);
        if (!id || !name) return null;

        const authFields = Array.isArray(candidate.authorization?.fields)
            ? candidate.authorization?.fields.map((field) => this.normalizeField(field)).filter((field): field is IntegrationField => Boolean(field))
            : [];

        const settings = Array.isArray(candidate.settings)
            ? candidate.settings.map((field) => this.normalizeField(field)).filter((field): field is IntegrationField => Boolean(field))
            : [];

        return {
            id,
            key: asString(candidate.key, id),
            name,
            description: asString(candidate.description),
            category: asString(candidate.category, "other"),
            provider: asString(candidate.provider, id),
            icon: asString(candidate.icon, id),
            status: {
                enabled: asBoolean(candidate.status?.enabled, false),
                connected: asBoolean(candidate.status?.connected, false),
                availability: asString(candidate.status?.availability, "stable"),
            },
            capabilities: Array.isArray(candidate.capabilities)
                ? candidate.capabilities.filter((capability) => typeof capability === "string" && capability.trim().length > 0)
                : [],
            authorization: {
                type: asString(candidate.authorization?.type, "apiKey"),
                fields: authFields,
            },
            settings,
            actions: {
                allowEnable: asBoolean(candidate.actions?.allowEnable, true),
                allowConfigure: asBoolean(candidate.actions?.allowConfigure, true),
            },
        };
    }

    listIntegrations() {
        return integrations
            .map((item) => this.normalizeIntegration(item))
            .filter((item): item is NonNullable<ReturnType<IntegrationService["normalizeIntegration"]>> => Boolean(item));
    }
}

const integrationService = new IntegrationService();
export default integrationService;
