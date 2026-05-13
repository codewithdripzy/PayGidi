import { model, models } from "mongoose";
import businessSchema from "../schemas/business.schema";

const BusinessModel = models.Business || model("Business", businessSchema, "businesses");

export default BusinessModel;
