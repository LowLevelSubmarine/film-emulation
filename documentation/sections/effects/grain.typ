#import "../../components.typ": authored_by

== Grain
#authored_by("Leonie Wehser")

=== Theorie
- Definition von Film Grain:
  - Feine Bildstörungen, chemisch bedingt, nicht pixelbasiert.
  - Unregelmäßige Körnung, natürlicher Look.
  - Unterschied zu digitalem Rauschen: organische Verteilung vs. pixelbasierte Gleichförmigkeit.
- Entstehung von Film Grain:
  - Abhängig von der chemischen Struktur des Films.
  - Verteilung und Größe lichtempfindlicher Kristalle bestimmen die Körnung.
  - Körnung variiert zufällig über das Bild.
- Einfluss des ISO-Werts auf das Film Grain:
  - Höhere ISO-Werte = größere Kristalle = stärkeres Grain.
  - Niedrigere ISO-Werte = kleinere Kristalle = feineres Grain.
  - Glatteres Bild bei niedriger ISO.
- Subjektive Wirkung von Film Grain:
  - Nostalgische, cineastische Anmutung.
  - Analoge Filme wirken wärmer und authentischer.
  - Digitale Bilder wirken weniger klinisch durch Grain.

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
