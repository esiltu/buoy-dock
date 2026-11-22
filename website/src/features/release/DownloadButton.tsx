import { ArrowDown } from 'lucide-react'
import { ButtonLink } from '../../components/ui/Button'
import { AppleMark } from '../../components/ui/BrandMarks'
import { site } from '../../config/site'
import { useLatestRelease } from './queries'

interface DownloadButtonProps {
  size?: 'md' | 'lg'
  showMeta?: boolean
  tone?: 'light' | 'dark'
}

/** Links straight to the latest .zip on GitHub; falls back to the releases page while loading or offline. */
export function DownloadButton({ size = 'lg', showMeta = true, tone = 'light' }: DownloadButtonProps) {
  const { data, isPending } = useLatestRelease()
  const href = data?.downloadUrl ?? data?.pageUrl ?? site.releasesUrl
  const version = data?.version ?? site.fallbackVersion

  return (
    <div className="flex flex-col gap-2.5">
      <ButtonLink href={href} size={size} aria-label={`Download Buoy ${version} for macOS, free`}>
        {size === 'lg' ? <AppleMark className="size-[18px]" /> : <ArrowDown className="size-4" aria-hidden />}
        Download free
        {size === 'lg' && <span className="font-normal text-white/75">for macOS</span>}
      </ButtonLink>
      {showMeta && (
        <p className={`font-mono text-xs ${tone === 'light' ? 'text-ink-soft' : 'text-paper/70'}`} aria-live="polite">
          {isPending ? (
            <span className="inline-block h-3.5 w-40 animate-pulse rounded bg-current/15 align-middle" aria-label="Loading version" />
          ) : (
            <>
              v{version}
              {data?.sizeMB ? ` · ${data.sizeMB} MB` : ''} · {site.requirements}
            </>
          )}
        </p>
      )}
    </div>
  )
}
