#import "@preview/wrap-it:0.1.1": wrap-content
#import "../../components.typ": authored_by, input_output_figures

== Crushed Luminance
#authored_by("Florian Weichert")

=== Theorie 
Analog-Film hat im Vergleich zu digitalen Bildern einen höheren Dynamikumfang in den hellen Bildbereichen. Dieser Effekt entsteht durch die Eigenschaften der Fotoemulsion, die in der Lage ist, sehr helle Bildbereiche abzubilden, ohne dass diese überbelichtet wirken. Digitale Bilder hingegen haben eine geringere Dynamik in den hellen Bildbereichen, sie tendieren bei einer Überbelichtung schnell zu einem reinen Weiß @how-to-edit-like-film. Zusätzlich kann es passieren, dass im Scan-Vorgang die maximal hellen und dunklen Bereiche nicht perfekt abgebildet werden können.
=== Implementierung
#wrap-content(
    [
      #pad(left: 12pt, bottom: 12pt)[
        #box(width: 150pt)[
          #figure(
              image("../../assets/effects/crushed_luminance/modification.png"),
              caption: [Nachahmung der verwendeten Luminanz-Kurve],
          )<fig:crushed-luminance-curve>
        ]
      ]
    ],
    [
      Um diese Eigenschaften des analogen Films zu emulieren, wird eine Luminanz-Kurve (@fig:crushed-luminance-curve) auf das Bild angewendet. Dafür wird zunächst ein LUT generiert, welches die Luminanz-Werte anhand einer Splines auf andere Luminanz-Werte abbildet. Diese Spline wird durch 2-dimensionale Knoten definiert. Das anschließend generierte LUT wird aus Performance-Gründen zwischengespeichert. Anschließend wird das LUT auf das Bild angewendet. Die Stärke der Luminanz-Veränderung kann durch einen Parameter (`crushedLuminanceStrength`) angepasst werden. Damit das Bild durch die neue Luminanz-Kurve nicht zu sehr an Kontrast verliert, wird zuvor ein Kontrast-LUT auf das Bild angewendet. Dieses besteht aus zwei Knoten (also lineare Interpolation) und wird ebenfalls zwischengespeichert.
    ],
    align: right,
)

```kotlin
fun ProcessingDsl.crushedLuminance(
  inputImage: Mat, 
  destinationImage: Mat, 
  config: Config
) {
    val contrastLut by stored { 
      createSplineLUT(Knot(0.2f, 0.0f), Knot(0.8f, 1.0f)) 
    }
    Core.LUT(inputImage, contrastLut, destinationImage)
    val lut by stored(listOf(config.crushedLuminanceStrength)) {
        createSplineLUT(
            Knot(0.0f, config.crushedLuminanceStrength * 0.2f),
            Knot(0.2f, 0.2f),
            Knot(0.8f, 0.8f),
            Knot(1.0f, 1.0f - config.crushedLuminanceStrength * 0.2f)
        )
    }
    Core.LUT(destinationImage, lut, destinationImage)
}
```
#input_output_figures("Crushed Luminance", "/assets/effects/crushed_luminance/output.png")