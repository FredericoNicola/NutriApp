import { Test, TestingModule } from "@nestjs/testing";
import { UnauthorizedException } from "@nestjs/common";
import { JwtService } from "@nestjs/jwt";
import { mockDeep, DeepMockProxy } from "jest-mock-extended";
import { PrismaClient } from "@prisma/client";
import * as bcrypt from "bcrypt";
import { AuthService } from "./auth.service";
import { PrismaService } from "../prisma/prisma.service"; // ADD this import

// Mock bcrypt
jest.mock("bcrypt");

describe("AuthService", () => {
  let service: AuthService;
  let prismaMock: DeepMockProxy<PrismaClient>;
  let jwtMock: jest.Mocked<JwtService>;

  beforeEach(async () => {
    prismaMock = mockDeep<PrismaClient>();
    jwtMock = { sign: jest.fn() } as jest.Mocked<JwtService>;

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        // Provide the Prisma mock directly so `this.prisma.user.*` is available
        { provide: PrismaService, useValue: prismaMock },
        { provide: JwtService, useValue: jwtMock },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe("register", () => {
    it("should hash password, create user, and return user without password", async () => {
      const hashedPassword = "hashedPassword";
      (bcrypt.hash as jest.Mock).mockResolvedValue(hashedPassword);

      const createdUser = {
        id: 1,
        email: "test@example.com",
        name: "Test User",
        professionalCard: "12345",
        createdAt: new Date(),
      };
      prismaMock.user.create.mockResolvedValue(createdUser as any);

      const result = await service.register(
        "test@example.com",
        "password123",
        "Test User",
        "12345"
      );

      expect(bcrypt.hash).toHaveBeenCalledWith("password123", 10);
      expect(prismaMock.user.create).toHaveBeenCalledWith({
        data: {
          email: "test@example.com",
          password: hashedPassword,
          name: "Test User",
          professionalCard: "12345",
        },
      });
      expect(result).toEqual({
        id: 1,
        email: "test@example.com",
        name: "Test User",
        professionalCard: "12345",
        createdAt: expect.any(Date),
      });
    });
  });

  describe("login", () => {
    it("should return access token and user on valid credentials", async () => {
      const user = {
        id: 1,
        email: "test@example.com",
        password: "hashedPassword",
        name: "Test User",
      };
      prismaMock.user.findUnique.mockResolvedValue(user as any);
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);
      jwtMock.sign.mockReturnValue("jwtToken");

      const result = await service.login("test@example.com", "password123");

      expect(prismaMock.user.findUnique).toHaveBeenCalledWith({
        where: { email: "test@example.com" },
      });
      expect(bcrypt.compare).toHaveBeenCalledWith(
        "password123",
        "hashedPassword"
      );
      expect(jwtMock.sign).toHaveBeenCalledWith({
        sub: 1,
        email: "test@example.com",
      });
      expect(result).toEqual({
        access_token: "jwtToken",
        user: { id: 1, email: "test@example.com", name: "Test User" },
      });
    });

    it("should throw UnauthorizedException on invalid email", async () => {
      prismaMock.user.findUnique.mockResolvedValue(null);

      await expect(
        service.login("invalid@example.com", "password123")
      ).rejects.toThrow(UnauthorizedException);
      expect(bcrypt.compare).not.toHaveBeenCalled();
    });

    it("should throw UnauthorizedException on invalid password", async () => {
      const user = {
        id: 1,
        email: "test@example.com",
        password: "hashedPassword",
        name: "Test User",
      };
      prismaMock.user.findUnique.mockResolvedValue(user as any);
      (bcrypt.compare as jest.Mock).mockResolvedValue(false);

      await expect(
        service.login("test@example.com", "wrongpassword")
      ).rejects.toThrow(UnauthorizedException);
      expect(bcrypt.compare).toHaveBeenCalledWith(
        "wrongpassword",
        "hashedPassword"
      );
    });
  });
});
