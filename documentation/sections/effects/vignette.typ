#import "../../components.typ": authored_by

== Vignette
#authored_by("Leonie Wehser")

=== Theorie 
Unterscheidung zwischen
- Mechanische oder physikalische Vignettierung 
	- Lichtstrahlen durchqueren mehrere aufeinanderfolgende Öffnungen bevor die die Bildebene erreichen 
		- Linsenränder, Blende, Objektivgehäuse, Filter, Gegenlichtblende (falsch konstruiert oder ausgerichtet)
	- physikalisische Behinderung durch eine der oben genannten Gegenstände
	- ist starke,dunkle,kreisförmige Verdunkelung, die in den Ecken am deutlichsten sichtbar ist
	- verschwindet, wenn das Objektiv abgeblendet ist (kleine Blende)

  - Mehrere aufeinanderfolgende Öffnungen
  - Hindernisse: Linsenränder, Blende, Objektivgehäuse, Filter, Gegenlichtblende
  - Physikalische Blockade -> Lichtabschwächung in Bildecken
  - Charakteristisch: starke, dunkle, kreisförmige Abdunklung in Ecken
  - Reduktion durch Abblenden (kleinere Blendenöffnung)
- Optische Vignettierung
	- tritt auf wenn das Licht in einem steilen Winkel auf die Objektivblende auftritt  (internes physisches Hindernis)
		- Licht wird teilweise von der Blende blockiert
	-  Effekt oft bei Weitwinkelobjektiven (mit weit geöffneter Blende)
	- durch Abblenden des Objektivs kann der Effekt eliminiert/reduziert werden
	- Steiler Lichteinfall auf Objektivblende
  - Teilweise Blockierung durch interne Objektivelemente
  - Besonders bei Weitwinkelobjektiven mit großer Blendenöffnung
  - Reduktion durch Abblenden
- Pixelvignettierung
  - Ursache: Pixel-Sensoraufbau
  - Sensor mit Millionen von Photonenschächten
  - Kleine, tiefe Photonenschächte
  - Bei starkem Lichteinfallswinkel kein vollständiger Lichteinfall
  - Besonders an Bildrändern ausgeprägt
  - Korrektur durch Sensoralgorithmen

=== Implementierung

- Ziel der Implementierung
  - Erstellung einer Vignettenmaske mit einstellbarer Stärke
  - Anwendung zur Bildabdunklung
  - Nutzung von OpenCV für Effizienz

- Funktion `vignette(image: Mat, config: Config)`
  - Berechnung einer Maske basierend auf `config.vignetteStrength`
  - Generierung aus Bildabmessungen
  - Abdunklung durch Subtraktion der Maske
  - OpenCV: `Core.subtract(image, mask, image)`
  - Implementierung in Kotlin (Teil der `ProcessingDsl`)

- Vorteile
  - Effiziente Berechnung durch gespeicherte Maske (`stored`)
  - Anpassbare Stärke (`config.vignetteStrength`)
  - Reduzierte Berechnungskosten durch Wiederverwendung
  - Direkte Bildmanipulation ohne zusätzliche Kopien
  - OpenCV für hohe Performance

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