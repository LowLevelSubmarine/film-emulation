#import "../../components.typ": authored_by

== Vignette

=== Theorie 
#authored_by("")

Unterscheidung zwischen
- Mechanische oder physikalische Vignettierung 
	- Lichtstrahlen durchqueren mehrere aufeinanderfolgende Öffnungen bevor die die Bildebene erreichen 
		- Linsenränder, Blende, Objektivgehäuse, Filter, Gegenlichtblende (falsch konstruiert oder ausgerichtet)
	- physikalisische Behinderung durch eine der oben genannten Gegenstände
	- ist starke,dunkle,kreisförmige Verdunkelung, die in den Ecken am deutlichsten sichtbar ist
	- verschwindet, wenn das Objektiv abgeblendet ist (kleine Blende)
- Optische Vignettierung
	- tritt auf wenn das Licht in einem steilen Winkel auf die Objektivblende auftritt  (internes physisches Hindernis)
		- Licht wird teilweise von der Blende blockiert
	-  Effekt oft bei Weitwinkelobjektiven (mit weit geöffneter Blende)
	- durch Abblenden des Objektivs kann der Effekt eliminiert/reduziert werden
- Pixelvignettierung
	- Pixelsensor besteht aus Millionen von Photonenschächten, die das auftreffende Licht messen/aufzeichnen
	- Photonschächte sind extrem klein, haben aber eine gewisse Tiefe
	- bei einem starken Lichteinfallwinkel trifft möglicherweise das Licht nicht auf den Boden der Schächte - die stärksten Lichtwinkel finden sich an den Bildrändern
	- dieses Problem kann über Sensoralgorithmen korriegiert werden


=== Implementierung
#authored_by("")



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