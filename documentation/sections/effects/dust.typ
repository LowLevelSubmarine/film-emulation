#import "../../components.typ": authored_by

== Dust

=== Theorie 
#authored_by("")

=== Implementierung
#authored_by("")

```kotlin
fun ProcessingDsl.dust(image: Mat, config: Config) {
    val dustScale = 0.7
    val staticDust = store(dependencies = listOf(config.dustStrength)) {
        val texture = Imgcodecs.imread("./assets/dust/dust-2.png")
        Core.multiply(
          texture, 
          Scalar.all(config.dustStrength.toDouble()), 
          texture
        )
        val size = Size(
          texture.width().toDouble() * dustScale, 
          texture.height().toDouble() * dustScale
        )
        Imgproc.resize(texture, texture, size)
        Mat(texture, Rect(Point(), image.size()))
    }
    val dynamicDust = store { Mat() }
    if (Random.Default.nextFloat() > 0.05) return
    val transformation = createRandomOffsetTransformation(image)
    Imgproc.warpAffine(
      staticDust, 
      dynamicDust, 
      transformation, 
      dynamicDust.size(), 
      0, 
      Core.BORDER_REFLECT
    )
    Core.add(image, dynamicDust, image)
}
```