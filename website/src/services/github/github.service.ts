import { getJson } from '../../lib/api-client'
import { site } from '../../config/site'
import { releaseResponseSchema, repoResponseSchema, type GitHubService } from './types'

const apiBase = `https://api.github.com/repos/${site.repoOwner}/${site.repoName}`

export const gitHubService: GitHubService = {
  async getRepoStats(signal) {
    const repo = await getJson(apiBase, repoResponseSchema, signal)
    return { stars: repo.stargazers_count }
  },

  async getLatestRelease(signal) {
    const release = await getJson(`${apiBase}/releases/latest`, releaseResponseSchema, signal)
    const zip = release.assets.find((asset) => asset.name.endsWith('.zip'))
    return {
      version: release.tag_name.replace(/^v/, ''),
      pageUrl: release.html_url,
      downloadUrl: zip?.browser_download_url ?? null,
      sizeMB: zip ? Math.round((zip.size / 1_000_000) * 10) / 10 : null,
    }
  },
}
