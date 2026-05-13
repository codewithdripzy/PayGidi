import { model, models } from "mongoose";
import waitlistEntrySchema from "../schemas/waitlist-entry.schema";

const WaitlistEntryModel = models.WaitlistEntry || model("WaitlistEntry", waitlistEntrySchema, "waitlist_entries");

export default WaitlistEntryModel;
