#import "../../components.typ": authored_by

== Grain
#authored_by("Leonie Wehser")

=== Theorie 
- Feine Bildstörungen, anders als bei Digital-Film unabhängig von Pixeln, wirkt natürlicher
- Entsteht durch die Ballung / Unregelmäßigkeit der Kristalle
- Je höher der ISO-Wert (Empfindlichkeit) des Films, desto größer die Kristalle und stärker ausgeprägt der Film-Grain

=== Implementierung
```kotlin
fun ProcessingDsl.grain(inputImage: Mat, destinationImage: Mat, config: Config) {
    val grainScale = 0.4
    val staticGrain = store(dependencies = listOf(config.grainStrength)) {
        val texture = Imgcodecs.imread("./assets/grain/grain4.jpeg")
        Core.multiply(
          texture, 
          Scalar.all(config.grainStrength.toDouble()), 
          texture
        )
        val size = Size(
          texture.width().toDouble() * grainScale, 
          texture.height().toDouble() * grainScale
        )
        Imgproc.resize(texture, texture, size)
        Mat(texture, Rect(Point(), inputImage.size()))
    }
    val dynamicGrain = store { Mat() }
    val transformation = createRandomOffsetTransformation(inputImage)
    Imgproc.warpAffine(
      staticGrain, 
      dynamicGrain, 
      transformation, 
      dynamicGrain.size(), 
      0, 
      Core.BORDER_REFLECT
    )
    Core.add(
      inputImage, 
      Scalar.all(150.0 * config.grainStrength.toDouble()), 
      destinationImage
    )
    Core.subtract(destinationImage, dynamicGrain, destinationImage)
}
```