import { UsersService } from './users.service'

describe('UsersService', () => {
  it('returns fallback users when DB not available', async () => {
    const svc = new UsersService()
    const users = await svc.list()
    expect(Array.isArray(users)).toBe(true)
    expect(users.length).toBeGreaterThanOrEqual(1)
    expect(users[0]).toHaveProperty('id')
  })
})
