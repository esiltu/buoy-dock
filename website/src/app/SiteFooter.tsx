import { GitHubMark } from '../components/ui/BrandMarks'
import { Logo } from '../components/ui/Logo'
import { site } from '../config/site'

export function SiteFooter() {
  return (
    <footer className="border-t border-line">
      <div className="mx-auto flex max-w-6xl flex-col gap-6 px-5 py-10 sm:flex-row sm:items-center sm:justify-between sm:px-8">
        <div className="flex items-center gap-4">
          <Logo size={24} />
          <span className="font-mono text-xs text-ink-soft">Free &amp; open source · MIT</span>
        </div>
        <nav aria-label="Footer" className="flex flex-wrap items-center gap-x-6 gap-y-2 font-mono text-xs text-ink-soft">
          <a href={site.releasesUrl} className="transition-colors hover:text-ink">Releases</a>
          <a href={`${site.repoUrl}/blob/main/CHANGELOG.md`} className="transition-colors hover:text-ink">Changelog</a>
          <a href={site.issuesUrl} className="transition-colors hover:text-ink">Report an issue</a>
          <a href={site.repoUrl} className="inline-flex items-center gap-1.5 transition-colors hover:text-ink">
            <GitHubMark className="size-3.5" />
            GitHub
          </a>
        </nav>
      </div>
    </footer>
  )
}
