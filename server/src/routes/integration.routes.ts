import { Router } from "express";
import { ListIntegrationsController } from "../controllers/integration.controller";
import authMiddleware from "../middlewares/auth.middleware";

const integrationRouter = Router();

integrationRouter.use(authMiddleware);
integrationRouter.route("/").get(ListIntegrationsController);

export default integrationRouter;
