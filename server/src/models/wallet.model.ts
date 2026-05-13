import { model, models } from "mongoose";
import walletSchema from "../schemas/wallet.schema";

const WalletModel = models.Wallet || model("Wallet", walletSchema, "wallets");

export default WalletModel;
