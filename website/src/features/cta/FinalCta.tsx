import { KineticHeading } from '../../components/ui/KineticHeading'
import { Logo } from '../../components/ui/Logo'
import { ProductHuntBadge } from '../../components/ui/ProductHuntBadge'
import { Reveal } from '../../components/ui/Reveal'
import { DownloadButton } from '../release/DownloadButton'
import { StarButton } from '../release/StarButton'

export function FinalCta() {
  return (
    <section className="mx-auto max-w-6xl px-5 py-24 sm:px-8 sm:py-32">
      <div className="flex flex-col items-start gap-10 border-t border-line pt-12 lg:flex-row lg:items-end lg:justify-between">
        <div>
          <Reveal>
            <Logo size={64} showName={false} />
          </Reveal>
          <KineticHeading
            text="Give your Mac a better dock."
            accent="better"
            className="mt-8 max-w-2xl text-5xl leading-[1] font-semibold tracking-[-0.045em] text-balance sm:text-6xl"
          />
          <Reveal delay={0.2}>
            <p className="mt-5 text-xl text-ink-soft">
              It’s <strong className="font-semibold text-ink">free</strong>. It always will be.
            </p>
          </Reveal>
        </div>
        <Reveal delay={0.25} className="flex flex-col gap-4">
          <DownloadButton />
          <div className="flex flex-wrap items-center gap-3">
            <ProductHuntBadge />
            <StarButton label="Star on GitHub" />
          </div>
        </Reveal>
      </div>
    </section>
  )
}
