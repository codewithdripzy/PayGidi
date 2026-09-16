import nodemailer from 'nodemailer';
import twilio from 'twilio';
import axios from 'axios';

class NotificationService {
  async sendSms(to: string, message: string) {
    if (
      !process.env.TWILIO_ACCOUNT_SID ||
      !process.env.TWILIO_AUTH_TOKEN ||
      !process.env.TWILIO_PHONE_NUMBER
    ) {
      if (process.env.NODE_ENV === 'production')
        throw new Error('SMS provider is not configured');
      console.info(`[PayGidi SMS] ${to}: ${message}`);
      return;
    }

    const client = twilio(
      process.env.TWILIO_ACCOUNT_SID,
      process.env.TWILIO_AUTH_TOKEN,
    );
    await client.messages.create({
      from: process.env.TWILIO_PHONE_NUMBER,
      to,
      body: message,
    });
  }

  async sendEmail(
    to: string,
    subject: string,
    message: string,
    emailType: 'register' | 'notification' | 'default' = 'default',
  ) {
    if (process.env.RESEND_API_KEY) {
      const fromByType = {
        register: process.env.RESEND_REGISTER_FROM_EMAIL,
        notification: process.env.RESEND_NOTIFICATION_FROM_EMAIL,
        default: process.env.RESEND_DEFAULT_FROM_EMAIL,
      };
      const from =
        fromByType[emailType] ||
        process.env.RESEND_DEFAULT_FROM_EMAIL ||
        'PayGidi <noreply@send.paygidi.site>';

      await axios.post(
        'https://api.resend.com/emails',
        { from, to: [to], subject, html: message },
        {
          headers: {
            Authorization: `Bearer ${process.env.RESEND_API_KEY}`,
            'Content-Type': 'application/json',
          },
          timeout: 10_000,
        },
      );
      return;
    }

    if (
      !process.env.EMAIL_HOST ||
      !process.env.EMAIL_USER ||
      !process.env.EMAIL_PASS
    ) {
      if (process.env.NODE_ENV === 'production')
        throw new Error('Email provider is not configured');
      console.info(`[PayGidi email] ${to}: ${subject}`);
      return;
    }

    const transporter = nodemailer.createTransport({
      host: process.env.EMAIL_HOST,
      port: Number(process.env.EMAIL_PORT || 587),
      secure: process.env.EMAIL_SECURE === 'true',
      auth: { user: process.env.EMAIL_USER, pass: process.env.EMAIL_PASS },
    });
    await transporter.sendMail({
      from: process.env.EMAIL_FROM || process.env.EMAIL_USER,
      to,
      subject,
      text: message,
    });
  }
}

export default new NotificationService();
