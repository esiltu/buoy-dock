import {
  CalendarDays,
  Compass,
  Folder,
  Image,
  Mail,
  MessageCircle,
  Music2,
  NotebookPen,
  Settings,
  SquareTerminal,
  type LucideIcon,
} from 'lucide-react'

export interface DemoApp {
  name: string
  icon: LucideIcon
  /** Gradient stops for the tile, in the site's warm palette. */
  from: string
  to: string
  /** Dark glyph on a light tile. */
  darkGlyph?: boolean
  running?: boolean
  /** Hidden on narrow screens to keep the dock on one line. */
  wideOnly?: boolean
}

export const demoApps: DemoApp[] = [
  { name: 'Files', icon: Folder, from: '#f59a5c', to: '#d4501a', running: true },
  { name: 'Browser', icon: Compass, from: '#3a3029', to: '#16120f', running: true },
  { name: 'Mail', icon: Mail, from: '#f3e6d6', to: '#d9c3a5', darkGlyph: true },
  { name: 'Messages', icon: MessageCircle, from: '#c08f69', to: '#8a5a3b', running: true },
  { name: 'Photos', icon: Image, from: '#ffc38f', to: '#ef7b35', wideOnly: true },
  { name: 'Music', icon: Music2, from: '#4a3b31', to: '#231b16', wideOnly: true },
  { name: 'Calendar', icon: CalendarDays, from: '#ffffff', to: '#efe6da', darkGlyph: true, wideOnly: true },
  { name: 'Notes', icon: NotebookPen, from: '#f8dfb3', to: '#e8b96a', darkGlyph: true, wideOnly: true },
  { name: 'Terminal', icon: SquareTerminal, from: '#5e4d40', to: '#2e241d', running: true, wideOnly: true },
  { name: 'Settings', icon: Settings, from: '#e2d6c7', to: '#b8a48d', darkGlyph: true },
]
