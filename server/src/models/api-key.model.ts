import { model, models } from "mongoose";
import apiKeySchema from "../schemas/api-key.schema";

const ApiKeyModel = models.ApiKey || model("ApiKey", apiKeySchema, "api_keys");

export default ApiKeyModel;
