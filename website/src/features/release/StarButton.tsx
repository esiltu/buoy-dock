import { Star } from 'lucide-react'
import { GitHubMark } from '../../components/ui/BrandMarks'
import { site } from '../../config/site'
import { useRepoStats } from './queries'

const formatter = new Intl.NumberFormat('en', { notation: 'compact' })
const minimumShownStars = 10

export function StarButton({ label = 'Star', tone = 'light' }: { label?: string; tone?: 'light' | 'dark' }) {
  const { data } = useRepoStats()
  // A tiny count looks worse than none, so it only shows once there are a few stars.
  const showCount = data !== undefined && data.stars >= minimumShownStars
  const colors = tone === 'light' ? 'border-line-strong bg-white text-ink hover:border-ink/35' : 'border-white/20 text-paper hover:bg-white/10'

  return (
    <a
      href={site.repoUrl}
      target="_blank"
      rel="noreferrer"
      className={`inline-flex h-10 items-center gap-2 rounded-xl border px-3.5 text-sm font-medium transition-colors duration-200 ${colors}`}
    >
      <GitHubMark className="size-4" />
      {label}
      <Star className="size-3.5 fill-ember text-ember" aria-hidden />
      {showCount && <span className="font-mono text-xs opacity-75">{formatter.format(data.stars)}</span>}
    </a>
  )
}
