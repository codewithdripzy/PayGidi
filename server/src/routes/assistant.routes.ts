import multer from "multer";
import { validateSchema } from "../utils/validator";
import { NextFunction, Request, Response, Router } from "express";
import { addKnowledgeBaseItemDto, createAssistantDto, deployAssistantDto, updateAssistantDto, updateKnowledgeBaseItemDto } from "../validators/assistant.dto";
import {
    AddAssistantKnowledgeController,
    CreateAssistantController,
    DeleteAssistantController,
    DeployAssistantController,
    GetAssistantController,
    ListAssistantDeploymentsController,
    ListOrganizationAssistantsController,
    RemoveAssistantKnowledgeController,
    UndeployAssistantController,
    UpdateAssistantKnowledgeController,
    UpdateAssistantController,
    ListProvidersController,
    CheckCrawlerStatusController,
    DeploymentWebhookController,
    RegenerateAssistantKeyController,
} from "../controllers/assistant.controller";
import { GetPublicAssistantController } from "../controllers/embed.controller";
import { embedAuthMiddleware } from "../middlewares/embed.middleware";
import { agentAuthMiddleware } from "../middlewares/agent.middleware";
import authMiddleware from "../middlewares/auth.middleware";

const assistantRouter = Router();
const upload = multer({
    storage: multer.memoryStorage(),
    limits: {
        // Allow large text values for knowledgeBase fields while still capping abuse.
        fieldSize: 10 * 1024 * 1024,
        fileSize: 25 * 1024 * 1024,
        fields: 200,
        files: 20,
    },
});

const uploadAnyWithLimits = (req: Request, res: Response, next: NextFunction) => {
    upload.any()(req, res, (err: unknown) => {
        if (!err) return next();

        if (err instanceof multer.MulterError) {
            const status = err.code === "LIMIT_FILE_SIZE" || err.code === "LIMIT_FIELD_VALUE"
                ? 413
                : 400;

            return res.status(status).json({
                message: err.code === "LIMIT_FIELD_VALUE"
                    ? "A form field is too large. Upload files via multipart file fields instead of sending binary content in text fields."
                    : err.message,
            });
        }

        return res.status(400).json({ message: "Invalid multipart form-data payload" });
    });
};

assistantRouter.route("/public/:assistantId").get(agentAuthMiddleware, embedAuthMiddleware, GetPublicAssistantController);
assistantRouter.route("/providers").get(ListProvidersController);
assistantRouter.route("/status").get(CheckCrawlerStatusController);
assistantRouter.route("/webhooks/:assistantId/deployment").post(DeploymentWebhookController);

assistantRouter.use(authMiddleware);

assistantRouter.route("/").post(uploadAnyWithLimits, validateSchema(createAssistantDto), CreateAssistantController);
assistantRouter.route("/organization/:organizationId").get(ListOrganizationAssistantsController);

assistantRouter.route("/:assistantId").get(GetAssistantController);
assistantRouter.route("/:assistantId").patch(uploadAnyWithLimits, validateSchema(updateAssistantDto), UpdateAssistantController);
assistantRouter.route("/:assistantId").delete(DeleteAssistantController);

assistantRouter.route("/:assistantId/knowledge").post(uploadAnyWithLimits, validateSchema(addKnowledgeBaseItemDto), AddAssistantKnowledgeController);
assistantRouter.route("/:assistantId/knowledge/:knowledgeUid").patch(uploadAnyWithLimits, validateSchema(updateKnowledgeBaseItemDto), UpdateAssistantKnowledgeController);
assistantRouter.route("/:assistantId/knowledge/:knowledgeUid").delete(RemoveAssistantKnowledgeController);
assistantRouter.route("/:assistantId/deploy").post(validateSchema(deployAssistantDto), DeployAssistantController);
assistantRouter.route("/:assistantId/regenerate-key").post(RegenerateAssistantKeyController);
assistantRouter.route("/:assistantId/undeploy").post(UndeployAssistantController);
assistantRouter.route("/:assistantId/deployments").get(ListAssistantDeploymentsController);

export default assistantRouter;
