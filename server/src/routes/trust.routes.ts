import { Router } from "express";
import trustController from "../controllers/trust.controller";
import authMiddleware from "../middlewares/auth.middleware";

const router = Router();

router.post("/evaluate/:businessId", authMiddleware, trustController.evaluate);
router.get("/history/:businessId", authMiddleware, trustController.getHistory);

export default router;
