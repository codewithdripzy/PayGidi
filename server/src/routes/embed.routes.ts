import { Router } from "express";
import { GetPublicAssistantController, VerifyEmbedController } from "../controllers/embed.controller";
import { embedAuthMiddleware } from "../middlewares/embed.middleware";

const embedRouter = Router();

// All embed routes require X-Api-Key verification
embedRouter.use(embedAuthMiddleware);

/**
 * @route GET /api/v:version/embed/:assistantId
 * @desc Fetch public assistant details.
 * @access Public
 */
embedRouter.route("/:assistantId").get(GetPublicAssistantController);

/**
 * @route POST /api/v:version/embed/verify
 * @desc Verify if an assistant embedding is valid using its UID and widget key.
 * @access Public
 */
embedRouter.route("/verify").post(VerifyEmbedController);

export default embedRouter;
