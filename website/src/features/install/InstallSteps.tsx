import { Reveal } from '../../components/ui/Reveal'
import { Section } from '../../components/ui/Section'
import { DownloadButton } from '../release/DownloadButton'
import { CopyCommand } from './CopyCommand'

const steps = [
  { title: 'Download', body: 'Grab the latest zip from GitHub. It’s free and there’s nothing to sign up for.' },
  { title: 'Move to Applications', body: 'Unzip it, drag Buoy into your Applications folder and open it.' },
  { title: 'Hide the old dock', body: 'Buoy offers to tuck Apple’s Dock away. One click and you’re set.' },
]

export function InstallSteps() {
  return (
    <Section
      id="install"
      index="03"
      eyebrow="Install"
      title="Up and floating in a minute."
      accent="floating"
      subtitle="macOS 26 Tahoe or later, on Apple silicon and Intel Macs."
    >
      <ol className="grid gap-10 md:grid-cols-3 md:gap-8">
        {steps.map((step, index) => (
          <Reveal key={step.title} delay={index * 0.08}>
            <li className="border-t-2 border-ink pt-6">
              <span className="font-mono text-sm text-ember-deep">Step {String(index + 1).padStart(2, '0')}</span>
              <h3 className="mt-3 text-xl font-semibold tracking-[-0.02em]">{step.title}</h3>
              <p className="mt-2.5 leading-relaxed text-ink-soft">{step.body}</p>
            </li>
          </Reveal>
        ))}
      </ol>

      <Reveal className="mt-14 grid gap-8 rounded-2xl border border-line bg-white p-6 sm:p-8 lg:grid-cols-[1fr_auto] lg:items-end">
        <div className="min-w-0">
          <p className="font-semibold">macOS says it can’t check Buoy?</p>
          <p className="mt-2 max-w-2xl text-ink-soft">
            Buoy isn’t notarized, because that needs a paid Apple developer account. Click <strong className="text-ink">Open Anyway</strong> in
            System Settings › Privacy &amp; Security, or run this once in Terminal:
          </p>
          <CopyCommand command="xattr -dr com.apple.quarantine /Applications/Buoy.app" />
        </div>
        <DownloadButton />
      </Reveal>
    </Section>
  )
}
