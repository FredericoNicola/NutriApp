import { Controller, Post, Body } from "@nestjs/common";
import { AuthService } from "./auth.service";

@Controller("api/auth") // CHANGED: add 'api/' prefix to match users controller
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post("register")
  async register(
    @Body()
    body: {
      email: string;
      password: string;
      name: string;
      professionalCard: string;
    }
  ) {
    return this.authService.register(
      body.email,
      body.password,
      body.name,
      body.professionalCard
    );
  }

  @Post("login")
  async login(@Body() body: { email: string; password: string }) {
    return this.authService.login(body.email, body.password);
  }
}
