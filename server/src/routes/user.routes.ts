import { Router } from "express";
import authMiddleware from "../middlewares/auth.middleware";
import { GetAuthenticatedUserController, UpdateAuthenticatedUserController } from "../controllers/user.controller";

const userRouter = Router();

userRouter.use(authMiddleware);
userRouter.route("/").get(GetAuthenticatedUserController);
userRouter.route("/").patch(UpdateAuthenticatedUserController);

export default userRouter;
