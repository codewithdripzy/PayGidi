import { model, models } from "mongoose";
import assistantDeploymentSchema from "../schemas/assistant-deployment.schema";

const AssistantDeploymentModel = models.AssistantDeployment || model("AssistantDeployment", assistantDeploymentSchema, "assistant_deployments");

export default AssistantDeploymentModel;
