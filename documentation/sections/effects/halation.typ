#import "../../components.typ": authored_by

== Halation

=== Theorie 
#authored_by("")

=== Implementierung
#authored_by("")

```kotlin
fun ProcessingDsl.halation(
  inputImage: Mat, 
  destinationImage: Mat, 
  config: Config) {
    val halationRes = 0.5
    val redChannelImage = store { Mat() }
    Core.extractChannel(inputImage, redChannelImage, 2) // red channel isolated
    val gammaLut = store(listOf(config.halationThreshold)) { 
      createGammaLUT(config.halationThreshold.toDouble()) 
    }
    Imgproc.resize(
      redChannelImage, 
      redChannelImage, 
      Size(), 
      halationRes, 
      halationRes, 
      Imgproc.INTER_LINEAR
    )
    Core.LUT(redChannelImage, gammaLut, redChannelImage)
    measureTime("halation: gaussian blur") {
        GaussianBlur(
            redChannelImage,
            redChannelImage,
            config.halationGaussianSize.toSize().map { 
              (it * halationRes).roundToInt().odd().toDouble() 
            },
            config.halationSigmaX.toDouble()
        ) // blurred red channel
    }
    adjustLuminance(
      redChannelImage, 
      redChannelImage, 
      brightness = config.halationStrength.toDouble()
    )
    Imgproc.resize(
      redChannelImage, 
      redChannelImage, 
      Size(), 
      1.0 / halationRes, 
      1.0 / halationRes, 
      Imgproc.INTER_LINEAR
    )
    val threeChannelImage by stored { 
      Mat.zeros(inputImage.size(), CV_8UC3) 
    }  // black image with 3 channels
    Core.insertChannel(redChannelImage, threeChannelImage, 2)
    Core.add(inputImage, threeChannelImage, destinationImage)
}
```