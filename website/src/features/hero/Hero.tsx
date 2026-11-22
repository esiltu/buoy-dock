import { motion } from 'motion/react'
import { ButtonLink } from '../../components/ui/Button'
import { GitHubMark } from '../../components/ui/BrandMarks'
import { KineticHeading } from '../../components/ui/KineticHeading'
import { ProductHuntBadge } from '../../components/ui/ProductHuntBadge'
import { Reveal } from '../../components/ui/Reveal'
import { site } from '../../config/site'
import { DesktopMockup } from '../dock-demo/DesktopMockup'
import { DownloadButton } from '../release/DownloadButton'
import { Typewriter } from './Typewriter'
import { SpecSheet } from './SpecSheet'

const phrases = ['floats above your desktop.', 'magnifies under your pointer.', 'dodges your windows.', 'works in full screen.', 'costs nothing. Ever.']

const fadeUp = (delay: number) => ({
  initial: { opacity: 0, y: 14 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.8, delay, ease: [0.22, 1, 0.36, 1] as const },
})

export function Hero() {
  return (
    <section className="relative isolate overflow-hidden pt-28 pb-16 sm:pt-36 sm:pb-24">
      <div aria-hidden className="blueprint absolute inset-0 -z-10 opacity-60 [mask-image:radial-gradient(ellipse_at_50%_0%,black_10%,transparent_65%)]" />

      <div className="mx-auto grid max-w-6xl items-center gap-12 px-5 sm:px-8 lg:grid-cols-[1.15fr_0.85fr] lg:gap-16">
        <div>
          <motion.p {...fadeUp(0)} className="label-mono inline-flex items-center gap-2.5">
            <span className="size-2 rounded-full bg-ember" />
            Free dock for macOS · Open source
          </motion.p>

          <KineticHeading
            as="h1"
            immediate
            delay={0.1}
            text="Your dock, set afloat."
            accent="afloat."
            className="mt-6 text-[clamp(3rem,8vw,5.75rem)] leading-[0.98] font-semibold tracking-[-0.045em]"
          />

          <motion.p {...fadeUp(0.45)} className="mt-7 max-w-xl text-lg text-pretty text-ink-soft sm:text-xl">
            Buoy is a <strong className="font-semibold text-ink">free</strong>, open-source dock for macOS. Clean Liquid Glass,
            smooth magnification, and it stays out of your way.
          </motion.p>

          <motion.div {...fadeUp(0.55)} className="mt-6">
            <Typewriter prefix="buoy › " phrases={phrases} />
          </motion.div>

          <motion.div {...fadeUp(0.65)} className="mt-9 flex flex-col gap-4 sm:flex-row sm:items-start">
            <DownloadButton />
            <ButtonLink href={site.repoUrl} target="_blank" rel="noreferrer" variant="secondary" size="lg">
              <GitHubMark className="size-[18px]" />
              View on GitHub
            </ButtonLink>
          </motion.div>

          <motion.div {...fadeUp(0.75)} className="mt-6">
            <ProductHuntBadge />
          </motion.div>
        </div>

        <SpecSheet />
      </div>

      <Reveal className="mt-20 px-5 sm:mt-24 sm:px-8">
        <DesktopMockup />
      </Reveal>
    </section>
  )
}
