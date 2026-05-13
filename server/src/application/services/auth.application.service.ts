import UserModel from '../../models/user.model';
import { PasswordHasher } from '../../infrastructure/security/password.hasher';
import { TokenGenerator } from '../../infrastructure/security/token.generator';
import { notificationService } from '../../infrastructure/notifications/notification.service';
import logger from '../../infrastructure/logging/logger';

export class AuthApplicationService {
  async register(data: any) {
    const { name, email, password, phoneNumber } = data;

    // Check if user exists
    const existingUser = await UserModel.findOne({ $or: [{ email }, { phoneNumber }] });
    if (existingUser) {
      throw new Error('User with this email or phone number already exists');
    }

    const passwordHash = await PasswordHasher.hash(password);
    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString(); // 6-digit OTP
    const verificationExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    const user = await UserModel.create({
      name,
      email,
      passwordHash,
      phoneNumber,
      verificationCode,
      verificationExpires,
      isPhoneVerified: false,
      role: 'buyer'
    });

    // Send OTP via SMS
    try {
      await notificationService.sendSMS({
        to: phoneNumber,
        message: `Your PayGidi verification code is: ${verificationCode}. Valid for 10 minutes.`,
      });
      
      // Also send welcome email
      await notificationService.sendEmail({
        to: email,
        subject: 'Welcome to PayGidi',
        text: `Hi ${name}, welcome to PayGidi! Please verify your phone number to start using the platform.`,
      });
    } catch (err) {
      logger.error('Failed to send registration notifications', err);
      // We don't throw here to not break the registration, user can request resend
    }

    const accessToken = TokenGenerator.generate({ userId: user._id.toString(), role: user.role });

    return {
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phoneNumber: user.phoneNumber,
        isPhoneVerified: user.isPhoneVerified,
      },
      accessToken,
    };
  }

  async verifyPhone(userId: string, code: string) {
    const user = await UserModel.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }

    if (user.isPhoneVerified) {
      return { message: 'Phone already verified' };
    }

    if (user.verificationCode !== code || (user.verificationExpires && user.verificationExpires < new Date())) {
      throw new Error('Invalid or expired verification code');
    }

    user.isPhoneVerified = true;
    user.verificationCode = undefined;
    user.verificationExpires = undefined;
    await user.save();

    return { message: 'Phone verified successfully' };
  }

  async login(data: any) {
    const { email, password } = data;

    const user = await UserModel.findOne({ email });
    if (!user) {
      throw new Error('Invalid email or password');
    }

    const isPasswordValid = await PasswordHasher.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      throw new Error('Invalid email or password');
    }

    const accessToken = TokenGenerator.generate({ userId: user._id.toString(), role: user.role });

    return {
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phoneNumber: user.phoneNumber,
        isPhoneVerified: user.isPhoneVerified,
      },
      accessToken,
    };
  }
}

export const authApplicationService = new AuthApplicationService();
