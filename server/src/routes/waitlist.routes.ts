import { Router } from "express";
import { validateSchema } from "../utils/validator";
import { createWaitlistEntryDto } from "../validators/waitlist.dto";
import { CreateWaitlistEntryController } from "../controllers/waitlist.controller";

const waitlistRouter = Router();

waitlistRouter.route("/").post(validateSchema(createWaitlistEntryDto), CreateWaitlistEntryController);

export default waitlistRouter;
