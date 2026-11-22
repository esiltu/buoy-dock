import { gitHubMock } from './github.mock'
import { gitHubService } from './github.service'
import type { GitHubService } from './types'

export const github: GitHubService = import.meta.env.VITE_USE_MOCKS === 'true' ? gitHubMock : gitHubService

export type { LatestRelease, RepoStats } from './types'
