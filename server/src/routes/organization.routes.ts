import { Router } from "express";
import authMiddleware from "../middlewares/auth.middleware";
import { validateSchema } from "../utils/validator";
import { createOrganizationDto, inviteOrganizationMemberDto } from "../validators/organization.dto";
import {
    AcceptOrganizationInviteController,
    CreateOrganizationController,
    DeleteOrganizationController,
    GetOrganizationController,
    InviteOrganizationMemberController,
    ListOrganizationInvitesController,
    ListOrganizationsController,
    UpdateOrganizationController,
} from "../controllers/organization.controller";
import {
    CreateOrganizationApiKeyController,
    ListOrganizationApiKeysController,
    RevokeOrganizationApiKeyController,
} from "../controllers/api-key.controller";

const organizationRouter = Router();

organizationRouter.use(authMiddleware);

organizationRouter.route("/").post(validateSchema(createOrganizationDto), CreateOrganizationController);
organizationRouter.route("/").get(ListOrganizationsController);
organizationRouter.route("/:organizationId").get(GetOrganizationController);
organizationRouter.route("/:organizationId").patch(UpdateOrganizationController);
organizationRouter.route("/:organizationId").delete(DeleteOrganizationController);

organizationRouter.route("/:organizationId/invites").post(validateSchema(inviteOrganizationMemberDto), InviteOrganizationMemberController);
organizationRouter.route("/:organizationId/invites").get(ListOrganizationInvitesController);
organizationRouter.route("/invites/accept/:token").post(AcceptOrganizationInviteController);

organizationRouter.route("/:organizationId/api-keys").get(ListOrganizationApiKeysController);
organizationRouter.route("/:organizationId/api-keys").post(CreateOrganizationApiKeyController);
organizationRouter.route("/:organizationId/api-keys/:keyUid").delete(RevokeOrganizationApiKeyController);

export default organizationRouter;
