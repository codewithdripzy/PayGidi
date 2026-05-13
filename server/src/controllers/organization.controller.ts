import { Request, Response } from "express";
import { HTTP_RESPONSE_CODE } from "../core/constants/values";
import organizationService, { OrganizationServiceError } from "../services/organization.service";

const resolveBearerToken = (rawToken?: string) => {
    if (!rawToken || typeof rawToken !== "string") return undefined;

    const normalized = rawToken.trim();
    if (!normalized) return undefined;

    const tokenValue = normalized.toLowerCase().startsWith("bearer ")
        ? normalized.slice(7).trim()
        : normalized;

    if (!tokenValue || tokenValue === "undefined" || tokenValue === "null") {
        return undefined;
    }

    return `Bearer ${tokenValue}`;
};

const getRequestToken = (req: Request) => {
    const authHeaderToken = resolveBearerToken(req.headers.authorization);
    if (authHeaderToken) return authHeaderToken;

    return resolveBearerToken(req.cookies?.accessToken);
};

const CreateOrganizationController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, login to continue" });
        }

        // const organization = await organizationService.createOrganization(
        //     {
        //         _id: user._id,
        //         uid: user.uid,
        //         email: user.email,
        //     },
        //     req.body,
        //     { token: getRequestToken(req), cookie: req.headers.cookie }
        // );

        // return res.status(HTTP_RESPONSE_CODE.CREATED).json({
        //     message: "Organization created successfully",
        //     data: organization.organization,
        //     trackedOrganization: organization.trackedOrganization,
        //     success: true,
        // });
    } catch (error) {
        if (error instanceof OrganizationServiceError) {
            return res.status(error.statusCode).json({ message: error.message, success: false });
        }

        console.error("CreateOrganizationController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to create organization at the moment" });
    }
};

const ListOrganizationsController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, login to continue" });
        }

        const result = await organizationService.listOrganizationsForUser(
            { token: getRequestToken(req), cookie: req.headers.cookie }
        );

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: `Organizations fetched successfully - (${result.organizations.length}) row(s)`,
            data: result.organizations,
            success: true,
        });
    } catch (error) {
        if (error instanceof OrganizationServiceError) {
            return res.status(error.statusCode).json({ message: error.message, success: false });
        }

        console.error("ListOrganizationsController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to fetch organizations" });
    }
};

const GetOrganizationController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, login to continue" });
        }

        const { organizationId } = req.params;
        const organization = await organizationService.getOrganizationForUser(
            organizationId,
            { token: getRequestToken(req), cookie: req.headers.cookie }
        );

        if (!organization) {
            return res.status(HTTP_RESPONSE_CODE.NOT_FOUND).json({ message: "Organization not found or access denied" });
        }

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: "Organization fetched successfully",
            data: organization,
            success: true,
        });
    } catch (error) {
        console.error("GetOrganizationController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to fetch organization" });
    }
};

const DeleteOrganizationController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, login to continue" });
        }

        const { organizationId } = req.params;
        await organizationService.deleteOrganization(
            organizationId,
            { token: getRequestToken(req), cookie: req.headers.cookie }
        );

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: "Organization deleted successfully",
            success: true,
        });
    } catch (error) {
        if (error instanceof OrganizationServiceError) {
            return res.status(error.statusCode).json({ message: error.message, success: false });
        }

        console.error("DeleteOrganizationController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to delete organization" });
    }
};

const UpdateOrganizationController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, login to continue" });
        }

        const { organizationId } = req.params;
        const organization = await organizationService.updateOrganization(
            organizationId,
            req.body,
            { token: getRequestToken(req), cookie: req.headers.cookie }
        );

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: "Organization updated successfully",
            data: organization,
            success: true,
        });
    } catch (error) {
        if (error instanceof OrganizationServiceError) {
            return res.status(error.statusCode).json({ message: error.message, success: false });
        }

        console.error("UpdateOrganizationController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to update organization" });
    }
};

const InviteOrganizationMemberController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, login to continue" });
        }

        const { organizationId } = req.params;
        const result = await organizationService.createInvitation(
            organizationId,
            req.body,
            { token: getRequestToken(req), cookie: req.headers.cookie }
        );

        const data = (result as { data?: unknown; invite?: unknown })?.data ?? (result as { invite?: unknown })?.invite ?? result;

        return res.status(HTTP_RESPONSE_CODE.CREATED).json({
            message: "Invitation created successfully",
            data,
            success: true,
        });
    } catch (error) {
        if (error instanceof OrganizationServiceError) {
            return res.status(error.statusCode).json({ message: error.message, success: false });
        }

        console.error("InviteOrganizationMemberController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to invite member" });
    }
};

const ListOrganizationInvitesController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, login to continue" });
        }

        const { organizationId } = req.params;
        const result = await organizationService.listInvitations(
            organizationId,
            { token: getRequestToken(req), cookie: req.headers.cookie }
        );

        const invites = (result as { data?: unknown[]; invites?: unknown[] })?.data
            ?? (result as { invites?: unknown[] })?.invites
            ?? [];

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: `Invitations fetched successfully - (${invites.length}) row(s)`,
            data: invites,
            success: true,
        });
    } catch (error) {
        if (error instanceof OrganizationServiceError) {
            return res.status(error.statusCode).json({ message: error.message, success: false });
        }

        console.error("ListOrganizationInvitesController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to fetch invitations" });
    }
};

const AcceptOrganizationInviteController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, login to continue" });
        }

        const { token } = req.params;
        const result = await organizationService.acceptInvitation(
            token,
            { token: getRequestToken(req), cookie: req.headers.cookie }
        );

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: "Invitation accepted successfully",
            data: result,
            success: true,
        });
    } catch (error) {
        if (error instanceof OrganizationServiceError) {
            return res.status(error.statusCode).json({ message: error.message, success: false });
        }

        console.error("AcceptOrganizationInviteController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to accept invitation" });
    }
};

export {
    CreateOrganizationController,
    ListOrganizationsController,
    GetOrganizationController,
    DeleteOrganizationController,
    InviteOrganizationMemberController,
    ListOrganizationInvitesController,
    AcceptOrganizationInviteController,
    UpdateOrganizationController,
};
