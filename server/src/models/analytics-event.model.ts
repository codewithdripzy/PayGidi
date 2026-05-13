import { model, models } from "mongoose";
import analyticsEventSchema from "../schemas/analytics-event.schema";

const AnalyticsEventModel = models.AnalyticsEvent || model("AnalyticsEvent", analyticsEventSchema, "analytics_events");

export default AnalyticsEventModel;
