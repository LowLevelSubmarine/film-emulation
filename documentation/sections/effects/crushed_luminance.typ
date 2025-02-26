#import "../../components.typ": authored_by

== Crushed Luminance
#authored_by("Florian Weichert")

=== Theorie 
@how-to-edit-like-film

=== Implementierung

```kotlin
fun ProcessingDsl.crushedLuminance(
  inputImage: Mat, 
  destinationImage: Mat, 
  config: Config
) {
    val contrastLut by stored { 
      createSplineLUT(Knot(0.2f, 0.0f), Knot(0.8f, 1.0f)) 
    }
    Core.LUT(inputImage, contrastLut, destinationImage)
    val lut by stored(listOf(config.crushedLuminanceStrength)) {
        createSplineLUT(
            Knot(0.0f, config.crushedLuminanceStrength * 0.2f),
            Knot(0.2f, 0.2f),
            Knot(0.8f, 0.8f),
            Knot(1.0f, 1.0f - config.crushedLuminanceStrength * 0.2f)
        )
    }
    Core.LUT(destinationImage, lut, destinationImage)
}
```