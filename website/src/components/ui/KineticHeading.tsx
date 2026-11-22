import { motion } from 'motion/react'

interface KineticHeadingProps {
  text: string
  /** Words to set in italic serif and ember, e.g. "afloat." */
  accent?: string
  as?: 'h1' | 'h2'
  className?: string
  /** Animate on mount (hero) instead of when scrolled into view. */
  immediate?: boolean
  delay?: number
}

/** Each word rises out of its own masked line, one after another. */
export function KineticHeading({ text, accent, as = 'h2', className = '', immediate = false, delay = 0 }: KineticHeadingProps) {
  const Tag = as === 'h1' ? motion.h1 : motion.h2
  const accentWords = new Set(accent?.split(' ') ?? [])
  const words = text.split(' ')
  const trigger = immediate ? { animate: 'shown' } : { whileInView: 'shown', viewport: { once: true, margin: '-60px' } }

  return (
    <Tag initial="hidden" {...trigger} transition={{ staggerChildren: 0.06, delayChildren: delay }} className={className} aria-label={text}>
      {words.map((word, index) => (
        <span key={`${word}-${index}`} aria-hidden className="inline-flex overflow-hidden pb-[0.12em] align-top">
          <motion.span
            variants={{ hidden: { y: '105%' }, shown: { y: '0%' } }}
            transition={{ duration: 0.85, ease: [0.22, 1, 0.36, 1] }}
            className={accentWords.has(word) ? 'pr-[0.06em] font-serif font-normal tracking-normal text-ember-deep italic' : undefined}
          >
            {word}
          </motion.span>
          {index < words.length - 1 && <span>&nbsp;</span>}
        </span>
      ))}
    </Tag>
  )
}
