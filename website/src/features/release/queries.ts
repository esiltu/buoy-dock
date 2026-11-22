import { useQuery } from '@tanstack/react-query'
import { github } from '../../services/github'

const tenMinutes = 10 * 60 * 1000

export function useLatestRelease() {
  return useQuery({
    queryKey: ['github', 'latest-release'],
    queryFn: ({ signal }) => github.getLatestRelease(signal),
    staleTime: tenMinutes,
    retry: 1,
  })
}

export function useRepoStats() {
  return useQuery({
    queryKey: ['github', 'repo-stats'],
    queryFn: ({ signal }) => github.getRepoStats(signal),
    staleTime: tenMinutes,
    retry: 1,
  })
}
