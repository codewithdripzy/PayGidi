import { Router } from "express";
import businessController from "../controllers/business.controller";
import authMiddleware from "../middlewares/auth.middleware";

const router = Router();

router.post("/onboard", authMiddleware, businessController.onboard);
router.post("/verify", authMiddleware, (req, res) => res.status(501).json({ message: "Not implemented" }));
router.get("/:id", businessController.getBusiness);
router.get("/:id/trust-score", businessController.getTrustScore);

export default router;
