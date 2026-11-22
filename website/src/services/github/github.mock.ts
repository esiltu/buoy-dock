import { site } from '../../config/site'
import type { GitHubService } from './types'

const wait = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms))

/** Offline stand-in with the same interface; enable with VITE_USE_MOCKS=true. */
export const gitHubMock: GitHubService = {
  async getRepoStats() {
    await wait(300)
    return { stars: 128 }
  },

  async getLatestRelease() {
    await wait(300)
    return {
      version: site.fallbackVersion,
      pageUrl: site.releasesUrl,
      downloadUrl: `${site.repoUrl}/releases/download/v${site.fallbackVersion}/Buoy-${site.fallbackVersion}.zip`,
      sizeMB: 1.5,
    }
  },
}
