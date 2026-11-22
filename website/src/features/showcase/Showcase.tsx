import { Check } from 'lucide-react'
import { Reveal } from '../../components/ui/Reveal'
import { Section } from '../../components/ui/Section'

const points = [
  'Icon size, magnification and how high the dock floats',
  'Dodge windows, auto-hide or always visible',
  'Show open apps and the Trash, open at login',
  'Hide or restore Apple’s Dock in one click',
]

export function Showcase() {
  return (
    <Section
      index="02"
      eyebrow="Settings"
      title="Make it yours in a few seconds."
      accent="yours"
      subtitle="Everything lives in one calm window, opened from the menu bar. Change something and the dock follows instantly."
    >
      <div className="grid items-center gap-12 lg:grid-cols-[0.9fr_1.1fr]">
        <Reveal>
          <ul className="divide-y divide-line border-y border-line">
            {points.map((point, index) => (
              <li key={point} className="flex items-start gap-4 py-4">
                <span className="mt-0.5 font-mono text-xs text-ink-soft">{String(index + 1).padStart(2, '0')}</span>
                <span className="flex-1">{point}</span>
                <Check className="mt-0.5 size-4 text-ember-deep" strokeWidth={2.5} aria-hidden />
              </li>
            ))}
          </ul>
        </Reveal>

        <Reveal delay={0.1} className="rounded-[22px] bg-sand p-6 sm:p-10">
          <img
            src={`${import.meta.env.BASE_URL}settings-window.png`}
            alt="Buoy settings window: macOS Dock, appearance, behavior, apps and about"
            width={500}
            height={955}
            loading="lazy"
            className="mx-auto w-full max-w-md rounded-xl shadow-[0_30px_60px_-30px_rgb(60_35_15/0.55)]"
          />
        </Reveal>
      </div>
    </Section>
  )
}
