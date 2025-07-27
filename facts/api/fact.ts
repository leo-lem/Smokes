import type { VercelRequest, VercelResponse } from '@vercel/node'
import facts from './_facts.json'

type Fact = {

  fact: string
  source: string
}

export default function handler(req: VercelRequest, res: VercelResponse) {
  const random: Fact = facts[Math.floor(Math.random() * facts.length)]
  res.setHeader('Access-Control-Allow-Origin', '*')
  res.status(200).json(random)
}