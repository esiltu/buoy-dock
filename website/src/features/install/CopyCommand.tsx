import { Check, Copy } from 'lucide-react'
import { useEffect, useState } from 'react'

export function CopyCommand({ command }: { command: string }) {
  const [state, setState] = useState<'idle' | 'copied' | 'failed'>('idle')

  useEffect(() => {
    if (state === 'idle') return
    const timer = setTimeout(() => setState('idle'), 1800)
    return () => clearTimeout(timer)
  }, [state])

  async function copy() {
    try {
      await navigator.clipboard.writeText(command)
      setState('copied')
    } catch {
      setState('failed')
    }
  }

  return (
    <div className="mt-5 flex items-center gap-3 rounded-xl bg-ink py-2 pr-2 pl-4">
      <span aria-hidden className="font-mono text-sm text-ember">$</span>
      <code className="min-w-0 flex-1 overflow-x-auto font-mono text-[13px] whitespace-nowrap text-paper">{command}</code>
      <button
        type="button"
        onClick={copy}
        className="inline-flex h-8 shrink-0 items-center gap-1.5 rounded-lg bg-white/10 px-3 font-mono text-xs text-paper transition-colors hover:bg-white/20"
      >
        {state === 'copied' ? <Check className="size-3.5 text-ember" aria-hidden /> : <Copy className="size-3.5" aria-hidden />}
        <span aria-live="polite">{state === 'copied' ? 'Copied' : state === 'failed' ? 'Select & copy' : 'Copy'}</span>
      </button>
    </div>
  )
}
