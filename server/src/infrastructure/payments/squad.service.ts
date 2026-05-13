import axios from 'axios';
import logger from '../logging/logger';

export interface SquadTransactionInitiateResponse {
  status: number;
  success: boolean;
  message: string;
  data: {
    checkout_url: string;
    transaction_ref: string;
  };
}

export class SquadService {
  private readonly secretKey = process.env.SQUAD_SECRET_KEY;
  private readonly baseUrl = process.env.NODE_ENV === 'production' 
    ? 'https://api-d.squadco.com' 
    : 'https://sandbox-api-d.squadco.com';

  async initiateTransaction(payload: {
    amount: number;
    email: string;
    currency: string;
    transaction_ref: string;
    callback_url?: string;
  }): Promise<SquadTransactionInitiateResponse['data']> {
    try {
      const response = await axios.post<SquadTransactionInitiateResponse>(
        `${this.baseUrl}/transaction/initiate`,
        {
          ...payload,
          amount: payload.amount * 100, // Convert to kobo
          initiate_type: 'inline',
        },
        {
          headers: {
            Authorization: `Bearer ${this.secretKey}`,
          },
        }
      );

      if (!response.data.success) {
        throw new Error(response.data.message || 'Failed to initiate Squad transaction');
      }

      return response.data.data;
    } catch (error: any) {
      logger.error('Squad Transaction Initiation Error:', error.response?.data || error.message);
      throw error;
    }
  }

  async verifyTransaction(transactionRef: string): Promise<boolean> {
    try {
      const response = await axios.get(
        `${this.baseUrl}/transaction/verify/${transactionRef}`,
        {
          headers: {
            Authorization: `Bearer ${this.secretKey}`,
          },
        }
      );

      return response.data.success && response.data.data.status === 'success';
    } catch (error: any) {
      logger.error('Squad Transaction Verification Error:', error.response?.data || error.message);
      return false;
    }
  }
}

export const squadService = new SquadService();
