export interface AccountData {
    message?: string;
    accessToken?: string;
    user?: {
        id: string;
        name: string;
        email: string;
    };
}

export interface AccessTokenValidationUser {
    id?: string;
    email?: string;
    firstName?: string;
    lastName?: string;
}

export interface AccessTokenValidationData {
    valid?: boolean;
    user?: AccessTokenValidationUser;
}

export interface CurrentUserData {
    _id?: string;
    id?: string;
    uid?: string;
    orelloId?: string;
    firstName?: string;
    lastName?: string;
    otherName?: string | null;
    username?: string | null;
    bio?: string | null;
    email?: {
        _id?: string;
        address?: string;
        verified?: boolean;
    };
    metadata?: {
        _id?: string;
        isFirstTime?: boolean;
        profileColors?: string[];
    };
    status?: string;
    deletedAt?: string | null;
    createdAt?: string;
    updatedAt?: string;
    connectedApps?: string[];
}

export interface RequestUserData {
    _id: string;
    name: string;
    email: string;
    phoneNumber: string;
    isPhoneVerified: boolean;
    role: string;
}

export interface UserData {
    name: string;
    email: string;
    phoneNumber: string;
    password: string;
}

export interface WorkspaceData {
    name: string;
    description?: string;
    type: "public" | "private";
    owner: unknown;
}

export interface ProjectData {
    name: string;
    description?: string;
    type: "public" | "private";
    framework: {
        id: string;
        version: string;
    };
    workspace: string;
    owner: unknown;
}