#import "../../components.typ": authored_by, input_output_figures

== Staub
#authored_by("Florian Weichert")

=== Theorie
Es gibt zwei Arten, wie Staub einen Einfluss auf das endgültige Bild haben kann. Zum einen kann sich Staub in der Kamera befinden, der das eintreffende Licht blockiert, bevor es auf den Film selbst treffen kann. Zum anderen gibt es Staub, der während der Entwicklung einen Einfluss auf das Bild hat. Dieser Staub ist in Form von hellen Artefakten zu erkennen. In diesem Effekt wird der erstere Typ emuliert. @understanding-film-flaws

=== Implementierung
Der Effekt wird in zwei Schritten umgesetzt. Zuerst wird ein statisches Bild des Staubes geladen und auf die Größe des Bildes skaliert. Anschließend wird das Bild mit einer zufälligen Transformation auf das Eingabebild gelegt. Die Transformation wird so gewählt, dass der Staub nicht nur an einer Stelle ist, sondern sich über das gesamte Bild verteilt. Um den Effekt nicht für eine realistische Anwendung zu stark zu machen, wird der Effekt mit einer Wahrscheinlichkeit von 5% je Frame angewendet. Das Bild des Staubes ist Schwarz-Weiß, wobei die weißen Stellen den Staub darstellen. Damit der Staub als weiße Artefakte auf dem Bild sichtbar wird, genügt es, den Staub von dem originalen Bild zu subtrahieren. Um die Verarbeitung zu optimieren, wird der Staub nur einmal geladen und skaliert. Nur die Transformation muss für jedes Frame angepasst werden, daher wird auch nur diese für jedes Frame neu berechnet.

```kotlin
fun ProcessingDsl.dust(image: Mat, config: Config) {
    val dustScale = 0.7
    val staticDust = store(dependencies = listOf(config.dustStrength)) {
        val texture = Imgcodecs.imread("./assets/dust/dust-2.png")
        Core.multiply(
          texture, 
          Scalar.all(config.dustStrength.toDouble()), 
          texture
        )
        val size = Size(
          texture.width().toDouble() * dustScale, 
          texture.height().toDouble() * dustScale
        )
        Imgproc.resize(texture, texture, size)
        Mat(texture, Rect(Point(), image.size()))
    }
    val dynamicDust = store { Mat() }
    if (Random.Default.nextFloat() > 0.05) return
    val transformation = createRandomOffsetTransformation(image)
    Imgproc.warpAffine(
      staticDust, 
      dynamicDust, 
      transformation, 
      dynamicDust.size(), 
      0, 
      Core.BORDER_REFLECT
    )
    Core.subtract(image, dynamicDust, image)
}
```

#input_output_figures("Dust", "/assets/effects/dust/output.png")
