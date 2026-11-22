import { site } from '../../config/site'
import { ProductHuntMark } from './BrandMarks'

export function ProductHuntBadge({ tone = 'light', className = '' }: { tone?: 'light' | 'dark'; className?: string }) {
  const colors =
    tone === 'light'
      ? 'border-line-strong bg-white text-ink hover:border-ink/35'
      : 'border-white/20 bg-white/5 text-paper hover:bg-white/10'

  return (
    <a
      href={site.productHuntUrl}
      target="_blank"
      rel="noreferrer"
      className={`inline-flex h-12 items-center gap-3 rounded-xl border pr-4 pl-2 transition-colors duration-200 ${colors} ${className}`}
    >
      <ProductHuntMark className="size-8" />
      <span className="flex flex-col text-left leading-none">
        <span className={`font-mono text-[10px] tracking-[0.14em] uppercase ${tone === 'light' ? 'text-ink-soft' : 'text-paper/70'}`}>
          Find us on
        </span>
        <span className="mt-1 text-[15px] font-semibold tracking-tight">Product Hunt</span>
      </span>
    </a>
  )
}
