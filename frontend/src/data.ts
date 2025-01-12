export interface Config {
  grainStrength: number,
  dustStrength: number,
  vignetteStrength: number,
  threshold: number,
  sigmaX: number,
  gaussianSize: BlurSize,
  colorCast: Color,
  crushedLuminanceStrength: number
}

interface Color {
  red: number,
  green: number,
  blue: number,
}

interface BlurSize {
  width: number,
  height: number,
}