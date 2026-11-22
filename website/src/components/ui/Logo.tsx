interface LogoProps {
  size?: number
  showName?: boolean
}

export function Logo({ size = 32, showName = true }: LogoProps) {
  return (
    <span className="inline-flex items-center gap-2.5">
      <img src={`${import.meta.env.BASE_URL}icon.png`} alt={showName ? '' : 'Buoy'} width={size} height={size} />
      {showName && <span className="text-[17px] font-semibold tracking-[-0.02em]">Buoy</span>}
    </span>
  )
}
