import { Router } from "express";
import controllers from "../controllers/wallet.controller";
import authMiddleware from "../middlewares/auth.middleware";

const router = Router();

// Wallet routes
router.post("/fund", authMiddleware, controllers.wallet.fund);

// Escrow routes
router.post("/escrow/create", authMiddleware, controllers.escrow.create);
router.post("/escrow/release/:transactionId", authMiddleware, controllers.escrow.release);
router.post("/escrow/refund/:transactionId", authMiddleware, controllers.escrow.refund);

export default router;
