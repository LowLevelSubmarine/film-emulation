#import "../../components.typ": authored_by

== Tone
#authored_by("Florian Weichert")

=== Theorie 

=== Implementierung
```kotlin
fun ProcessingDsl.tone(image: Mat, config: Config) {
    val hsv by stored { Mat() }
    val hue by stored { Mat() }
    val sat by stored { Mat() }
    val lum by stored { Mat() }
    val orangeTonesMask by stored { Mat() }
    Imgproc.cvtColor(image, hsv, Imgproc.COLOR_BGR2HSV)
    Core.extractChannel(hsv, hue, 0)
    Core.extractChannel(hsv, sat, 1)
    Core.extractChannel(hsv, lum, 2)
    Core.multiply(hue, Scalar.all(255.0 / 179.0), hue)
    val orangeRangeLut by stored {
        createLinearLUT(
            listOf(
                Knot(0.2f, 1.0f),
                Knot(0.3f, 0.0f),
                Knot(0.9f, 0.0f),
                Knot(1.0f, 1.0f),
            )
        )
    }
    Core.LUT(hue, orangeRangeLut, orangeTonesMask)
    Core.multiply(orangeTonesMask, sat, orangeTonesMask, 1.0 / 255.0 * 1)
    Core.multiply(orangeTonesMask, lum, orangeTonesMask, 1.0 / 255.0 * 2.0)
    adjustLuminance(
      orangeTonesMask, 
      orangeTonesMask, 
      contrast = 2.0, 
      brightness = 1.5
      )
    val orangeTonesMask3C by stored { Mat() }
    Core.merge(
      listOf(orangeTonesMask, orangeTonesMask, orangeTonesMask), 
      orangeTonesMask3C
    )
    val orangeTonesMask3CI by stored { Mat() }
    Core.absdiff(orangeTonesMask3C, Scalar.all(255.0), orangeTonesMask3CI)
    val warmColor by stored(listOf(config.warmColorCast)) {
        val mat = Mat.zeros(image.size(), CvType.CV_8UC3)
        mat.setTo(config.warmColorCast.toScalar())
        mat
    }
    val warmColorPart by stored { Mat() }
    Core.multiply(warmColor, orangeTonesMask3C, warmColorPart, 1.0 / 255.0)
    val coldColor by stored(listOf(config.coldColorCast)) {
        val mat = Mat.zeros(image.size(), CvType.CV_8UC3)
        mat.setTo(config.coldColorCast.toScalar())
        mat
    }
    val coldColorPart by stored { Mat() }
    Core.multiply(coldColor, orangeTonesMask3CI, coldColorPart, 1.0 / 255.0)
    Core.add(image, warmColorPart, image)
    Core.add(image, coldColorPart, image)
}
```