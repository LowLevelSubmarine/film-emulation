#import "@preview/wrap-it:0.1.1": wrap-content
#import "../../components.typ": authored_by

== Vignette
#authored_by("Leonie Wehser")

=== Theorie 
Vignettierung beschreibt die Abschattung zum Bildrand hin.
Es gibt verschiedene Arten, wodurch Vignettierung auftreten kann.
Eine wäre die mechanische oder physikalische Vignettierung.
Hierbei durchqueren die Lichtstrahlen mehrere aufeinander folgende Öffnungen (von dem Objektivgehäuse, der Blende und der Linsenränder etc.), bevor diese die Bildebene erreichen. Durch eine physikalische Behinderung beim Durchqueren der obengenannten Öffnungen tritt eine starke, dunkle, kreisförmige Verdunkelung auf, welche in den Ecken am deutlichsten sichtbar ist. Um den Effekt zu mindern, hilft es das Objektiv abzublenden. 
Es gibt außerdem eine optische Vignettierung. Diese tritt auf, wenn das Licht in einem steilen Winkel auf die Objektivblende auftritt. Es entsteht ein internes physisches Hindernis, da das Licht teilweise von der Blende blockiert wird. Der Effekt tritt besonders oft bei Weitwinkelobjektiven mit großer Blendenöffnung auf. Durch Abblenden des Objektivs kann der Effekt wieder reduziert oder sogar eliminiert werden.
Als Letztes gibt es da noch die Pixelvignettierung. Ein Pixelsensor besthet aus Millionen von Photonenschächte, die das auftreffende Licht messen. Diese Schächte sind extrem klein, haben aber eine gewisse Tiefe. Bei einem starken Lichteinfall trifft das Licht möglicherweise nicht den Boden. Besonders ausgeprägt ist der Effekt wieder an den Bildrändern. Man kann den Effekt durch bestimmte Sensoralgorithmen korrigieren.

#wrap-content(
    [
      #pad(box(width: 160pt)[
        #figure(
            image("../../assets/effects/input.png", width: 100%),
            caption: [Beispiel Eingabebild],
        )<fig:grain-input>
        #figure(
            image("../../assets/effects/vignette/modification.png", width: 100%),
            caption: [Vignette-Modifikation],
        )<fig:grain-modification>
        #figure(
            image("../../assets/effects/vignette/output.png", width: 100%),
            caption: [Ausgabebild für Vignette],
        )<fig:grain-output>
      ], left: 12pt, bottom: 12pt)
    ],
    [
      === Implementierung
		#text("Ziel der Implementierung:", weight: "semibold") 
		- Erstellung einer Vignettenmaske mit einstellbarer Stärke
		- Anwendung zur Bildabdunklung
		- Nutzung von OpenCV für Effizienz

		- Funktion vignette(image: Mat, config: Config):
		- Berechnung einer Maske basierend auf config.vignetteStrength
		- Generierung aus Bildabmessungen
		- Abdunklung durch Subtraktion der Maske
		- OpenCV: Core.subtract(image, mask, image)
		- Implementierung in Kotlin (Teil der ProcessingDsl)

		- Vorteile
		- Effiziente Berechnung durch gespeicherte Maske (stored)
		- Anpassbare Stärke (config.vignetteStrength)
		- Reduzierte Berechnungskosten durch Wiederverwendung
		- Direkte Bildmanipulation ohne zusätzliche Kopien
		- OpenCV für hohe Performance
	],
  align: right,
)

```kotlin
fun ProcessingDsl.vignette(image: Mat, config: Config) {
    val mask by stored(dependencies = listOf(config.vignetteStrength)) {
        createVignetteMask(
            config.vignetteStrength.toDouble(),
            image.size()
        )
    }
    Core.subtract(image, mask, image)
}
```