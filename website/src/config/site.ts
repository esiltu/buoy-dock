export const site = {
  name: 'Buoy',
  tagline: 'A free floating dock for macOS',
  repoOwner: 'esiltu',
  repoName: 'buoy-dock',
  repoUrl: 'https://github.com/esiltu/buoy-dock',
  releasesUrl: 'https://github.com/esiltu/buoy-dock/releases/latest',
  issuesUrl: 'https://github.com/esiltu/buoy-dock/issues',
  siteUrl: 'https://esiltu.github.io/buoy-dock/',
  /** The Product Hunt launch, with Product Hunt's own badge tracking parameters. */
  productHuntUrl:
    'https://www.producthunt.com/products/buoy-4?embed=true&utm_source=badge-featured&utm_medium=badge&utm_campaign=badge-buoy-a6b36018-36b8-44ba-b913-24483b525dd6',
  /** Official "Featured on Product Hunt" badge; it shows the live upvote count. */
  productHuntBadge: (theme: 'light' | 'dark') =>
    `https://api.producthunt.com/widgets/embed-image/v1/featured.svg?post_id=1326312&theme=${theme}`,
  /** Shown while the latest release is loading, or if GitHub can't be reached. */
  fallbackVersion: '1.3.0',
  requirements: 'macOS 26+ · Apple silicon & Intel',
} as const
