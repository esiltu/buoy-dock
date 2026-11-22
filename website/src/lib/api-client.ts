import type * as z from 'zod'

export class ApiError extends Error {
  readonly status?: number

  constructor(message: string, status?: number) {
    super(message)
    this.name = 'ApiError'
    this.status = status
  }
}

/** Fetches JSON and validates it, so the UI only ever sees well-formed data. */
export async function getJson<T>(url: string, schema: z.ZodType<T>, signal?: AbortSignal): Promise<T> {
  const response = await fetch(url, {
    headers: { Accept: 'application/vnd.github+json' },
    signal,
  })
  if (!response.ok) {
    throw new ApiError(`Request to ${url} failed with ${response.status}`, response.status)
  }
  const result = schema.safeParse(await response.json())
  if (!result.success) {
    throw new ApiError(`Unexpected response from ${url}`)
  }
  return result.data
}
