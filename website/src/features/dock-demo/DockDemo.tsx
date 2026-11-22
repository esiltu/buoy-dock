import { useMotionValue } from 'motion/react'
import { Trash2 } from 'lucide-react'
import { useMediaQuery } from '../../lib/useMediaQuery'
import { demoApps } from './apps'
import { DockTile } from './DockTile'

/** A working miniature of Buoy: move the pointer over it to feel the magnification. */
export function DockDemo() {
  const pointerX = useMotionValue(Number.POSITIVE_INFINITY)
  const wide = useMediaQuery('(min-width: 640px)')
  const base = wide ? 46 : 34
  const max = wide ? 76 : 50

  return (
    <div
      role="toolbar"
      aria-label="Buoy dock demo"
      onPointerMove={(event) => pointerX.set(event.clientX)}
      onPointerLeave={() => pointerX.set(Number.POSITIVE_INFINITY)}
      className="flex items-end gap-2 rounded-[24px] border border-white/70 bg-white/45 px-3 pt-2.5 pb-3 shadow-[0_24px_50px_-20px_rgb(90_50_20/0.45),inset_0_1px_0_rgb(255_255_255/0.8)] backdrop-blur-xl sm:gap-2.5"
      style={{ height: base + 22 }}
    >
      {demoApps.map((app) => (
        <DockTile key={app.name} app={app} pointerX={pointerX} base={base} max={max} />
      ))}
      <span aria-hidden className="mx-0.5 mb-2 h-8 w-px shrink-0 self-end bg-ink/15" />
      <DockTile
        app={{ name: 'Trash', icon: Trash2, from: 'rgb(255 255 255 / 0.85)', to: 'rgb(240 230 218 / 0.85)', darkGlyph: true }}
        pointerX={pointerX}
        base={base}
        max={max}
      />
    </div>
  )
}
