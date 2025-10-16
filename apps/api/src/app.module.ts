import { Module } from "@nestjs/common";
import { UsersModule } from "./users/users.module";
import { AuthModule } from "./auth/auth.module"; // ensure this import is present

@Module({
  imports: [UsersModule, AuthModule], // ensure AuthModule is in imports
})
export class AppModule {}
