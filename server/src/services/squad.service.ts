import axios, { AxiosInstance } from 'axios';

export class SquadProviderError extends Error {
  statusCode: number;

  constructor(message: string, statusCode = 502) {
    super(message);
    this.name = 'SquadProviderError';
    this.statusCode = statusCode;
  }
}

class SquadService {
  private client(): AxiosInstance {
    const secretKey = process.env.SQUAD_SECRET_KEY?.trim();
    if (!secretKey)
      throw new SquadProviderError('Squad is not configured', 503);

    return axios.create({
      baseURL:
        process.env.SQUAD_API_URL ||
        (process.env.NODE_ENV === 'production'
          ? 'https://api-d.squadco.com'
          : 'https://sandbox-api-d.squadco.com'),
      timeout: 15000,
      headers: {
        Accept: 'application/json',
        Authorization: `Bearer ${secretKey}`,
      },
    });
  }

  private async request<T>(
    method: 'get' | 'post',
    path: string,
    body?: unknown,
  ): Promise<T> {
    try {
      const response = await this.client().request<{
        success: boolean;
        message?: string;
        data: T;
      }>({ method, url: path, data: body });
      if (!response.data.success)
        throw new SquadProviderError(
          response.data.message || 'Squad request failed',
          502,
        );
      return response.data.data;
    } catch (error: any) {
      if (error instanceof SquadProviderError) throw error;
      const message =
        error.response?.data?.message ||
        error.message ||
        'Squad request failed';
      throw new SquadProviderError(
        message,
        error.response?.status >= 400 && error.response.status < 500
          ? 400
          : 502,
      );
    }
  }

  createVirtualAccount(payload: Record<string, unknown>) {
    return this.request('post', '/virtual-account', payload);
  }
  createBusinessVirtualAccount(payload: Record<string, unknown>) {
    return this.request('post', '/virtual-account/business', payload);
  }
  getCustomerTransactions(customerIdentifier: string) {
    return this.request(
      'get',
      `/virtual-account/customer/transactions/${encodeURIComponent(customerIdentifier)}`,
    );
  }
  getVirtualAccount(accountNumber: string) {
    return this.request(
      'get',
      `/virtual-account/customer/${encodeURIComponent(accountNumber)}`,
    );
  }
  simulatePayment(payload: Record<string, unknown>) {
    return this.request('post', '/virtual-account/simulate/payment', payload);
  }
  initiatePayment(payload: Record<string, unknown>) {
    return this.request('post', '/transaction/initiate', payload);
  }
  resolveAccount(payload: Record<string, unknown>) {
    return this.request('post', '/payout/account/lookup', payload);
  }
  initiateTransfer(payload: Record<string, unknown>) {
    return this.request('post', '/payout/transfer', payload);
  }
  getBanks() {
    return this.request('post', '/transaction/mandate/banklists', null);
  }
  getTransfers() {
    return this.request('get', '/payout/transactions');
  }
  requeryTransfer(reference: string) {
    return this.request(
      'get',
      `/payout/transactions/${encodeURIComponent(reference)}`,
    );
  }
  getDisputes() {
    return this.request('get', '/dispute');
  }
  getDisputeUploadUrl(ticketId: string, fileName: string) {
    return this.request(
      'get',
      `/disputes/${encodeURIComponent(ticketId)}/upload-url/${encodeURIComponent(fileName)}`,
    );
  }
  resolveDispute(ticketId: string, payload: Record<string, unknown>) {
    return this.request(
      'post',
      `/disputes/${encodeURIComponent(ticketId)}/resolve`,
      payload,
    );
  }
}

export default new SquadService();
