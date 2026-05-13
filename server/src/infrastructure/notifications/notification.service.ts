import nodemailer from 'nodemailer';
import twilio from 'twilio';
import { INotificationService, EmailOptions, SMSOptions } from '../../application/interfaces/notification-service.interface';
import logger from '../logging/logger';

export class NotificationService implements INotificationService {
  private mailTransporter: nodemailer.Transporter;
  private twilioClient?: twilio.Twilio;

  constructor() {
    this.mailTransporter = nodemailer.createTransport({
      host: process.env.EMAIL_HOST || 'smtp.gmail.com',
      port: Number(process.env.EMAIL_PORT) || 587,
      secure: process.env.EMAIL_SECURE === 'true',
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
    });

    if (process.env.TWILIO_ACCOUNT_SID && process.env.TWILIO_AUTH_TOKEN) {
      this.twilioClient = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);
    } else {
      logger.warn('Twilio credentials not provided. SMS service will be unavailable.');
    }
  }

  async sendEmail(options: EmailOptions): Promise<void> {
    try {
      await this.mailTransporter.sendMail({
        from: process.env.EMAIL_FROM || '"PayGidi" <noreply@paygidi.com>',
        ...options,
      });
      logger.info(`Email sent to ${options.to}: ${options.subject}`);
    } catch (error) {
      logger.error(`Failed to send email to ${options.to}`, error);
      throw error;
    }
  }

  async sendSMS(options: SMSOptions): Promise<void> {
    if (!this.twilioClient) {
      logger.error('SMS Service unavailable: Twilio not configured');
      return;
    }

    try {
      await this.twilioClient.messages.create({
        body: options.message,
        to: options.to,
        from: process.env.TWILIO_PHONE_NUMBER,
      });
      logger.info(`SMS sent to ${options.to}`);
    } catch (error) {
      logger.error(`Failed to send SMS to ${options.to}`, error);
      throw error;
    }
  }
}

export const notificationService = new NotificationService();
