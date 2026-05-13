import { Router } from "express";
import { loginDto, registerDto, socialAuthDto, verifyOauthTokenDto } from "../validators/auth.dto";
import { validateSchema } from "../utils/validator";
import authMiddleware from "../middlewares/auth.middleware";
import {
	LoginController,
	RegisterController,
	GoogleController,
	GithubController,
	GetAppDetailsController,
	AuthorizeController,
	VerifyAuthorizationController,
	TokenController,
	LogoutController,
	RefreshController,
	ValidateAccessTokenController,
	SessionValidateController,
} from "../controllers/auth.controller";

const authRouter = Router();

authRouter.route("/login").post(validateSchema(loginDto), LoginController);
authRouter.route("/register").post(validateSchema(registerDto), RegisterController);

// social auth
authRouter.route("/continue/with/google").post(validateSchema(socialAuthDto), GoogleController);
authRouter.route("/continue/with/github").post(validateSchema(socialAuthDto), GithubController);

// OAuth
authRouter.route("/oauth/details").get(authMiddleware, GetAppDetailsController);
authRouter.route("/oauth/authorize").post(authMiddleware, AuthorizeController);
authRouter.route("/oauth/verify").post(validateSchema(verifyOauthTokenDto), VerifyAuthorizationController);
authRouter.route("/oauth/token").post(TokenController);

// session
authRouter.route("/logout").post(LogoutController);
authRouter.route("/refresh").post(RefreshController);
authRouter.route("/access-token/validate").post(ValidateAccessTokenController);
authRouter.route("/session").get(authMiddleware, SessionValidateController);

export default authRouter;
