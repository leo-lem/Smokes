import { readFile } from 'fs/promises'

type Fact = {
  fact: string
  source: string
}

export async function GET(): Promise<Response> {
  const data = await readFile(new URL('./facts.json', import.meta.url).pathname, 'utf-8')
  const facts: Fact[] = JSON.parse(data)
  const random = facts[Math.floor(Math.random() * facts.length)]

  console.log('Random fact requested: ', random)

  const headers = new Headers()
  headers.set('Access-Control-Allow-Origin', '*')
  headers.set('Content-Type', 'application/json')

  return new Response(JSON.stringify(random), { headers })
}