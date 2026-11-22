import { Link } from 'react-router'
import { Logo } from '../components/ui/Logo'

export function NotFoundPage() {
  return (
    <main className="flex min-h-svh flex-col items-center justify-center gap-6 px-6 text-center">
      <Logo size={64} showName={false} />
      <p className="label-mono">Error 404</p>
      <h1 className="text-4xl font-semibold tracking-[-0.035em]">
        This page <span className="font-serif font-normal text-ember-deep italic">drifted</span> away.
      </h1>
      <Link to="/" className="rounded-xl border border-line-strong bg-white px-5 py-3 font-medium transition-colors hover:border-ink/35">
        Back to Buoy
      </Link>
    </main>
  )
}
