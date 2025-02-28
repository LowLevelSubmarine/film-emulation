#import "@preview/wrap-it:0.1.1": wrap-content
#import "../../components.typ": authored_by

== Vignette
#authored_by("Leonie Wehser")

=== Theorie 
Vignettierung beschreibt die Abschattung zum Bildrand hin. Es gibt verschiedene Ursachen für Vignettierung:

#text("1. Mechanische oder physikalische Vignettierung:", weight: "semibold") Hierbei durchqueren die Lichtstrahlen mehrere aufeinanderfolgende Öffnungen (wie das Objektivgehäuse, die Blende und die Linsenränder), bevor sie die Bildebene erreichen. Durch physikalische Behinderungen beim Durchqueren dieser Öffnungen tritt eine starke, dunkle, kreisförmige Verdunkelung auf, die in den Ecken am deutlichsten sichtbar ist. Um den Effekt zu mindern, hilft es, das Objektiv abzublenden.

#text("2. Optische Vignettierung:", weight: "semibold") Diese tritt auf, wenn das Licht in einem steilen Winkel auf die Objektivblende trifft. Es entsteht ein internes physisches Hindernis, da das Licht teilweise von der Blende blockiert wird. Der Effekt tritt besonders oft bei Weitwinkelobjektiven mit großer Blendenöffnung auf. Durch Abblenden des Objektivs kann der Effekt reduziert oder sogar eliminiert werden.

#text("3. Pixelvignettierung:", weight: "semibold") Ein Pixelsensor besteht aus Millionen von Photonenschächten, die das auftreffende Licht messen. Diese Schächte sind extrem klein, haben aber eine gewisse Tiefe. Bei starkem Lichteinfall trifft das Licht möglicherweise nicht den Boden der Schächte. Besonders ausgeprägt ist der Effekt an den Bildrändern. Man kann den Effekt durch bestimmte Sensoralgorithmen korrigieren.

=== Implementierung
Um den klassischen Analogfilm-Look zu verbessern, wird ein Vignetteneffekt hinzugefügt. Dieser Effekt dunkelt die Bildränder ab und lenkt den Fokus auf das Zentrum des Bildes. Der Vignetteneffekt wird durch die Funktion `vignette(image: Mat, config: Config)` implementiert.

Der Effekt wird in mehreren Schritten umgesetzt:
Zunächst wird eine Vignettenmaske erstellt, die die Bildränder abdunkelt (@fig:vignette-modification). Die Stärke des Effekts wird durch den Konfigurationswert `config.vignetteStrength` bestimmt.
Die Berechnung der Maske erfolgt nur einmal und wird zwischengespeichert, solange der Wert von `config.vignetteStrength` unverändert bleibt, um die Effizienz zu erhöhen. Die Maske wird dann auf die Größe des Eingabebildes skaliert und schließlich vom Bild subtrahiert, um den Vignetteneffekt zu erzeugen (@fig:vignette-output).

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
            caption: [Modifikation - Vignette],
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



