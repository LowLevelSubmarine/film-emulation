#import "@preview/wrap-it:0.1.0": wrap-content
#import "../../components.typ": authored_by

== Halation
#authored_by("Leonie Wehser")


=== Theorie 
#wrap-content(
    [
      #pad(box(width: 150pt)[
         #figure(
            image("../../assets/effects/halation/example.jpg", width: 150pt),
            caption: [Beispielbild für Halation @halation-example-image ],
        )<fig:halation-example>,
        #figure(
            image("../../assets/effects/halation/theorie.png", width: 150pt),
            caption: [Darstellung des \ einfallenden
           Lichts auf einen Farbfilm],
        )<fig:halation-theorie>
      ], left: 12pt, bottom: 12pt)
    ],
    [
        (@fig:halation-example)
        (@fig:halation-theorie)
        - Entsteht durch auf die Emulsionsschichten zurück geworfenes Licht
          - Rückseite der Film-Basis
          - Oberflächen auf der Film-Rückseite
        - Licht trifft zum Großteil auf die rot-empfindliche Schicht
        - Es entstehen rötliche Verfärbungen an den Rändern heller Bild-Bereiche
        - Eine Anti-Halation-Schicht mindert den Effekt deutlich, jedoch nicht vollständig
    ],
    align: right,
)

=== Implementierung

#figure(
  image("../../assets/effects/halation/diagram.png",
      height: 250pt),
  caption: [Implementierungsablauf für die Halation],
)<fig:halation-diagram>

#wrap-content(
    [
      #pad(
        box(width: 150pt)[
          #figure(
              image("../../assets/effects/halation/input.png"),
              caption: [Beispiel Eingabebild],
          )<fig:halation-input>
          #figure(
              image("../../assets/effects/halation/step1.png"),
              caption: [Extraktion des roten Bildkanals],
          )<fig:halation-step1>
          #figure(
              image("../../assets/effects/halation/step2.png"),
              caption: [Isolierung der extrem hellen Bildbereiche],
          )<fig:halation-step2>
          #figure(
              image("../../assets/effects/halation/step3.png"),
              caption: [Weichzeichnung der isolierten Bildbereiche],
          )<fig:halation-step3>
          #figure(
              image("../../assets/effects/halation/step4.png"),
              caption: [Rückführung in einen 3-Kanal-Buffer],
          )<fig:halation-step4>
          #figure(
              image("../../assets/effects/halation/output.png"),
              caption: [Addition auf das Eingabebild],
          )<fig:halation-output>
        ],
        left: 12pt, bottom: 12pt
      )
    ],
    [
      #lorem(100)
    ],
    align: right,
)

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