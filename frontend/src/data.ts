export interface Config {
  grainStrength: number,
  dustStrength: number,
  vignetteStrength: number,
  halationStrength: number,
  halationThreshold: number,
  halationSigmaX: number,
  halationGaussianSize: BlurSize,
  colorCast: Color,
  warmColorCast: Color,
  coldColorCast: Color,
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