import { Request, Response } from "express";
import { HTTP_RESPONSE_CODE } from "../core/constants/values";
import assistantService from "../services/assistant.service";
import { uploadToCloudinary } from "../utils/cloudinary";
import providers from "../data/providers.json";
import { WebsiteCrawler } from "../utils/crawler";
import aiService from "../services/ai.service";

const resolveBearerToken = (rawToken?: string) => {
    if (!rawToken || typeof rawToken !== "string") return undefined;

    const normalized = rawToken.trim();
    if (!normalized) return undefined;

    const tokenValue = normalized.toLowerCase().startsWith("bearer ")
        ? normalized.slice(7).trim()
        : normalized;

    if (!tokenValue || tokenValue === "undefined" || tokenValue === "null") {
        return undefined;
    }

    return `Bearer ${tokenValue}`;
};

const getRequestToken = (req: Request) => {
    const authHeaderToken = resolveBearerToken(req.headers.authorization);
    if (authHeaderToken) return authHeaderToken;

    return resolveBearerToken(req.cookies?.accessToken);
};

type CreateAssistantKnowledgeBaseItem = {
    type: "website" | "file" | "faq" | "document" | "link" | "text";
    title: string;
    value: string;
    fileName?: string;
};

const isLikelyBinaryPayload = (value: string) => {
    if (!value) return false;
    if (value.includes("PK\u0003\u0004") || value.includes("PK\x03\x04")) return true;

    let nonPrintable = 0;
    for (let i = 0; i < value.length; i += 1) {
        const code = value.charCodeAt(i);
        const isPrintableAscii = code >= 32 && code <= 126;
        const isCommonWhitespace = code === 9 || code === 10 || code === 13;
        if (!isPrintableAscii && !isCommonWhitespace) {
            nonPrintable += 1;
        }
    }

    return nonPrintable / value.length > 0.2;
};

const normalizeKnowledgeBaseFromBracketKeys = (body: Record<string, unknown>) => {
    const map = new Map<number, Partial<CreateAssistantKnowledgeBaseItem>>();

    Object.entries(body).forEach(([key, rawValue]) => {
        const match = key.match(/^knowledgeBase\[(\d+)\]\[(type|title|value|fileName|file)\]$/);
        if (!match) return;

        const index = Number(match[1]);
        const field = match[2];
        const item = map.get(index) ?? {};

        if (typeof rawValue === "string") {
            if (field === "type") item.type = rawValue as CreateAssistantKnowledgeBaseItem["type"];
            if (field === "title") item.title = rawValue;
            if (field === "value") item.value = rawValue;
            if (field === "fileName") item.fileName = rawValue;
        }

        map.set(index, item);
    });

    return Array.from(map.entries())
        .sort((a, b) => a[0] - b[0])
        .map(([, item]) => item);
};

const normalizeInstructions = (raw: unknown): string[] => {
    if (Array.isArray(raw)) {
        return raw.filter((i) => typeof i === "string" && i.trim().length > 0).map((i) => i.trim());
    }
    if (typeof raw === "string" && raw.trim().length > 0) {
        try {
            const parsed = JSON.parse(raw);
            if (Array.isArray(parsed)) {
                return parsed.filter((i) => typeof i === "string" && i.trim().length > 0).map((i) => i.trim());
            }
        } catch {
            return [raw.trim()];
        }
    }
    return [];
};

const normalizeAccessControl = (raw: unknown) => {
    if (typeof raw === "string" && raw.trim().length > 0) {
        try {
            return JSON.parse(raw);
        } catch {
            return undefined;
        }
    }
    if (typeof raw === "object" && raw !== null) return raw;
    return undefined;
};

