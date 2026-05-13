import { Request, Response } from "express";
import { HTTP_RESPONSE_CODE } from "../core/constants/values";
import waitlistService from "../services/waitlist.service";

const CreateWaitlistEntryController = async (req: Request, res: Response) => {
    try {
        const { email, name, source } = req.body;

        const result = await waitlistService.createEntry({ email, name, source });

        return res.status(result.created ? HTTP_RESPONSE_CODE.CREATED : HTTP_RESPONSE_CODE.OK).json({
            message: result.created
                ? "You're on the early access list."
                : "You are already on the early access list.",
            success: true,
            data: result.entry,
        });
    } catch (error) {
        console.error("CreateWaitlistEntryController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({
            message: "Unable to join waitlist right now",
            success: false,
        });
    }
};

export { CreateWaitlistEntryController };
