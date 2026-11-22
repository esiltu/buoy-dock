import * as z from 'zod'

export const repoResponseSchema = z.object({
  stargazers_count: z.number(),
})

export const releaseResponseSchema = z.object({
  tag_name: z.string(),
  html_url: z.string(),
  assets: z.array(
    z.object({
      name: z.string(),
      size: z.number(),
      browser_download_url: z.string(),
    }),
  ),
})

export interface RepoStats {
  stars: number
}

export interface LatestRelease {
  version: string
  pageUrl: string
  /** Direct link to the .zip, or null if the release has no zip attached. */
  downloadUrl: string | null
  sizeMB: number | null
}

/** The real service and the mock implement the same interface. */
export interface GitHubService {
  getRepoStats(signal?: AbortSignal): Promise<RepoStats>
  getLatestRelease(signal?: AbortSignal): Promise<LatestRelease>
}
