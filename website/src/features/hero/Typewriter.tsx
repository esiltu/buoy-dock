import { useReducedMotion } from 'motion/react'
import { useEffect, useState } from 'react'

interface TypewriterProps {
  phrases: string[]
  prefix?: string
}

const typeSpeed = 42
const eraseSpeed = 22
const holdTime = 1700

/** Types and erases phrases in monospace. With reduced motion it simply shows the first phrase. */
export function Typewriter({ phrases, prefix = '' }: TypewriterProps) {
  const reduceMotion = useReducedMotion()
  const [index, setIndex] = useState(0)
  const [length, setLength] = useState(0)
  const [erasing, setErasing] = useState(false)
  const phrase = phrases[index % phrases.length] ?? ''

  useEffect(() => {
    if (reduceMotion) return
    const done = !erasing && length === phrase.length
    const empty = erasing && length === 0
    const delay = done ? holdTime : erasing ? eraseSpeed : typeSpeed
    const timer = setTimeout(() => {
      if (done) setErasing(true)
      else if (empty) {
        setErasing(false)
        setIndex((value) => value + 1)
      } else setLength((value) => value + (erasing ? -1 : 1))
    }, delay)
    return () => clearTimeout(timer)
  }, [erasing, length, phrase, reduceMotion])

  const shown = reduceMotion ? phrases[0] : phrase.slice(0, length)

  return (
    <p className="font-mono text-sm text-ink-soft" aria-label={`${prefix}${phrases.join(', ')}`}>
      <span aria-hidden>
        <span className="text-ember-deep">{prefix}</span>
        {shown}
        <span className="ml-0.5 inline-block h-[1.1em] w-[0.55em] translate-y-[0.18em] animate-pulse bg-ember-deep/80" />
      </span>
    </p>
  )
}