const normalizeCreateAssistantKnowledgeBase = (raw: unknown, body: Record<string, unknown>): CreateAssistantKnowledgeBaseItem[] => {
    let parsed: unknown[] = [];

    if (Array.isArray(raw)) {
        parsed = raw;
    } else if (typeof raw === "string" && raw.trim()) {
        try {
            const jsonParsed = JSON.parse(raw) as unknown;
            parsed = Array.isArray(jsonParsed) ? jsonParsed : [];
        } catch {
            parsed = [];
        }
    }

    const bracketItems = normalizeKnowledgeBaseFromBracketKeys(body);
    const sourceItems = bracketItems.length > 0 ? bracketItems : parsed;

    return sourceItems
        .map((rawItem) => rawItem as Partial<CreateAssistantKnowledgeBaseItem>)
        .filter((item) => typeof item.type === "string" && typeof item.title === "string")
        .map((item) => {
            const rawValue = typeof item.value === "string" ? item.value : "";
            const fileName = typeof item.fileName === "string" ? item.fileName.trim() : "";
            const sanitizedValue = isLikelyBinaryPayload(rawValue)
                ? fileName || item.title || ""
                : rawValue;

            return {
                type: item.type as CreateAssistantKnowledgeBaseItem["type"],
                title: item.title as string,
                value: sanitizedValue,
                fileName: fileName || undefined,
            };
        })
        .filter((item) => item.value.trim().length > 0 || item.type !== "file");
};

const CreateAssistantController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, login to continue" });
        }

        let knowledgeBase = normalizeCreateAssistantKnowledgeBase(req.body?.knowledgeBase, req.body as Record<string, unknown>);

        // Upload file-type knowledge base items to Cloudinary
        if (req.files && Array.isArray(req.files) && req.files.length > 0) {
            const uploadedFiles = new Map<string, string>();

            for (const file of req.files) {
                if (file.fieldname.startsWith('knowledgeBase[') && file.fieldname.includes('][file]')) {
                    const match = file.fieldname.match(/^knowledgeBase\[(\d+)\]\[file\]$/);
                    if (match) {
                        const index = Number(match[1]);
                        try {
                            const cloudinaryUrl = await uploadToCloudinary(file.buffer, file.originalname, 'knowledge-base');
                            if (cloudinaryUrl) {
                                uploadedFiles.set(`${index}`, cloudinaryUrl);
                            }
                        } catch (uploadError) {
                            console.error(`Failed to upload file for knowledge base item ${index}:`, uploadError);
                        }
                    }
                }
            }

            // Replace file content with Cloudinary URLs
            knowledgeBase = knowledgeBase.map((item, index) => {
                const url = uploadedFiles.get(`${index}`);
                if (url && item.type === 'file') {
                    return {
                        ...item,
                        value: url,
                    };
                }
                return item;
            });
        }

        const payload = {
            ...req.body,
            instructions: normalizeInstructions(req.body?.instructions),
            knowledgeBase,
            accessControl: normalizeAccessControl(req.body?.accessControl),
        };

        const assistant = await assistantService.createAssistant(user._id, payload, {
            token: getRequestToken(req),
            cookie: req.headers.cookie,
        });
        if (!assistant) {
            return res.status(HTTP_RESPONSE_CODE.NOT_FOUND).json({ message: "Organization not found or access denied" });
        }

        return res.status(HTTP_RESPONSE_CODE.CREATED).json({
            message: "Assistant created successfully",
            data: assistant,
            success: true,
        });
    } catch (error) {
        console.error("CreateAssistantController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to create assistant" });
    }
};

const ListOrganizationAssistantsController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, login to continue" });
        }

        const { organizationId } = req.params;
        const result = await assistantService.listAssistantsForOrganization(organizationId, user._id, {
            token: getRequestToken(req),
            cookie: req.headers.cookie,
        });
        if (!result) {
            return res.status(HTTP_RESPONSE_CODE.NOT_FOUND).json({ message: "Organization not found or access denied" });
        }

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: `Assistants fetched successfully - (${result.assistants.length}) row(s)`,
            data: result.assistants,
            success: true,
        });
    } catch (error) {
        console.error("ListOrganizationAssistantsController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to fetch assistants" });
    }
};

const GetAssistantController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, login to continue" });
        }
        const { assistantId } = req.params;
        const assistant = await assistantService.getAssistantForUser(assistantId, user._id, {
            token: getRequestToken(req),
            cookie: req.headers.cookie,
        });
        if (!assistant) {
            return res.status(HTTP_RESPONSE_CODE.NOT_FOUND).json({ message: "Assistant not found or access denied" });
        }

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: "Assistant fetched successfully",
            data: assistant,
            success: true,
        });
    } catch (error) {
        console.error("GetAssistantController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to fetch assistant" });
    }
};


