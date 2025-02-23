#import "../../components.typ": authored_by

== Color Cast
#authored_by("Leonie Wehser")

=== Theorie 
- Die Film-Chemie verarbeitet die Farben grundlegend anders als das menschliche Auge
- Falsche Einstellungen im Scan-Vorgang können Farbstiche und graue Tiefen oder Höhen verursachen

=== Implementierung
```kotlin
fun ProcessingDsl.colorCast(image: Mat, config: Config) {
    Core.add(image, config.colorCast.toScalar(), image)
}
```