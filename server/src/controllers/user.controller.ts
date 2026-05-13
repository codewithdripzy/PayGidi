import { Request, Response } from "express";
import { HTTP_RESPONSE_CODE } from "../core/constants/values";
import userService from "../services/user.service";

const GetAuthenticatedUserController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, login to continue" });
        }

        return res.status(HTTP_RESPONSE_CODE.OK).json({ message: "Authenticated user fetched successfully", data: user, success: true });
    } catch (error) {
        console.error("Error getting authenticated user:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Something went wrong, it's not your fault, Try logging out and logging in again, or contact support if the issue persists" });
    }
};

const UpdateAuthenticatedUserController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, login to continue" });
        }

        const authHeader = req.headers.authorization;
        const cookie = req.headers.cookie;

        const updatedUser = await userService.updateMe(req.body, { token: authHeader, cookie });

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: "User profile updated successfully",
            data: updatedUser,
            success: true,
        });
    } catch (error) {
        console.error("UpdateAuthenticatedUserController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to update user profile" });
    }
};

export { GetAuthenticatedUserController, UpdateAuthenticatedUserController };