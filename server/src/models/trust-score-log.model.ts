import { model, models } from "mongoose";
import trustScoreLogSchema from "../schemas/trust-score-log.schema";

const TrustScoreLogModel = models.TrustScoreLog || model("TrustScoreLog", trustScoreLogSchema, "trust_score_logs");

export default TrustScoreLogModel;
