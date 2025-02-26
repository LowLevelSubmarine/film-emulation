#import "../../components.typ": authored_by

== Color Cast
#authored_by("Leonie Wehser")

=== Theorie
- Unterschied zwischen Film-Chemie und menschlichem Sehen:
    - Film-Chemie: Farben durch chemische Reaktionen verarbeitet.
    - Menschliches Auge: Photorezeptoren (Zapfen) reagieren auf RGB-Wellenlängen.
    - Unterschiede in der Farbwahrnehmung zwischen Auge und Filmmaterial.
- Fehlerquellen bei der Digitalisierung von Film:
    - Falsche Scan-Einstellungen verursachen Farbabweichungen.
    - Farbstiche (Color Casts) entstehen durch dominante Farben.
    - Ungewollte Graustufenanpassungen verfälschen Tiefen und Höhen.
- Bedeutung der Farbkorrektur:
    - Notwendig zur Wiederherstellung des ursprünglichen Farbeindrucks.
    - Manuelle oder softwaregestützte Korrektur möglich.
    - Wichtig für authentische digitale Filmaufnahmen.

=== Implementierung
- Ziel der Implementierung:
    - Simulation oder Kompensation eines Farbstichs.
    - Flexible Anpassung durch Konfigurationswerte.
    - Grundlage für automatisierte Farbkorrektur.
- Beschreibung der Funktion colorCast in Kotlin:
    - Eingabe: Bild (Mat) und Konfiguration (Config).
    - Nutzung von Core.add(image, config.colorCast.toScalar(), image) für Farbanpassungen.
    - Umwandlung der Konfigurationsfarbe in OpenCV-Scalar-Format.
    - Ergebnis: Anpassung aller Pixel um die definierten Farbwerte.
- Vorteile der Implementierung:
    - Effiziente Anwendung durch OpenCV.
    - Anpassbarkeit durch Konfigurationswerte.
    - Ermöglicht automatisierte Farbkorrekturen.
```kotlin
fun ProcessingDsl.colorCast(image: Mat, config: Config) {
    Core.add(image, config.colorCast.toScalar(), image)
}
```