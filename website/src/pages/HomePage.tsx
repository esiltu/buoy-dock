import { SiteFooter } from '../app/SiteFooter'
import { SiteHeader } from '../app/SiteHeader'
import { FinalCta } from '../features/cta/FinalCta'
import { Faq } from '../features/faq/Faq'
import { FeatureGrid } from '../features/features/FeatureGrid'
import { WhyFree } from '../features/free/WhyFree'
import { Hero } from '../features/hero/Hero'
import { InstallSteps } from '../features/install/InstallSteps'
import { Showcase } from '../features/showcase/Showcase'

export function HomePage() {
  return (
    <>
      <a href="#main" className="sr-only focus:not-sr-only focus:fixed focus:top-3 focus:left-3 focus:z-[60] focus:rounded-xl focus:bg-sea focus:px-4 focus:py-2">
        Skip to content
      </a>
      <SiteHeader />
      <main id="main">
        <div id="top" />
        <Hero />
        <FeatureGrid />
        <Showcase />
        <InstallSteps />
        <WhyFree />
        <Faq />
        <FinalCta />
      </main>
      <SiteFooter />
    </>
  )
}
