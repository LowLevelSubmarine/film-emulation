#import "../../components.typ": authored_by

== Scratches
#authored_by("Leonie Wehser")

=== Theorie
- Ursache: Staub oder Kratzer auf dem Film.
- Sichtbarkeit: Helle oder dunkle Artefakte im Bild.
- Variabilität: Form und Intensität abhängig von Ursache und Filmart.
- Digitale Simulation:
    - Nachbildung des Looks alter/beschädigter Filme.
    - Nutzung für künstlerische Effekte oder Algorithmus-Validierung.

=== Implementierung
- Ziel:
    - Simulation von Kratzern auf digitalen Bildern.
    - Erzeugung zufälliger Kratzertexturen für realistischen Effekt.
- Funktion scratches(image: Mat):
    - Nutzung einer ProcessingDsl-Umgebung.
    - Eingabe: OpenCV-Mat-Objekt.
    - Schritte:
        - Laden verschiedener Kratzertexturen aus Bilddateien.
        - Speicherung in einer Liste.
        - Transformation der Texturen (z. B. Rotation) für Variabilität.
        - Berechnung des Kratzeranteils (scratchAmount):
            - Geringe Wahrscheinlichkeit für hohe Anzahl an Kratzern.
        - Anwendung der Kratzertexturen auf das Eingangsbild:
            - Auswahl einer zufälligen Textur.
            - Bestimmung eines zufälligen Bereichs (ROI) im Bild.
            - Additive Anwendung der Textur mit Core.add().
- Vorteile:
    - Effiziente Erzeugung realistischer Kratzereffekte.
    - Nutzung realer Kratzertexturen statt synthetischer Generierung.
    - Anpassbarkeit durch Variation von Anzahl, Position, Transformationen.
    - Einfache Integration in Bildverarbeitungs-Pipelines.
    - Nützlich für Algorithmus-Tests oder künstlerische Anwendungen.

```kotlin
fun ProcessingDsl.scratches(image: Mat) {
    val textures by stored {
        val rawTextures = (0 until 10).map {
          i -> Imgcodecs.imread("./assets/scratches/$i.png")
        }
        (0 until 30).map {
            val transformation = buildTransformation {
                rotate(Random.nextFloat() * PI * 2)
            }
            val texture = Mat()
            Imgproc.warpAffine(
              rawTextures.random(),
              texture,
              transformation,
              texture.size()
            )
            texture
        }
    }
    val scratchAmount = if (Random.Default.nextFloat() > 0.9) {
        (Random.Default.nextFloat().pow(2) * 5).toInt()
    } else 0
    for (i in 0 until scratchAmount) {
        val texture = textures.random()
        val roiRect = Rect(
            Random.Default.nextInt(image.width() - texture.width()),
            Random.Default.nextInt(image.height() - texture.height()),
            texture.width(),
            texture.height()
        )
        val roi = Mat(image, roiRect)
        Core.add(roi, texture, roi)
    }
}
```
