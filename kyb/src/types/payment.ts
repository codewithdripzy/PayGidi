export interface PersonData {
  firstName: string;
  lastName: string;
}

export interface UserData {
  personData: PersonData;
  email: string;
  phone: string;
  username: string;
  profilePic?: string;
  status: string;
}

export type PaymentStatus = "pending" | "disbursed" | "refunded" | "action_required" | "rejected" | "in_progress";

export interface Payment {
  id: number;
  userId: string;
  amount: number;
  accountNumber: string;
  bank: string;
  merchantPhoneNumber: string;
  merchantEmail: string;
  advanceOptions?: string;
  status: PaymentStatus;
  summary?: string;
  trustScore?: number;
  expiresAt?: string;
  createdAt: string;
  updatedAt: string;
}

export interface PaymentResponse {
  status: number;
  success: boolean;
  message: string;
  data: {
    payment: Payment;
    customer: UserData;
  };
}
