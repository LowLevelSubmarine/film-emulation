#import "@preview/wrap-it:0.1.1": wrap-content
#import "../../components.typ": authored_by

== Kratzer
#authored_by("Leonie Wehser")

=== Theorie
Staub oder Kratzer auf dem Film führen zu hellen oder dunklen Artefakten im Bild. 
Die Form und Intensität dieser Artefakte hängen von der Ursache und der Art des Films ab.

=== Implementierung
Um Kratzer auf digitalen Bildern zu simulieren, wird die Funktion `scratches` verwendet.

Zunächst werden 10 verschiedene Kratzertexturen aus Bilddateien geladen und in einer Liste gespeichert. Diese Texturen basieren auf realen Kratzern, um eine realistische Darstellung zu gewährleisten. Anschließend werden 30 zufällige Rotationen erstellt und auf zufällige Kratzertexturen angewendet, um Variabilität zu erzeugen.

Der Anteil der anzuwendenden Kratzer (`scratchAmount`) wird berechnet. In 90% der Fälle wird kein Kratzer angewendet. In den restlichen 10% der Fälle wird eine geringe Anzahl von Kratzern festgelegt, wobei die maximale Anzahl 5 beträgt. Danach werden die Kratzertexturen auf das Eingangsbild angewendet. Eine zufällige Textur aus der Liste der 30 transformierten Kratzer wird ausgewählt (@fig:scratches-modification) und ein zufälliger Bereich (ROI = Region of Interest) im Bild bestimmt. Die Textur wird additiv auf das Eingangsbild angewendet (@fig:scratches-output).

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

#grid(
  columns: (1fr, 1fr, 1fr),
  align: (left, center, right),
  [
    #box(width: 145pt)[
     #figure(
            image("../../assets/effects/input.png", width: 100%),
            caption: [Eingabebild - Scratches],
        )<fig:scratches-input>
    ] ],
  [
    #box(height: 165pt, width: 145pt)[
       #figure(
            image("../../assets/effects/scratches/modification.png", height: 100%, width: 100%),
            caption: [Modifikation - Scratches],
        )<fig:scratches-modification>
    ]],
    [
    #box(width: 145pt)[
      #figure(
            image("../../assets/effects/scratches/output.png", width:  100%),
            caption: [Ausgabebild - Scratches],
        )<fig:scratches-output>
    ]
  ]
)
