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
  jitterScale: number,
  weaveNoiseSpeed: number,
  weaveNoiseScale: number,
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