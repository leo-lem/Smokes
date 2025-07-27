import { readFile } from 'fs/promises'

type Fact = {
  fact: string
  source: string
}

export async function GET(): Promise<Response> {
  const filePath = new URL('./facts.json', import.meta.url).pathname
  const data = await readFile(filePath, 'utf-8')
  const facts: Fact[] = JSON.parse(data)

  const random = facts[Math.floor(Math.random() * facts.length)]
  return Response.json(random)
}