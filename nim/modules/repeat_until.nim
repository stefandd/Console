template repeat*(body: untyped): void =
  while true:
    body

template until*(cond: typed): void =
  if cond: break
