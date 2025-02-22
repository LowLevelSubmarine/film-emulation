#import "../../components.typ": authored_by

== Gate Weave

=== Theorie 
#authored_by("")

=== Implementierung
#authored_by("")

```kotlin
fun ProcessingDsl.shake(inputImage: Mat, destinationImage: Mat, config: Config) {
    var weaveNoiseOffset by stored { 0.0 }
    val weaveNoiseGenerator =
        store { 
          JNoise.newBuilder().perlin(3301, 
          Interpolation.COSINE, 
          FadeFunction.QUINTIC_POLY).build() 
          }
    val x = Random.nextFloat() * config.jitterScale + weaveNoiseGenerator.evaluateNoise(weaveNoiseOffset, 0.0)
        .toFloat() * config.weaveNoiseScale
    val y = Random.nextFloat() * config.jitterScale + weaveNoiseGenerator.evaluateNoise(weaveNoiseOffset, 100.0)
        .toFloat() * config.weaveNoiseScale * 0.5f

    weaveNoiseOffset += config.weaveNoiseSpeed

    val transformation = Mat.zeros(2, 3, CV_32F).apply {
        put(0, 0, floatArrayOf(1.0F))
        put(1, 1, floatArrayOf(1.0F))
        put(0, 2, floatArrayOf(inputImage.width().toFloat() * x))
        put(1, 2, floatArrayOf(inputImage.height().toFloat() * y))
    }
    Imgproc.warpAffine(
        inputImage,
        destinationImage,
        transformation,
        destinationImage.size(),
        0,
        Core.BORDER_REFLECT
    )
}
```