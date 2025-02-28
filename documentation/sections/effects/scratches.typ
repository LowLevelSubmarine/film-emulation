#import "@preview/wrap-it:0.1.1": wrap-content
#import "../../components.typ": authored_by

== Scratches
#authored_by("Leonie Wehser")

=== Theorie
Staub oder Kratzer auf dem Film führen zu hellen oder dunklen Artefakten im Bild. 
Die Form und Intensität dieser Artefakte hängen von der Ursache und der Art des Films ab.

#wrap-content(
    [
      #pad(box(width: 160pt)[
        #figure(
            image("../../assets/effects/input.png", width: 100%),
            caption: [Beispiel Eingabebild],
        )<fig:scratches-input>
        #figure(
            image("../../assets/effects/scratches/modification.png", width: 100%),
            caption: [Kratzer-Maske],
        )<fig:scratches-modification>
        #figure(
            image("../../assets/effects/scratches/output.png", width: 100%),
            caption: [Ausgabebild für Kratzer],
        )<fig:scratches-output>
      ], left: 12pt, bottom: 12pt)
    ],
    [
        === Implementierung
        Um Kratzer auf digitalen Bildern zu simulieren, wird die Funktion `scratches` verwendet.

        Zunächst werden verschiedene Kratzertexturen aus Bilddateien geladen und in einer Liste gespeichert. Dabei werden reale Kratzertexturen verwendet, um synthetische Generierung zu vermeiden und realistische Ergebnisse zu erzielen. Die Texturen werden durch Rotation transformiert, um Variabilität zu erzeugen.

        Der Anteil der anzuwendenden Kratzer (`scratchAmount`) wird berechnet, wobei eine geringe Wahrscheinlichkeit für eine hohe Anzahl an Kratzern festgelegt wird. Anschließend werden die Kratzertexturen auf das Eingangsbild angewendet. Dazu wird eine zufällige Textur ausgewählt (@fig:scratches-modification) und ein zufälliger Bereich (ROI = Region of Interest) im Bild bestimmt. Die Textur wird additiv auf das Eingangsbild angewendet (@fig:scratches-output).
    ],
  align: right,
)

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