const UpdateAssistantController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, login to continue" });
        }

        const { assistantId } = req.params;
        const payload = {
            ...req.body,
            instructions: normalizeInstructions(req.body?.instructions),
            accessControl: normalizeAccessControl(req.body?.accessControl),
            provider: typeof req.body?.provider === "string" && req.body.provider.trim().length > 0
                ? req.body.provider.trim()
                : undefined,
            model: typeof req.body?.model === "string" && req.body.model.trim().length > 0
                ? req.body.model.trim()
                : undefined,
        };

        console.log(`[UpdateAssistant] Updating ${assistantId}:`, {
            name: payload.name,
            provider: payload.provider,
            model: payload.model,
            tone: payload.tone,
            status: payload.status
        });

        const assistant = await assistantService.updateAssistant(assistantId, user._id, payload, {
            token: getRequestToken(req),
            cookie: req.headers.cookie,
        });
        if (!assistant) {
            return res.status(HTTP_RESPONSE_CODE.NOT_FOUND).json({ message: "Assistant not found or access denied" });
        }

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: "Assistant updated successfully",
            data: assistant,
            success: true,
        });
    } catch (error) {
        console.error("UpdateAssistantController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to update assistant" });
    }
};

const AddAssistantKnowledgeController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, login to continue" });
        }

        const { assistantId } = req.params;
        let payload = req.body;

        // Upload file to Cloudinary if present
        if (req.files && Array.isArray(req.files) && req.files.length > 0 && payload.type === 'file') {
            const file = req.files[0];
            try {
                const cloudinaryUrl = await uploadToCloudinary(file.buffer, file.originalname, 'knowledge-base');
                if (cloudinaryUrl) {
                    payload = {
                        ...payload,
                        value: cloudinaryUrl,
                    };
                }
            } catch (uploadError) {
                console.error('Failed to upload knowledge base file to Cloudinary:', uploadError);
                return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Failed to upload file" });
            }
        }

        const assistant = await assistantService.addKnowledgeBaseItem(assistantId, user._id, payload, {
            token: getRequestToken(req),
            cookie: req.headers.cookie,
        });
        if (!assistant) {
            return res.status(HTTP_RESPONSE_CODE.NOT_FOUND).json({ message: "Assistant not found or access denied" });
        }

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: "Knowledge base item added successfully",
            data: assistant,
            success: true,
        });
    } catch (error) {
        console.error("AddAssistantKnowledgeController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to update knowledge base" });
    }
};

const UpdateAssistantKnowledgeController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, login to continue" });
        }

        const { assistantId, knowledgeUid } = req.params;
        let payload = req.body as {
            title?: string;
            value?: string;
            fileName?: string;
            metadata?: Record<string, unknown>;
        };

        // Replace the existing file value with a fresh Cloudinary URL when a file is provided.
        if (req.files && Array.isArray(req.files) && req.files.length > 0) {
            const file = req.files[0];
            try {
                const cloudinaryUrl = await uploadToCloudinary(file.buffer, file.originalname, "knowledge-base");
                if (cloudinaryUrl) {
                    payload = {
                        ...payload,
                        fileName: file.originalname,
                        value: cloudinaryUrl,
                    };
                }
            } catch (uploadError) {
                console.error("Failed to upload knowledge base replacement file to Cloudinary:", uploadError);
                return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Failed to upload file" });
            }
        }

        const assistant = await assistantService.updateKnowledgeBaseItem(assistantId, user._id, knowledgeUid, payload, {
            token: getRequestToken(req),
            cookie: req.headers.cookie,
        });
        if (!assistant) {
            return res.status(HTTP_RESPONSE_CODE.NOT_FOUND).json({ message: "Assistant or knowledge item not found" });
        }

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: "Knowledge base item updated successfully",
            data: assistant,
            success: true,
        });
    } catch (error) {
        console.error("UpdateAssistantKnowledgeController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to update knowledge base item" });
    }
};

const DeployAssistantController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, login to continue" });
        }

        const { assistantId } = req.params;
        const assistant = await assistantService.deployAssistant(assistantId, user._id, req.body, {
            token: getRequestToken(req),
            cookie: req.headers.cookie,
        });
        if (!assistant) {
            return res.status(HTTP_RESPONSE_CODE.NOT_FOUND).json({ message: "Assistant not found or access denied" });
        }

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: "Assistant deployed successfully",
            data: {
                uid: assistant.uid,
                name: assistant.name,
                deployment: assistant.deployment,
            },
            success: true,
        });
    } catch (error) {
        console.error("DeployAssistantController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to deploy assistant" });
    }
};

