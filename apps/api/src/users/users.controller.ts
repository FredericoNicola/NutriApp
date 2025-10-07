import { Controller, Get } from '@nestjs/common'
import { UsersService } from './users.service'

@Controller()
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Get('health')
  health() {
    return { status: 'ok' }
  }

  @Get('users')
  async getUsers() {
    return this.usersService.list()
  }
}
