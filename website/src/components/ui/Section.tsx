import type { ReactNode } from 'react'
import { KineticHeading } from './KineticHeading'
import { Reveal } from './Reveal'

interface SectionProps {
  id?: string
  index?: string
  eyebrow?: string
  title: string
  /** Words from the title to set in the serif accent. */
  accent?: string
  subtitle?: ReactNode
  children?: ReactNode
  className?: string
}

export function Section({ id, index, eyebrow, title, accent, subtitle, children, className = '' }: SectionProps) {
  return (
    <section id={id} className={`relative mx-auto w-full max-w-6xl scroll-mt-20 px-5 py-24 sm:px-8 sm:py-28 ${className}`}>
      <div className="grid gap-6 border-t border-line pt-8 lg:grid-cols-[220px_1fr]">
        {eyebrow && (
          <Reveal>
            <p className="label-mono">
              {index && <span className="text-ember-deep">{index} </span>}
              {eyebrow}
            </p>
          </Reveal>
        )}
        <div className="max-w-3xl">
          <KineticHeading as="h2" text={title} accent={accent} className="text-4xl font-semibold tracking-[-0.035em] text-balance sm:text-5xl" />
          {subtitle && (
            <Reveal delay={0.15}>
              <p className="mt-5 max-w-2xl text-lg text-pretty text-ink-soft">{subtitle}</p>
            </Reveal>
          )}
        </div>
      </div>
      {children && <div className="mt-14">{children}</div>}
    </section>
  )
}
