#import "@preview/wrap-it:0.1.1": wrap-content
#import "../../components.typ": authored_by

#wrap-content(
    [
      #pad(box(width: 160pt)[
        #figure(
            image("../../assets/effects/grain/ISO1600.jpg", width: 100%),
            caption: [Korn eines Films mit ISO 1600 @grain-images ],
        )<fig:grain-ISO1600>
        #figure(
            image("../../assets/effects/grain/ISO25.jpg", width: 100%),
            caption: [Korn eines Films mit ISO 25 @grain-images ],
        )<fig:grain-ISO25>
      ], left: 12pt, bottom: 12pt)
    ],
    [
      == Grain
      #authored_by("Leonie Wehser")
      === Theorie
      Wie im @topic:fotoemulsion erläutert, enthalten analoge Farbfilme lichtempfindliche Kristalle. Die Körnung variiert zufällig über das Bild. Bei der Entwicklung können durch die Kristalle feine, chemisch bedingte Bildstörungen auftreten. Diese unregelmäßige, organische Verteilung verleiht den Bildern ein natürlicheres Aussehen. Der ISO-Wert beeinflusst die Korn-Bildung: Bei höheren ISO-Werten bilden sich größere Kristalle und somit auch ein stärkeres Rauschen (@fig:grain-ISO1600). Ein glatteres Bild erhält man bei niedrigeren ISO-Werten (@fig:grain-ISO25).
    ],
  align: right,
)

#wrap-content(
    [
      #pad(box(width: 160pt)[
        #figure(
            image("../../assets/effects/input.png", width: 100%),
            caption: [Beispiel Eingabebild],
        )<fig:grain-input>
        #figure(
            image("../../assets/effects/grain/modification.png", width: 100%),
            caption: [Grain-Mask],
        )<fig:grain-modification>
        #figure(
            image("../../assets/effects/grain/output.png", width: 100%),
            caption: [Ausgabebild für Körnung],
        )<fig:grain-output>
      ], left: 12pt, bottom: 12pt)
    ],
    [
      === Implementierung
      - Ziel der Implementierung:
        - Simulation von Film Grain durch statisches und dynamisches Rauschen.
        - Verwendung einer Grain-Textur mit zufälliger Modifikation.
        - Realistische Nachbildung analoger Filmkörnung.
      - Einlesen der Grain-Textur:
        - Laden einer Bilddatei (grain4.jpeg).
        - Skalierung zur Anpassung an Bildgröße (grainScale = 0.4).
      - Verstärkung des Grain-Effekts:
        - Anpassung der Intensität durch Multiplikation mit config.grainStrength.
        - Analog zur realen Filmempfindlichkeit.
      - Dynamisches Grain:
        - Generierung eines zufälligen Offsets (createRandomOffsetTransformation).
        - Transformation der Grain-Textur (Imgproc.warpAffine).
        - Simuliert die Bewegung des Film Grain.
      - Kombination von Grain und Originalbild:
        - Addition (Core.add) hellt bestimmte Bereiche auf.
        - Subtraktion (Core.subtract) reduziert Helligkeit für realistischen Effekt.
      - Vorteile der Implementierung:
        - Authentische Film Grain-Nachbildung mit Anpassungsmöglichkeiten.
        - Kombination aus statischem und dynamischem Grain.
        - Parametersteuerung für unterschiedliche ISO-Simulationen.
        - Digitalen Bildern wird ein analoger Charakter verliehen.
   ],
  align: right,
)

```kotlin
fun ProcessingDsl.grain(inputImage: Mat, destinationImage: Mat, config: Config) {
    val grainScale = 0.4
    val staticGrain = store(dependencies = listOf(config.grainStrength)) {
        val texture = Imgcodecs.imread("./assets/grain/grain4.jpeg")
        // effekt verringern
        Core.multiply(
          texture,
          Scalar.all(config.grainStrength.toDouble()),
          texture
        )
        // verringerung der Größe
        val size = Size(
          texture.width().toDouble() * grainScale,
          texture.height().toDouble() * grainScale
        )
        // verkleinerung des bildes
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
