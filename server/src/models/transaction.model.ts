import { model, models } from "mongoose";
import transactionSchema from "../schemas/transaction.schema";

const TransactionModel = models.Transaction || model("Transaction", transactionSchema, "transactions");

export default TransactionModel;
