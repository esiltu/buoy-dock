import { AnimatePresence, motion } from 'motion/react'
import { Plus } from 'lucide-react'
import { useId, useState } from 'react'
import { Reveal } from '../../components/ui/Reveal'
import { Section } from '../../components/ui/Section'
import { faqs } from './faqs'

function FaqItem({ question, answer }: { question: string; answer: string }) {
  const [open, setOpen] = useState(false)
  const panelId = useId()

  return (
    <div className="border-b border-line">
      <button
        type="button"
        aria-expanded={open}
        aria-controls={panelId}
        onClick={() => setOpen((value) => !value)}
        className="flex w-full items-center justify-between gap-6 py-5 text-left text-lg font-medium tracking-[-0.01em] transition-colors hover:text-ember-deep"
      >
        {question}
        <motion.span animate={{ rotate: open ? 45 : 0 }} transition={{ duration: 0.3, ease: [0.22, 1, 0.36, 1] }} className="shrink-0">
          <Plus className="size-5" aria-hidden />
        </motion.span>
      </button>
      <AnimatePresence initial={false}>
        {open && (
          <motion.div
            id={panelId}
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.35, ease: [0.22, 1, 0.36, 1] }}
            className="overflow-hidden"
          >
            <p className="max-w-2xl pb-6 leading-relaxed text-ink-soft">{answer}</p>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}

export function Faq() {
  return (
    <Section id="faq" index="05" eyebrow="FAQ" title="Questions, answered." accent="answered.">
      <Reveal className="border-t border-line lg:ml-[244px]">
        {faqs.map((faq) => (
          <FaqItem key={faq.question} {...faq} />
        ))}
      </Reveal>
    </Section>
  )
}