const RemoveAssistantKnowledgeController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, login to continue" });
        }

        const { assistantId, knowledgeUid } = req.params;
        const assistant = await assistantService.removeKnowledgeBaseItem(assistantId, user._id, knowledgeUid, {
            token: getRequestToken(req),
            cookie: req.headers.cookie,
        });

        if (!assistant) {
            return res.status(HTTP_RESPONSE_CODE.NOT_FOUND).json({ message: "Assistant not found or access denied" });
        }

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: "Knowledge base item removed successfully",
            data: assistant,
            success: true,
        });
    } catch (error) {
        console.error("RemoveAssistantKnowledgeController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to remove knowledge base item" });
    }
};

const DeleteAssistantController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, login to continue" });
        }

        const { assistantId } = req.params;
        const assistant = await assistantService.deleteAssistant(assistantId, user._id, {
            token: getRequestToken(req),
            cookie: req.headers.cookie,
        });

        if (!assistant) {
            return res.status(HTTP_RESPONSE_CODE.NOT_FOUND).json({ message: "Assistant not found or access denied" });
        }

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: "Assistant deleted successfully",
            data: assistant,
            success: true,
        });
    } catch (error) {
        console.error("DeleteAssistantController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to delete assistant" });
    }
};

const UndeployAssistantController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, login to continue" });
        }

        const { assistantId } = req.params;
        const assistant = await assistantService.undeployAssistant(assistantId, user._id, {
            token: getRequestToken(req),
            cookie: req.headers.cookie,
        });
        if (!assistant) {
            return res.status(HTTP_RESPONSE_CODE.NOT_FOUND).json({ message: "Assistant not found or access denied" });
        }

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: "Assistant undeployed successfully",
            data: {
                uid: assistant.uid,
                name: assistant.name,
                deployment: assistant.deployment,
            },
            success: true,
        });
    } catch (error) {
        console.error("UndeployAssistantController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to undeploy assistant" });
    }
};

const ListAssistantDeploymentsController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, login to continue" });
        }

        const { assistantId } = req.params;
        const result = await assistantService.listDeployments(assistantId, user._id, {
            token: getRequestToken(req),
            cookie: req.headers.cookie,
        });
        if (!result) {
            return res.status(HTTP_RESPONSE_CODE.NOT_FOUND).json({ message: "Assistant not found or access denied" });
        }

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: `Deployments fetched successfully - (${result.deployments.length}) row(s)`,
            data: result.deployments,
            success: true,
        });
    } catch (error) {
        console.error("ListAssistantDeploymentsController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to fetch deployments" });
    }
};

const ListProvidersController = async (req: Request, res: Response) => {
    try {
        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: "Providers fetched successfully",
            data: providers,
            success: true,
        });
    } catch (error) {
        console.error("ListProvidersController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to fetch providers" });
    }
};

