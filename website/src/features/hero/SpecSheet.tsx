import { motion } from 'motion/react'
import { site } from '../../config/site'
import { useLatestRelease } from '../release/queries'

/** The facts, set like a spec sheet. Version and size come live from GitHub. */
export function SpecSheet() {
  const { data, isPending } = useLatestRelease()
  const rows: [string, string][] = [
    ['License', 'MIT, open source'],
    ['Version', isPending ? '…' : (data?.version ?? site.fallbackVersion)],
    ['Download', isPending ? '…' : data?.sizeMB ? `${data.sizeMB} MB zip` : 'GitHub Releases'],
    ['Requires', 'macOS 26 Tahoe+'],
    ['Runs on', 'Apple silicon · Intel'],
    ['Account', 'None'],
    ['Tracking', 'None'],
  ]

  return (
    <motion.aside
      initial={{ opacity: 0, y: 24 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.9, delay: 0.35, ease: [0.22, 1, 0.36, 1] }}
      aria-label="Buoy at a glance"
      className="card relative overflow-hidden p-7 sm:p-8"
    >
      <div className="flex items-center justify-between">
        <span className="label-mono">Spec sheet</span>
        <span className="font-mono text-xs text-ink-soft">BUOY/{data?.version ?? site.fallbackVersion}</span>
      </div>

      <div className="mt-6 flex items-end gap-3 border-b border-dashed border-line-strong pb-6">
        <span className="text-7xl leading-none font-semibold tracking-[-0.05em] tabular-nums sm:text-8xl">$0</span>
        <span className="mb-2 font-serif text-2xl text-ember-deep italic">forever</span>
      </div>

      <motion.dl
        initial="hidden"
        animate="shown"
        transition={{ staggerChildren: 0.06, delayChildren: 0.6 }}
        className="mt-5 space-y-3 font-mono text-[13px]"
      >
        {rows.map(([term, value]) => (
          <motion.div
            key={term}
            variants={{ hidden: { opacity: 0, x: -8 }, shown: { opacity: 1, x: 0 } }}
            transition={{ duration: 0.5, ease: [0.22, 1, 0.36, 1] }}
            className="flex items-baseline gap-2"
          >
            <dt className="text-ink-soft">{term}</dt>
            <span aria-hidden className="mb-1 flex-1 border-b border-dotted border-line-strong" />
            <dd className="text-right text-ink">{value}</dd>
          </motion.div>
        ))}
      </motion.dl>

      <p className="mt-6 border-t border-line pt-4 font-mono text-[11px] tracking-wide text-ink-soft uppercase">
        Native Swift · SwiftUI · No Electron
      </p>
    </motion.aside>
  )
}
