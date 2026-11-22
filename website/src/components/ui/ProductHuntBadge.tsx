import { site } from '../../config/site'

/** Product Hunt's official "Featured" badge, with the live upvote count. */
export function ProductHuntBadge({ tone = 'light', className = '' }: { tone?: 'light' | 'dark'; className?: string }) {
  return (
    <a
      href={site.productHuntUrl}
      target="_blank"
      rel="noopener noreferrer"
      className={`inline-flex rounded-xl transition-transform duration-200 hover:-translate-y-0.5 ${className}`}
    >
      <img
        src={site.productHuntBadge(tone)}
        alt="Buoy, a free floating dock for macOS, featured on Product Hunt"
        width={222}
        height={48}
        loading="lazy"
        decoding="async"
      />
    </a>
  )
}
