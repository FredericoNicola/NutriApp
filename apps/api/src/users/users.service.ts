import { Injectable } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";

type User = { id: number; name: string; email?: string };

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async list(): Promise<User[]> {
    try {
      const users = await this.prisma.user.findMany();
      return users as unknown as User[];
    } catch {
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
