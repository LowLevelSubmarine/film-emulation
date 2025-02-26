#import "../../components.typ": authored_by

== Scratches
#authored_by("Leonie Wehser")

=== Theorie 
- Scratches entstehen durch Staub oder Kratzer auf dem Film.
- Sie können als helle oder dunkle Artefakte im Bild sichtbar werden.
- Die Form und Intensität der Kratzer kann variieren, abhängig von der Ursache und der Art des Films.
- In der digitalen Bildverarbeitung können solche Effekte simuliert werden, um den Look alter oder beschädigter Filme nachzubilden.
- Diese Simulation kann für künstlerische Effekte oder zur Validierung von Algorithmen zur Kratzerentfernung genutzt werden.

=== Implementierung
- Ziel der Implementierung:
    - Simulation von Kratzern auf digitalen Bildern, um den Look alter oder beschädigter Filme zu erzeugen.
    - Erzeugung zufälliger Kratzertexturen zur realistischen Nachbildung von Filmfehlern.
- Beschreibung der Funktion scratches(image: Mat):
    - Die Funktion arbeitet innerhalb einer ProcessingDsl-Umgebung und nimmt ein OpenCV-Mat-Objekt als Eingabe.
    - Zunächst werden verschiedene Kratzertexturen aus Bilddateien geladen und in einer Liste gespeichert.
    - Eine zufällige Auswahl an Texturen wird durch verschiedene Transformationen (z. B. Rotation) verändert, um Variabilität zu gewährleisten.
    - Ein zufälliger Kratzeranteil (scratchAmount) wird berechnet, wobei eine geringe Wahrscheinlichkeit für eine hohe Anzahl an Kratzern besteht.
    - Die Kratzertexturen werden dann zufällig auf das Eingangsbild angewendet:
        - Eine zufällige Textur wird ausgewählt.
        - Ein zufälliger Bereich (ROI) im Bild wird bestimmt.
        - Die Textur wird auf diesen Bereich mit Core.add() additiv angewendet, um den Effekt eines Kratzers zu erzeugen.
- Vorteile der Implementierung:
    - Effiziente Erzeugung zufälliger Kratzereffekte mit realistischen Variationen.
    - Nutzung vorhandener Kratzertexturen anstelle synthetischer Generierung für höhere Authentizität.
    - Möglichkeit der Anpassung durch Variationen in Anzahl, Position und Transformationen der Kratzer.
    - Flexibel in verschiedene Bildverarbeitungs-Pipelines integrierbar.
    - Ermöglicht Tests von Algorithmen zur Kratzerentfernung oder künstlerische Anwendungen.

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