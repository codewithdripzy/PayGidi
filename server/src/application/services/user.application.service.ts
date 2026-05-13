import UserModel from '../../models/user.model';
import { NotFoundError } from '../../core/errors/app-error';

export class UserApplicationService {
  async getUserProfile(userId: string) {
    const user = await UserModel.findById(userId).select('-passwordHash');
    if (!user) {
      throw new NotFoundError('User not found');
    }
    return user;
  }

  async updateProfile(userId: string, data: any) {
    const user = await UserModel.findByIdAndUpdate(
      userId,
      { $set: data },
      { new: true, runValidators: true }
    ).select('-passwordHash');

    if (!user) {
      throw new NotFoundError('User not found');
    }
    return user;
  }
}

export const userApplicationService = new UserApplicationService();
