#import "@preview/wrap-it:0.1.1": wrap-content
#import "../../components.typ": authored_by

== Vignette
#authored_by("Leonie Wehser")

=== Theorie 
Vignettierung beschreibt die Abschattung zum Bildrand hin. Es gibt verschiedene Ursachen für Vignettierung:

#text("1. Mechanische oder physikalische Vignettierung:", weight: "semibold") Hierbei durchqueren die Lichtstrahlen mehrere aufeinanderfolgende Öffnungen (wie das Objektivgehäuse, die Blende und die Linsenränder), bevor sie die Bildebene erreichen. Durch physikalische Behinderungen beim Durchqueren dieser Öffnungen tritt eine starke, dunkle, kreisförmige Verdunkelung auf, die in den Ecken am deutlichsten sichtbar ist. Um den Effekt zu mindern, hilft es, das Objektiv abzublenden.

#text("2. Optische Vignettierung:", weight: "semibold") Diese tritt auf, wenn das Licht in einem steilen Winkel auf die Objektivblende trifft. Es entsteht ein internes physisches Hindernis, da das Licht teilweise von der Blende blockiert wird. Der Effekt tritt besonders oft bei Weitwinkelobjektiven mit großer Blendenöffnung auf. Durch Abblenden des Objektivs kann der Effekt reduziert oder sogar eliminiert werden.

=== Implementierung
Um den klassischen Analogfilm-Look zu verbessern, wird ein Vignetteneffekt hinzugefügt. Dieser Effekt dunkelt die Bildränder ab und lenkt den Fokus auf das Zentrum des Bildes. Der Vignetteneffekt wird durch die Funktion `vignette(image: Mat, config: Config)` implementiert.

Der Effekt wird in mehreren Schritten umgesetzt:
Es wird eine Vignettenmaske erstellt, die die Bildränder abdunkelt (@fig:vignette-modification). `createVignetteMask()` erstellt dafür ein schwarzes 3-Kanal-Bild von der Größe des Eingabebildes und speichert den Mittelpunkt des Bildes in `center`. Anschließend speichert man die maximale Distanz vom Mittelpunkt zum Bildrand in `maxDist`. 
In einer doppelten Schleife wird für jeden Pixel der Richtungsvektor `delta` zum Mittelpunkt berechnet. Mit diesem Vektor wird die Distanz zum Mittelpunkt berechnet und mit dem maximalen Abstand normiert. Nun kann der Farbwert für den Pixel berechnet werden, indem die normierte Distanz mit der Stärke des Effekts multipliziert und auf den Wertebereich von 0 bis 255 skaliert wird. Dieser Wert wird als Grauwert für alle drei Kanäle des Pixels gesetzt.
Die Stärke des Effekts wird durch den Konfigurationswert `config.vignetteStrength` bestimmt.
Die Berechnung der Maske erfolgt nur einmal und wird zwischengespeichert, solange der Wert von `config.vignetteStrength` unverändert bleibt, um die Effizienz zu erhöhen. Die Maske wird vom Bild subtrahiert, um den Vignetteneffekt zu erzeugen (@fig:vignette-output).

```kotlin
fun ProcessingDsl.vignette(
  image: Mat, 
  config: Config
) {
  val mask by stored(
    dependencies = listOf(config.vignetteStrength)
  ) {
    createVignetteMask(
      config.vignetteStrength.toDouble(),
      image.size()
    )
  }
  Core.subtract(image, mask, image)
}

fun createVignetteMask(strength: Double, size: Size): Mat {
    val mask = Mat(size, CvType.CV_8UC3)
    val center = Point(size.height / 2, size.width / 2)
    val maxDist = sqrt(center.x.pow(2.0) + center.y.pow(2.0))
    for (x in 0 until size.height.toInt()) {
        for (y in 0 until size.width.toInt()) {
            val delta = Point(x - center.x, y - center.y)
            val dist = sqrt(delta.x.pow(2.0) + delta.y.pow(2.0)) / maxDist
            val value = min((dist * strength * 255).toInt(), 255).toByte()
            mask.at(Byte::class.java, x, y).v3c = Mat.Tuple3(value, value, value)
        }
    }
    return mask
}
```

#grid(
  columns: (1fr, 1fr, 1fr),
  align: (left, center, right),
  [
    #box(width: 145pt)[
      #figure(
            image("../../assets/effects/input.png", width: 100%),
            caption: [Eingabebild - Vignette],
        )<fig:vignette-input>
    ] ],
  [
    #box(width: 145pt)[
       #figure(
            image("../../assets/effects/vignette/modification.png", width: 100%),
            caption: [Vignettierungsmaske],
        )<fig:vignette-modification>
    ]],
    [
    #box(width: 145pt)[
      #figure(
            image("../../assets/effects/vignette/output.png", width: 100%),
            caption: [Ausgabebild - Vignette],
        )<fig:vignette-output>
    ]
  ]
)



