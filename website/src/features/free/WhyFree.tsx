import { Check, Share2, Star } from 'lucide-react'
import { useState } from 'react'
import { ButtonLink } from '../../components/ui/Button'
import { KineticHeading } from '../../components/ui/KineticHeading'
import { Reveal } from '../../components/ui/Reveal'
import { site } from '../../config/site'

const promises = ['No price tag', 'No subscription', 'No account', 'No ads', 'No tracking', 'MIT licensed']

export function WhyFree() {
  const [shared, setShared] = useState(false)

  async function share() {
    try {
      if (navigator.share) {
        await navigator.share({ title: 'Buoy', text: 'A free floating dock for macOS', url: site.siteUrl })
      } else {
        await navigator.clipboard.writeText(site.siteUrl)
        setShared(true)
      }
    } catch {
      // Closing the share sheet isn't an error worth showing.
    }
  }

  return (
    <section id="free" className="scroll-mt-20 bg-cocoa text-paper">
      <div className="mx-auto max-w-6xl px-5 py-24 sm:px-8 sm:py-32">
        <Reveal>
          <p className="font-mono text-xs tracking-[0.14em] text-tan uppercase">
            <span className="text-ember">04 </span>Pricing
          </p>
        </Reveal>
        <KineticHeading
          text="Why pay when it’s free?"
          accent="free?"
          className="mt-6 max-w-4xl text-5xl leading-[1] font-semibold tracking-[-0.045em] text-balance sm:text-7xl [&_.text-ember-deep]:text-ember"
        />

        <div className="mt-12 grid gap-12 lg:grid-cols-[1.1fr_0.9fr]">
          <Reveal delay={0.1}>
            <p className="max-w-xl text-lg text-pretty text-paper/75">
              Dock apps usually come with a price tag or a subscription. Buoy costs nothing, today and later. The whole source is on
              GitHub, so you can read every line, change it and build it yourself.
            </p>
            <p className="mt-8 text-lg">Like it? A star or a share helps other people find Buoy.</p>
            <div className="mt-6 flex flex-col gap-3 sm:flex-row">
              <ButtonLink href={site.repoUrl} target="_blank" rel="noreferrer" size="lg">
                <Star className="size-[18px] fill-current" aria-hidden />
                Star on GitHub
              </ButtonLink>
              <button
                type="button"
                onClick={share}
                className="inline-flex h-12 items-center justify-center gap-2.5 rounded-xl border border-white/25 px-5 text-[15px] font-medium transition-colors duration-200 hover:bg-white/10"
              >
                <Share2 className="size-[18px]" aria-hidden />
                <span aria-live="polite">{shared ? 'Link copied' : 'Share Buoy'}</span>
              </button>
            </div>
          </Reveal>

          <Reveal delay={0.2}>
            <ul className="divide-y divide-white/10 border-y border-white/10 font-mono text-sm">
              {promises.map((promise) => (
                <li key={promise} className="flex items-center justify-between py-3.5">
                  {promise}
                  <Check className="size-4 text-ember" strokeWidth={2.5} aria-hidden />
                </li>
              ))}
            </ul>
          </Reveal>
        </div>
      </div>
    </section>
  )
}
