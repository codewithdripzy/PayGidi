import nodemailer from 'nodemailer';
import axios from 'axios';

class NotificationService {
  async sendSms(to: string, message: string) {
    const apiKey = process.env.TERMII_API_KEY;
    const senderId = process.env.TERMII_SENDER_ID || 'Termii';

    if (!apiKey) {
      if (process.env.NODE_ENV === 'production') {
        throw new Error('Termii SMS provider is not configured');
      }

      console.info(`[PayGidi SMS] ${to}: ${message}`);
      return;
    }

    const normalizedPhone = to.replace(/[^0-9]/g, '').replace(/^0/, '234');
    const baseUrl = (
      process.env.TERMII_BASE_URL || 'https://api.ng.termii.com'
    ).replace(/\/$/, '');

    try {
      await axios.post(
        `${baseUrl}/api/sms/send`,
        {
          api_key: apiKey,
          to: normalizedPhone,
          from: senderId,
          sms: message,
          type: 'plain',
          channel: process.env.TERMII_CHANNEL || 'dnd',
        },
        {
          headers: { 'Content-Type': 'application/json' },
          timeout: 10_000,
        },
      );
    } catch (error: any) {
      const providerData = error?.response?.data;
      const providerErrors =
        providerData?.errors || providerData?.fields || providerData?.error;
      const fieldDetails = Array.isArray(providerErrors)
        ? providerErrors
            .map((item: any) => {
              const field = item?.field || item?.name || 'unknown field';
              const messages = Array.isArray(item?.messages)
                ? item.messages.join(', ')
                : item?.message || 'invalid value';
              return `${field}: ${messages}`;
            })
            .join('; ')
        : typeof providerErrors === 'object' && providerErrors !== null
          ? Object.entries(providerErrors)
              .map(([field, details]) => `${field}: ${String(details)}`)
              .join('; ')
          : '';
      const providerMessage = providerData?.message || 'SMS request rejected';
      const detail = fieldDetails ? ` (${fieldDetails})` : '';

      console.error('Termii SMS request failed', {
        status: error?.response?.status,
        providerData,
        phone: normalizedPhone,
        senderId,
        channel: process.env.TERMII_CHANNEL || 'dnd',
      });

      const smsError = new Error(
        `Termii SMS validation failed: ${providerMessage}${detail}`,
      ) as Error & { code?: string; statusCode?: number };
      smsError.code = 'TERMII_SMS_VALIDATION_ERROR';
      smsError.statusCode = 502;
      throw smsError;
    }
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
