#import "@preview/wrap-it:0.1.1": wrap-content
#import "../../components.typ": authored_by

== Grain
#authored_by("Leonie Wehser")
=== Theorie
Wie im @topic:fotoemulsion erläutert, enthalten analoge Farbfilme lichtempfindliche Kristalle. Die Körnung variiert zufällig über das Bild. Bei der Entwicklung können durch die Kristalle feine, chemisch bedingte Bildstörungen auftreten. Diese unregelmäßige, organische Verteilung verleiht den Bildern ein natürlicheres Aussehen. Der ISO-Wert beeinflusst die Korn-Bildung: Bei höheren ISO-Werten bilden sich größere Kristalle und somit auch ein stärkeres Rauschen (@fig:grain-ISO1600). Ein glatteres Bild erhält man bei niedrigeren ISO-Werten (@fig:grain-ISO25).

#grid(
  columns: (1fr, 1fr),
  align: (left, right),
  [
    #box(width: 200pt)[
      #figure(
          image("../../assets/effects/grain/ISO1600.jpg", width: 100%),
          caption: [Korn eines Films mit ISO 1600 @grain-images ],
      )<fig:grain-ISO1600>
  ]],
  [
  #box(width: 200pt)[
      #figure(
          image("../../assets/effects/grain/ISO25.jpg", width: 100%),
          caption: [Korn eines Films mit ISO 25 @grain-images ],
      )<fig:grain-ISO25>
    ]
  ]
)
=== Implementierung
Ziel ist es, Filmrauschen durch statisches und dynamisches Rauschen zu emulieren. Zunächst wird eine statische Grain-Textur aus den Assets geladen. Die Intensität der Textur wird mit `config.grainStrength` multipliziert, um die Stärke des Effekts zu steuern. Anschließend wird die Grain-Textur um den Faktor `grainScale = 0.4` verkleinert. Dieser Wert beeinflusst die Größe der Körnung: Je größer der Wert, desto gröber erscheint die Körnung. Ein Wert von 0.4 sorgt dafür, dass die Körnung nicht zu dominant wirkt.

Um das Rauschen dynamisch darzustellen, wird ein zufälliger Offset mit `createRandomOffsetTransformation()` generiert. Diese Transformation wird auf die Grain-Textur angewendet, um bei jedem Frame ein anderes Rauschen zu emulieren, ähnlich wie bei analogen Filmen. Das Ergebnis wird in `dynamicGrain` gespeichert. Dabei verhindert `Core.BORDER_REFLECT`, dass das Rauschen am Rand des Bildes abgeschnitten wird, stattdessen wird es gespiegelt.

Bevor das Rauschen zum Eingabebild hinzugefügt wird, wird das Bild um `150 * config.grainStrength` aufgehellt, um zu verhindern, dass das Ausgabebild durch das Rauschen zu dunkel wird. Abschließend wird das dynamische Rauschen vom Eingabebild subtrahiert, um den gewünschten Effekt zu erzeugen.
  
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

#grid(
  columns: (1fr, 1fr, 1fr),
  align: (left, center, right),
  [
    #box(width: 145pt)[
      #figure(
          image("../../assets/effects/input.png", width: 100%),
          caption: [Eingabebild - Grain],
      )<fig:grain-input>
    ] ],
  [
    #box(width: 145pt)[
      #figure(
          image("../../assets/effects/grain/modification.png", width: 100%),
          caption: [Modifikation - Grain],
      )<fig:grain-modification>
    ]],
    [
    #box(width: 145pt)[
      #figure(
          image("../../assets/effects/grain/output.png", width: 100%),
          caption: [Ausgabebild - Grain],
      )<fig:grain-output>
    ]
  ]
)