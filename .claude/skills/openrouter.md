---
name: openrouter
description: "OpenRouter LLM API patterns: setup, streaming, model selection, error handling, cost optimization"
---

# OpenRouter Patterns

> Patterns for working with OpenRouter LLM API.

---

## Setup

### Configuration
```typescript
// lib/openrouter.ts
const OPENROUTER_BASE_URL = 'https://openrouter.ai/api/v1'

const headers = {
  'Authorization': `Bearer ${process.env.OPENROUTER_API_KEY}`,
  'HTTP-Referer': 'https://your-app.com',  // Required
  'X-Title': 'Your App Name',               // Optional
  'Content-Type': 'application/json',
}
```

### Environment
```bash
# .env
OPENROUTER_API_KEY=sk-or-v1-xxxxx
```

---

## Basic Request

### Chat Completion
```typescript
const response = await fetch(`${OPENROUTER_BASE_URL}/chat/completions`, {
  method: 'POST',
  headers,
  body: JSON.stringify({
    model: 'anthropic/claude-3.5-sonnet',
    messages: [
      { role: 'system', content: 'You are a helpful assistant.' },
      { role: 'user', content: 'Hello!' }
    ],
  }),
})

const data = await response.json()
const reply = data.choices[0].message.content
```

### With Parameters
```typescript
const response = await fetch(`${OPENROUTER_BASE_URL}/chat/completions`, {
  method: 'POST',
  headers,
  body: JSON.stringify({
    model: 'anthropic/claude-3.5-sonnet',
    messages,
    temperature: 0.7,
    max_tokens: 1000,
    top_p: 1,
    frequency_penalty: 0,
    presence_penalty: 0,
  }),
})
```

---

## Streaming

```typescript
async function streamChat(messages: Message[]) {
  const response = await fetch(`${OPENROUTER_BASE_URL}/chat/completions`, {
    method: 'POST',
    headers,
    body: JSON.stringify({
      model: 'anthropic/claude-3.5-sonnet',
      messages,
      stream: true,
    }),
  })

  const reader = response.body!.getReader()
  const decoder = new TextDecoder()

  while (true) {
    const { done, value } = await reader.read()
    if (done) break

    const chunk = decoder.decode(value)
    const lines = chunk.split('\n').filter(line => line.startsWith('data: '))

    for (const line of lines) {
      const data = line.slice(6) // Remove 'data: '
      if (data === '[DONE]') continue

      const parsed = JSON.parse(data)
      const content = parsed.choices[0]?.delta?.content
      if (content) {
        process.stdout.write(content) // Or update UI
      }
    }
  }
}
```

---

## Model Selection

### Recommended Models
```typescript
const MODELS = {
  // Fast & cheap
  fast: 'anthropic/claude-3-haiku',

  // Balanced
  balanced: 'anthropic/claude-3.5-sonnet',

  // Most capable
  powerful: 'anthropic/claude-3-opus',

  // Alternatives
  gpt4: 'openai/gpt-4-turbo',
  gemini: 'google/gemini-pro',
} as const
```

### Dynamic Selection
```typescript
function selectModel(task: 'simple' | 'complex' | 'creative') {
  switch (task) {
    case 'simple':
      return 'anthropic/claude-3-haiku'
    case 'complex':
      return 'anthropic/claude-3-opus'
    case 'creative':
      return 'anthropic/claude-3.5-sonnet'
  }
}
```

---

## Error Handling

```typescript
async function chatWithRetry(
  messages: Message[],
  retries = 3
): Promise<string> {
  for (let attempt = 0; attempt < retries; attempt++) {
    try {
      const response = await fetch(`${OPENROUTER_BASE_URL}/chat/completions`, {
        method: 'POST',
        headers,
        body: JSON.stringify({
          model: 'anthropic/claude-3.5-sonnet',
          messages,
        }),
      })

      if (!response.ok) {
        const error = await response.json()

        // Rate limit - wait and retry
        if (response.status === 429) {
          const retryAfter = parseInt(response.headers.get('retry-after') || '5')
          await sleep(retryAfter * 1000)
          continue
        }

        throw new Error(error.error?.message || 'API error')
      }

      const data = await response.json()
      return data.choices[0].message.content

    } catch (error) {
      if (attempt === retries - 1) throw error
      await sleep(1000 * (attempt + 1)) // Exponential backoff
    }
  }

  throw new Error('Max retries exceeded')
}

function sleep(ms: number) {
  return new Promise(resolve => setTimeout(resolve, ms))
}
```

---

## Cost Optimization

### Track Usage
```typescript
interface Usage {
  prompt_tokens: number
  completion_tokens: number
  total_tokens: number
}

async function chatWithUsage(messages: Message[]) {
  const response = await fetch(/* ... */)
  const data = await response.json()

  const usage: Usage = data.usage
  console.log(`Tokens: ${usage.total_tokens} (${usage.prompt_tokens} + ${usage.completion_tokens})`)

  return data.choices[0].message.content
}
```

### Reduce Tokens
```typescript
// 1. Use system message efficiently
const systemMessage = `You are a helpful assistant. Be concise.`

// 2. Limit context
const recentMessages = messages.slice(-10)

// 3. Set max_tokens
body: JSON.stringify({
  model: 'anthropic/claude-3.5-sonnet',
  messages,
  max_tokens: 500, // Limit response length
})
```

---

## TypeScript Types

```typescript
interface Message {
  role: 'system' | 'user' | 'assistant'
  content: string
}

interface ChatResponse {
  id: string
  choices: {
    index: number
    message: Message
    finish_reason: string
  }[]
  usage: {
    prompt_tokens: number
    completion_tokens: number
    total_tokens: number
  }
}
```
