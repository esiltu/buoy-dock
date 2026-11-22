export const site = {
  name: 'Buoy',
  tagline: 'A free floating dock for macOS',
  repoOwner: 'esiltu',
  repoName: 'buoy-dock',
  repoUrl: 'https://github.com/esiltu/buoy-dock',
  releasesUrl: 'https://github.com/esiltu/buoy-dock/releases/latest',
  issuesUrl: 'https://github.com/esiltu/buoy-dock/issues',
  siteUrl: 'https://esiltu.github.io/buoy-dock/',
  /** Swap in the Product Hunt post URL once Buoy is live there. */
  productHuntUrl: 'https://www.producthunt.com/search?q=Buoy%20dock',
  /** Shown while the latest release is loading, or if GitHub can't be reached. */
  fallbackVersion: '1.1.0',
  requirements: 'macOS 26+ · Apple silicon & Intel',
} as const
