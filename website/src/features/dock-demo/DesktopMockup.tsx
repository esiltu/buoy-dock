import { MousePointer2 } from 'lucide-react'
import { DockDemo } from './DockDemo'

/** A warm, calm desktop with the interactive dock floating at the bottom. Gradients only: no blur filters. */
export function DesktopMockup() {
  return (
    <figure id="demo" className="mx-auto w-full max-w-6xl scroll-mt-24">
      <div className="relative h-[380px] overflow-hidden rounded-[22px] sm:h-auto sm:aspect-[16/9] border border-line-strong shadow-[0_40px_80px_-40px_rgb(60_35_15/0.5)]">
        <div
          className="absolute inset-0"
          style={{
            background:
              'radial-gradient(60% 70% at 78% 18%, rgb(255 236 214 / 0.9), transparent 70%), radial-gradient(70% 80% at 12% 100%, rgb(168 98 52 / 0.55), transparent 70%), linear-gradient(160deg, #f6e4cf 0%, #efc29a 48%, #d98a52 100%)',
          }}
        />

        <div className="absolute inset-x-0 top-0 flex h-7 items-center justify-between bg-white/35 px-4 font-mono text-[11px] text-ink/70">
          <span>File&nbsp;&nbsp;&nbsp;Edit&nbsp;&nbsp;&nbsp;View&nbsp;&nbsp;&nbsp;Window</span>
          <span>Sun 9:41</span>
        </div>

        <div className="absolute top-[16%] left-[7%] hidden w-[42%] rounded-xl border border-white/70 bg-white/55 p-4 shadow-[0_20px_40px_-24px_rgb(60_35_15/0.5)] sm:block">
          <div className="mb-3 flex gap-1.5">
            <span className="size-2.5 rounded-full bg-ink/15" />
            <span className="size-2.5 rounded-full bg-ink/15" />
            <span className="size-2.5 rounded-full bg-ink/15" />
          </div>
          <div className="space-y-2">
            <div className="h-2 w-3/4 rounded bg-ink/15" />
            <div className="h-2 w-1/2 rounded bg-ink/10" />
            <div className="h-2 w-2/3 rounded bg-ink/10" />
          </div>
        </div>

        <div className="absolute top-12 right-5 flex items-center gap-2 rounded-md bg-ink px-2.5 py-1.5 font-mono text-[11px] text-paper">
          <MousePointer2 className="size-3.5" aria-hidden />
          Try it: hover the dock
        </div>

        <div className="absolute inset-x-0 bottom-5 flex justify-center px-3 sm:bottom-7">
          <DockDemo />
        </div>
      </div>
      <figcaption className="mt-4 text-center font-mono text-xs text-ink-soft">Fig. 1 · The real magnification curve, running in your browser.</figcaption>
    </figure>
  )
}
