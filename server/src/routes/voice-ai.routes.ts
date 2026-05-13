import { Router } from "express";
import authMiddleware from "../middlewares/auth.middleware";
import {
    ListAiProvidersController,
    GetVoiceAiConfigController,
    UpdateVoiceAiConfigController,
} from "../controllers/voice-ai.controller";

const voiceAiRouter = Router();

voiceAiRouter.use(authMiddleware);

voiceAiRouter.route("/providers").get(ListAiProvidersController);
voiceAiRouter.route("/:organizationId").get(GetVoiceAiConfigController);
voiceAiRouter.route("/:organizationId").patch(UpdateVoiceAiConfigController);

export default voiceAiRouter;
