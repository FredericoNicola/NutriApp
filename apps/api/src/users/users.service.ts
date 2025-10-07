import { Injectable } from '@nestjs/common'
import { PrismaClient } from '@prisma/client'

@Injectable()
export class UsersService {
  private prisma = new PrismaClient()

  async list() {
    # Try to return users from DB; fallback to sample if DB not set up
    try {
      const users = await this.prisma.user.findMany()
      if (users.length > 0) return users
    } catch (e) {
      // ignore
    }
    return [
      { id: '1', name: 'Nutritionist Jane', email: 'jane@example.com' },
      { id: '2', name: 'Client Bob', email: 'bob@example.com' }
    ]
  }
}
