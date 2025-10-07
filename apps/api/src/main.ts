import { NestFactory } from '@nestjs/core'
import { AppModule } from './app.module'

async function bootstrap() {
  const app = await NestFactory.create(AppModule)
  app.setGlobalPrefix('api')
  const port = process.env.PORT ? parseInt(process.env.PORT) : 3333
  await app.listen(port)
  console.log(`API listening on http://localhost:${port}/api`)
}
bootstrap()
