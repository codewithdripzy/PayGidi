import WaitlistEntryModel from "../models/waitlist-entry.model";

class WaitlistService {
    async createEntry(payload: { email: string; name?: string; source?: string }) {
        const email = payload.email.trim().toLowerCase();

        const existing = await WaitlistEntryModel.findOne({ email });
        if (existing) return { created: false, entry: existing };

        const entry = await WaitlistEntryModel.create({
            email,
            name: payload.name?.trim() ?? "",
            source: payload.source?.trim() || "landing-page",
        });

        return { created: true, entry };
    }
}

const waitlistService = new WaitlistService();

export default waitlistService;
