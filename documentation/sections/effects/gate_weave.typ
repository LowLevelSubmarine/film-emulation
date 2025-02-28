#import "../../components.typ": authored_by

== Gate Weave
#authored_by("Florian Weichert")

=== Theorie
Das Analog-Bild läuft als Teil von Bewegt-Bildern sowohl während der Aufnahme als auch während der Wiedergabe mit einem Projektor oder der digitalen Aufzeichnung mit einem Scanner über verschiedene Rollenführungen. Diese Rollenführungen sorgen, besonders in älteren Systemen, für Ungenauigkeiten in der Platzierung des Bildes. Diese Ungenauigkeiten zeigen sich in Form von weichen Schwankungen des Bildes. Dieser Effekt wird als Gate Weave bezeichnet. Zusätzlich kann ein ungenaues Auslösen des Verschlusses zu einem ähnlichen Verwackeln führen. Dieser Effekt ist jedoch hochfrequenter, aber weniger stark ausgeprägt. @gate-weave-1 @gate-weave-2

=== Implementierung
Damit das Bild das charakteristische Wackeln aufweist, wird ein Zufallsgenerator benötigt, dessen Ausgabewerte zwar pseudo-zufällig sind, jedoch kontinuierlich bleiben, also nicht sprunghaft sind. Hierfür verwenden wir die Rauschfunktion Perlin-Noise. Zwei Ausgabewerte der Rauschfunktion mit verschiedenen Eingabewerten werden verwendet, um die Verschiebung des Bildes zu berechnen. Für das hochfrequente Verwackeln wird zusätzlich noch ein Zufallswert je Frame neu generiert und auf die Verschiebung addiert. Für die Verschiebung selbst wird die OpenCV-Funktion `warpAffine` verwendet. Diese erlaubt es, neben der Verschiebung auch ein Verhalten für die Bereiche des Bildes festzulegen, die durch die Verschiebung nicht mehr durch das Original abgedeckt werden. Für diesen Effekt wird der Rand des Bildes gespiegelt, um diese Bildbereiche möglichst störungsfrei zu füllen.

```kotlin
fun ProcessingDsl.shake(inputImage: Mat, destinationImage: Mat, config: Config) {
    var weaveNoiseOffset by stored { 0.0 }
    val weaveNoiseGenerator =
        store { 
          JNoise.newBuilder().perlin(3301, 
          Interpolation.COSINE, 
          FadeFunction.QUINTIC_POLY).build() 
        }
    val x = Random.nextFloat() * config.jitterScale + weaveNoiseGenerator.evaluateNoise(weaveNoiseOffset, 0.0)
        .toFloat() * config.weaveNoiseScale
    val y = Random.nextFloat() * config.jitterScale + weaveNoiseGenerator.evaluateNoise(weaveNoiseOffset, 100.0)
        .toFloat() * config.weaveNoiseScale * 0.5f

    weaveNoiseOffset += config.weaveNoiseSpeed

    val transformation = Mat.zeros(2, 3, CV_32F).apply {
        put(0, 0, floatArrayOf(1.0F))
        put(1, 1, floatArrayOf(1.0F))
        put(0, 2, floatArrayOf(inputImage.width().toFloat() * x))
        put(1, 2, floatArrayOf(inputImage.height().toFloat() * y))
    }
    Imgproc.warpAffine(
        inputImage,
        destinationImage,
        transformation,
        destinationImage.size(),
        0,
        Core.BORDER_REFLECT
    )
}
```