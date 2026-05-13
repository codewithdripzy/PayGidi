import Joi from "joi";

const trackAnalyticsEventDto = Joi.object({
    widgetKey: Joi.string().required(),
    eventType: Joi.string()
        .valid("session_started", "message_received", "message_resolved", "fallback", "handoff_requested", "deployment_view")
        .required(),
    sessionId: Joi.string().optional(),
    endUserId: Joi.string().optional(),
    value: Joi.number().default(1),
    metadata: Joi.object().unknown(true).optional(),
});

const queryAnalyticsDto = Joi.object({
    organizationId: Joi.string().optional(),
    range: Joi.string().valid("7d", "30d", "90d").default("7d"),
});

export { trackAnalyticsEventDto, queryAnalyticsDto };
