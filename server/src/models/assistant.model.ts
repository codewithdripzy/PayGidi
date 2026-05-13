import { model, models } from "mongoose";
import assistantSchema from "../schemas/assistant.schema";

const AssistantModel = models.Assistant || model("Assistant", assistantSchema, "assistants");

export default AssistantModel;
