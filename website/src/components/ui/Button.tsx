import type { AnchorHTMLAttributes, ReactNode } from 'react'

type Variant = 'primary' | 'secondary' | 'dark' | 'light'
type Size = 'md' | 'lg'

interface ButtonLinkProps extends AnchorHTMLAttributes<HTMLAnchorElement> {
  variant?: Variant
  size?: Size
  children: ReactNode
}

const variants: Record<Variant, string> = {
  primary: 'bg-ember-deep text-white shadow-[0_8px_20px_-10px_rgb(194_65_12/0.8)] hover:bg-ember-dark',
  secondary: 'border border-line-strong bg-white text-ink hover:border-ink/35',
  dark: 'bg-ink text-paper hover:bg-cocoa',
  light: 'border border-white/25 text-paper hover:bg-white/10',
}

const sizes: Record<Size, string> = {
  md: 'h-10 px-4 text-sm gap-2 rounded-xl',
  lg: 'h-12 px-5 text-[15px] gap-2.5 rounded-xl',
}

export function ButtonLink({ variant = 'primary', size = 'md', className = '', children, ...props }: ButtonLinkProps) {
  return (
    <a
      className={`inline-flex items-center justify-center font-medium whitespace-nowrap transition-colors duration-200 ${variants[variant]} ${sizes[size]} ${className}`}
      {...props}
    >
      {children}
    </a>
  )
}
