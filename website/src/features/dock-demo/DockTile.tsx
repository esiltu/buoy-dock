import { AnimatePresence, motion, useReducedMotion, useSpring, useTransform, type MotionValue } from 'motion/react'
import { useRef, useState } from 'react'
import type { DemoApp } from './apps'

interface DockTileProps {
  app: DemoApp
  pointerX: MotionValue<number>
  base: number
  max: number
}

/** One icon: grows smoothly with the pointer's distance (like Buoy's magnification) and hops when clicked. */
export function DockTile({ app, pointerX, base, max }: DockTileProps) {
  const ref = useRef<HTMLButtonElement>(null)
  const reduceMotion = useReducedMotion()
  const [hovered, setHovered] = useState(false)
  const [hops, setHops] = useState(0)

  const distance = useTransform(pointerX, (x) => {
    const rect = ref.current?.getBoundingClientRect()
    if (!rect || !Number.isFinite(x)) return 1_000
    return x - rect.left - rect.width / 2
  })
  const target = useTransform(distance, [-150, 0, 150], [base, max, base])
  const size = useSpring(target, { mass: 0.12, stiffness: 200, damping: 18 })
  const Icon = app.icon

  return (
    <motion.button
      ref={ref}
      type="button"
      aria-label={app.name}
      onClick={() => setHops((count) => count + 1)}
      onPointerEnter={() => setHovered(true)}
      onPointerLeave={() => setHovered(false)}
      onFocus={() => setHovered(true)}
      onBlur={() => setHovered(false)}
      style={reduceMotion ? { width: base, height: base } : { width: size, height: size }}
      className={`relative shrink-0 ${app.wideOnly ? 'max-sm:hidden' : ''}`}
    >
      <motion.span
        key={hops}
        animate={hops > 0 && !reduceMotion ? { y: [0, -20, 0, -8, 0] } : undefined}
        transition={{ duration: 0.7, ease: 'easeOut' }}
        className="grid size-full place-items-center rounded-[23%] shadow-[0_6px_14px_-6px_rgb(60_35_15/0.45),inset_0_1px_0_rgb(255_255_255/0.5)]"
        style={{ background: `linear-gradient(160deg, ${app.from}, ${app.to})` }}
      >
        <Icon className={`size-[50%] ${app.darkGlyph ? 'text-[#4a3a2e]' : 'text-white'}`} strokeWidth={1.8} aria-hidden />
      </motion.span>
      {app.running && <span className="absolute -bottom-[7px] left-1/2 size-1 -translate-x-1/2 rounded-full bg-ink/70" />}
      <AnimatePresence>
        {hovered && (
          <motion.span
            initial={{ opacity: 0, y: 4 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 2 }}
            transition={{ duration: 0.14 }}
            className="pointer-events-none absolute -top-10 left-1/2 -translate-x-1/2 rounded-md bg-ink px-2.5 py-1 font-mono text-[11px] whitespace-nowrap text-paper"
          >
            {app.name}
          </motion.span>
        )}
      </AnimatePresence>
    </motion.button>
  )
}