const CheckCrawlerStatusController = async (req: Request, res: Response) => {
    try {
        const { baseUrl } = req.query;
        if (!baseUrl || typeof baseUrl !== "string") {
            return res.status(HTTP_RESPONSE_CODE.BAD_REQUEST).json({ message: "baseUrl query parameter is required" });
        }

        const assistant = await assistantService.getAssistantByBaseUrl(baseUrl);
        if (!assistant) {
            return res.status(HTTP_RESPONSE_CODE.NOT_FOUND).json({
                message: "Assistant not found for this website",
                success: false,
                initialized: false
            });
        }

        const normalized = baseUrl.replace(/\/$/, "").toLowerCase();
        const site = (assistant.sites || []).find((s: any) => s.baseUrl.replace(/\/$/, "").toLowerCase() === normalized);

        const lastCrawledAt = site?.lastCrawledAt;
        const now = new Date();
        const sevenDaysInMs = 7 * 24 * 60 * 60 * 1000;

        const needsRecrawl = !lastCrawledAt || (now.getTime() - new Date(lastCrawledAt).getTime() > sevenDaysInMs);

        // if needs recrawl trigger a background crawl
        if (needsRecrawl) {
            (async () => {
                try {
                    const crawler = new WebsiteCrawler();
                    const crawlResult = await crawler.crawl(baseUrl);
                    
                    // Transform crawl result into structured understanding
                    const understanding = await aiService.understandSitemap(crawlResult);
                    
                    await assistantService.updateCrawlStatus(assistant.uid, baseUrl, new Date(), {
                        sitemap: understanding.pages,
                        summary: understanding.siteSummary
                    });
                    console.log(`[Webhook] Crawl and AI understanding completed for ${assistant.uid} at ${baseUrl}`);
                } catch (crawlError) {
                    console.error(`[Webhook] Background crawl/analysis failed for ${assistant.uid} at ${baseUrl}:`, crawlError);
                }
            })();
        }

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: "Assistant status fetched successfully",
            data: {
                uid: assistant.uid,
                name: assistant.name,
                initialized: true,
                lastCrawledAt,
                needsRecrawl,
            },
            success: true,
        });
    } catch (error) {
        console.error("CheckCrawlerStatusController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({
            message: "Unable to check assistant status",
            success: false
        });
    }
};

const DeploymentWebhookController = async (req: Request, res: Response) => {
    try {
        const { assistantId } = req.params;
        const payload = req.body;
        const baseUrl = payload.baseUrl || payload.url || payload.project_url || (req.query.baseUrl as string);

        if (!baseUrl) {
            return res.status(HTTP_RESPONSE_CODE.BAD_REQUEST).json({ 
                message: "baseUrl is required in payload or query",
                success: false 
            });
        }

        // Verify assistant exists by the ID provided in the URL
        const assistant = await assistantService.getAssistantByUid(assistantId);
        if (!assistant) {
            return res.status(HTTP_RESPONSE_CODE.NOT_FOUND).json({ 
                message: "Assistant not found",
                success: false 
            });
        }

        // Fire and forget crawl
        console.log(`[Webhook] Triggering re-crawl for assistant ${assistant.uid} at ${baseUrl}`);
        
        (async () => {
            try {
                const crawler = new WebsiteCrawler();
                const crawlResult = await crawler.crawl(baseUrl);
                
                // Transform crawl result into structured understanding
                const understanding = await aiService.understandSitemap(crawlResult);

                await assistantService.updateCrawlStatus(assistant.uid, baseUrl, new Date(), {
                    sitemap: understanding.pages,
                    summary: understanding.siteSummary
                });
                console.log(`[Webhook] Crawl successfully completed and status updated for ${assistant.uid} at ${baseUrl}`);
            } catch (crawlError) {
                console.error(`[Webhook] Background crawl failed for ${assistant.uid} at ${baseUrl}:`, crawlError);
            }
        })();

        return res.status(HTTP_RESPONSE_CODE.ACCEPTED).json({
            message: "Crawl re-initiation triggered",
            success: true,
        });
    } catch (error) {
        console.error("DeploymentWebhookController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ 
            message: "Unable to process deployment webhook",
            success: false 
        });
    }
};


const RegenerateAssistantKeyController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, login to continue" });
        }

        const { assistantId } = req.params;
        const assistant = await assistantService.regenerateWidgetKey(assistantId, user._id, {
            token: getRequestToken(req),
            cookie: req.headers.cookie,
        });

        if (!assistant) {
            return res.status(HTTP_RESPONSE_CODE.NOT_FOUND).json({ message: "Assistant not found or access denied" });
        }

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: "API key regenerated successfully",
            data: {
                widgetKey: assistant.deployment.widgetKey,
            },
            success: true,
        });
    } catch (error) {
        console.error("RegenerateAssistantKeyController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to regenerate API key" });
    }
};

export {
    CreateAssistantController,
    ListOrganizationAssistantsController,
    GetAssistantController,
    UpdateAssistantController,
    AddAssistantKnowledgeController,
    UpdateAssistantKnowledgeController,
    RemoveAssistantKnowledgeController,
    DeleteAssistantController,
    DeployAssistantController,
    UndeployAssistantController,
    ListAssistantDeploymentsController,
    ListProvidersController,
    CheckCrawlerStatusController,
    DeploymentWebhookController,
    RegenerateAssistantKeyController,
};
