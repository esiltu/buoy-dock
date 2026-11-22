import { motion, useMotionValueEvent, useScroll } from 'motion/react'
import { useState } from 'react'
import { Logo } from '../components/ui/Logo'
import { DownloadButton } from '../features/release/DownloadButton'
import { StarButton } from '../features/release/StarButton'

const links = [
  { href: '#features', label: 'Features' },
  { href: '#install', label: 'Install' },
  { href: '#free', label: 'Pricing' },
  { href: '#faq', label: 'FAQ' },
]

export function SiteHeader() {
  const { scrollY } = useScroll()
  const [scrolled, setScrolled] = useState(false)
  useMotionValueEvent(scrollY, 'change', (y) => setScrolled(y > 16))

  return (
    <motion.header
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.6 }}
      className={`fixed inset-x-0 top-0 z-50 border-b transition-colors duration-300 ${
        scrolled ? 'border-line bg-paper/92' : 'border-transparent bg-transparent'
      }`}
    >
      <nav aria-label="Main" className="mx-auto flex h-16 max-w-6xl items-center justify-between px-5 sm:px-8">
        <a href="#top" aria-label="Buoy home">
          <Logo size={28} />
        </a>
        <ul className="hidden items-center gap-7 md:flex">
          {links.map((link) => (
            <li key={link.href}>
              <a href={link.href} className="text-sm text-ink-soft transition-colors hover:text-ink">
                {link.label}
              </a>
            </li>
          ))}
        </ul>
        <div className="flex items-center gap-2">
          <span className="hidden sm:inline-flex">
            <StarButton />
          </span>
          <DownloadButton size="md" showMeta={false} />
        </div>
      </nav>
    </motion.header>
  )
}
