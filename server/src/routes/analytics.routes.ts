import { Router } from "express";
import { validateSchema } from "../utils/validator";
import { queryAnalyticsDto, trackAnalyticsEventDto } from "../validators/analytics.dto";
import { GetAnalyticsOverviewController, GetAssistantAnalyticsController, TrackAnalyticsEventController } from "../controllers/analytics.controller";
import authMiddleware from "../middlewares/auth.middleware";

const analyticsRouter = Router();

analyticsRouter.route("/track").post(validateSchema(trackAnalyticsEventDto), TrackAnalyticsEventController);

analyticsRouter.use(authMiddleware);

analyticsRouter.route("/overview").get((req, _res, next) => {
    const { error, value } = queryAnalyticsDto.validate(req.query);
    if (!error) {
        req.query = value;
    }
    next();
}, GetAnalyticsOverviewController);

analyticsRouter.route("/assistant/:assistantId").get((req, _res, next) => {
    const { error, value } = queryAnalyticsDto.validate(req.query);
    if (!error) {
        req.query = value;
    }
    next();
}, GetAssistantAnalyticsController);

export default analyticsRouter;
