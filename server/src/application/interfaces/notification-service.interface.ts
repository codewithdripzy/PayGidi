export interface EmailOptions {
  to: string;
  subject: string;
  text?: string;
  html?: string;
}

export interface SMSOptions {
  to: string;
  message: string;
}

export interface INotificationService {
  sendEmail(options: EmailOptions): Promise<void>;
  sendSMS(options: SMSOptions): Promise<void>;
}
