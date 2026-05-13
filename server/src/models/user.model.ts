import { model, models } from "mongoose";
import userSchema from "../schemas/user.schema";

const UserModel = models.User || model("User", userSchema, "users");

export default UserModel;
