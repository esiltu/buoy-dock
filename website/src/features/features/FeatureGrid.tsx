import { ArrowDownToLine, Layers, Maximize2, Move, Undo2, ZoomIn, type LucideIcon } from 'lucide-react'
import { Reveal } from '../../components/ui/Reveal'
import { Section } from '../../components/ui/Section'

interface Feature {
  icon: LucideIcon
  title: string
  body: string
}

const features: Feature[] = [
  { icon: Layers, title: 'Liquid Glass', body: 'A real glass bar that floats above the bottom edge and takes on the colors behind it.' },
  { icon: ZoomIn, title: 'Smooth magnification', body: 'Icons swell gently under your pointer, with the app name just above.' },
  { icon: ArrowDownToLine, title: 'Dodges your windows', body: 'When a window reaches the dock, Buoy slides away. Push the pointer down and it’s back.' },
  { icon: Maximize2, title: 'Full-screen friendly', body: 'Nothing flashes while you swipe between Spaces. In full-screen apps it waits at the edge.' },
  { icon: Move, title: 'Drag and drop', body: 'Reorder icons, drag one up to remove it, drop an app from Finder to add it.' },
  { icon: Undo2, title: 'Apple’s Dock, tucked away', body: 'One click hides the macOS Dock. One click brings it back exactly as it was.' },
]

export function FeatureGrid() {
  return (
    <Section
      id="features"
      index="01"
      eyebrow="Features"
      title="Everything a dock should do. Nothing it shouldn’t."
      accent="Nothing it shouldn’t."
      subtitle="Native Swift and SwiftUI, living quietly in your menu bar. No Electron, no account, no tracking."
    >
      <div className="grid overflow-hidden rounded-2xl border border-line bg-line sm:grid-cols-2 lg:grid-cols-3" style={{ gap: 1 }}>
        {features.map((feature, index) => (
          <Reveal key={feature.title} delay={(index % 3) * 0.06} className="bg-paper">
            <article className="group h-full p-7 transition-colors duration-300 hover:bg-white sm:p-8">
              <div className="flex items-center justify-between">
                <feature.icon className="size-6 text-ember-deep" strokeWidth={1.6} aria-hidden />
                <span className="font-mono text-xs text-ink-soft">{String(index + 1).padStart(2, '0')}</span>
              </div>
              <h3 className="mt-10 text-xl font-semibold tracking-[-0.02em]">{feature.title}</h3>
              <p className="mt-2.5 leading-relaxed text-ink-soft">{feature.body}</p>
            </article>
          </Reveal>
        ))}
      </div>
    </Section>
  )
}
