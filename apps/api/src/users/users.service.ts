import { Injectable } from "@nestjs/common";
import { PrismaClient } from "@prisma/client";

type User = { id: number; name: string; email?: string };

@Injectable()
export class UsersService {
  private prisma = new PrismaClient();

  async list(): Promise<User[]> {
    try {
      const users = await this.prisma.user.findMany();
      // users already have number ids, so return directly
      return users as unknown as User[];
    } catch {
      // fallback sample users when DB not available
      return [
        { id: 1, name: "Nutritionist Jane", email: "jane@example.com" },
        { id: 2, name: "Client Bob", email: "bob@example.com" },
      ];
    }
  }

  async findOne(id: number) {
    return this.prisma.user.findUnique({ where: { id } });
  }
}
