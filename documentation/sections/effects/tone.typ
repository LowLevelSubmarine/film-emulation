#import "../../components.typ": authored_by

== Tone
#authored_by("Florian Weichert")

=== Theorie
Beim Abgleich der Analog-Bilder (beispielhaft @fig:tone-example-digital) mit den parallel geschossenen Digital-Bildern (@fig:tone-example-analog) lässt sich feststellen, dass Analog-Bilder unterschiedliche Farbtöne verschieden stark betonen. So werden in den für dieses Projekt geschossenen Bildern kältere Farbtone mit einem Purpur-Stich und wärmere Farbtöne mit einem Orange-Stich betont.
#grid(
    columns: (1fr, 1fr),
    gutter: 20pt,
    [#figure(
        image("../../assets/effects/tone/example-digital.png",),
        caption: [Beispiel Digital-Bild mit "realistischen" Farben],
    )<fig:tone-example-digital>],
    [#figure(
        image("../../assets/effects/tone/example-analog.jpg",),
        caption: [Beispiel Analog-Bild],
    )<fig:tone-example-analog>],
)

=== Implementierung
Um unterschiedliche Farbtöne eines Bildes getrennt von einander anzupassen ist es zunächst sinnvoll das Bild in einen Farbraum zu konvertieren, in dem die Farbtöne auf einen einzigen Wert abgebildet werden (z.B. HSV, Farbton ist "Hue"). So können die Farbtöne nach einem Mapping durch ein LUT als Maske für weitere Verarbeitungen verwendet werden (@fig:tone-effect-hue-filter). In diesem Fall wird eine Maske für orange Farbtöne erstellt.

#figure(
        image("../../assets/hue-filter.png",),
        caption: [Abbildung der Farbton-Werte auf Intensitätswerte einer Maske für warme Farbtöne],
    )<fig:tone-effect-hue-filter>

Um die Farbtöne schlussendlich ohne auffällige Artefakte verändern zu können, muss zunächst sichergestellt werden, dass intensivere Farben mit höherer Sättigung ("Saturation") und Luminanz ("Value") auch entsprechend intensiver verfärbt werden. Dafür wird die Maske je für orange Farbtöne mit dem Sättigungs- und Luminanz-Kanal multipliziert. In einem kleinen Zwischenritt wird nun die enstandene Maske in Kontrast und Helligkeit für die Feinabstimmung der Intensität angepasst. Anschließend wird die Maske in einen 3-Kanal-Buffer kopiert, da die weiteren Schritte mit Farben arbeiten. Außerdem wird eine invertierte Kopie der Maske erstellt, um auch die kälteren Farbtöne getrennt anpassen zu können. Im letzen Schritt werden die Farben des Bildes anhand der Masken angepasst. Dazu wird das Eingabebild zunächst mit den jeweiligen Masken multipliziert um nur die Werte zu erhalten die angepasst werden sollen. Die Anpassung selbt geschieht durch eine Multiplikation der nun entstandenen Buffer mit den jeweiligen Farbtönen. Zurückgegeben wird schließlich die Summe der beiden Buffer und des Eingabebildes.

```kotlin
fun ProcessingDsl.tone(image: Mat, config: Config) {
    val hsv by stored { Mat() }
    val hue by stored { Mat() }
    val sat by stored { Mat() }
    val lum by stored { Mat() }
    val orangeTonesMask by stored { Mat() }
    Imgproc.cvtColor(image, hsv, Imgproc.COLOR_BGR2HSV)
    Core.extractChannel(hsv, hue, 0)
    Core.extractChannel(hsv, sat, 1)
    Core.extractChannel(hsv, lum, 2)
    Core.multiply(hue, Scalar.all(255.0 / 179.0), hue)
    val orangeRangeLut by stored {
        createLinearLUT(
            listOf(
                Knot(0.2f, 1.0f),
                Knot(0.3f, 0.0f),
                Knot(0.9f, 0.0f),
                Knot(1.0f, 1.0f),
            )
        )
    }
    Core.LUT(hue, orangeRangeLut, orangeTonesMask)
    Core.multiply(orangeTonesMask, sat, orangeTonesMask, 1.0 / 255.0 * 1)
    Core.multiply(orangeTonesMask, lum, orangeTonesMask, 1.0 / 255.0 * 2.0)
    adjustLuminance(
      orangeTonesMask, 
      orangeTonesMask, 
      contrast = 2.0, 
      brightness = 1.5
      )
    val orangeTonesMask3C by stored { Mat() }
    Core.merge(
      listOf(orangeTonesMask, orangeTonesMask, orangeTonesMask), 
      orangeTonesMask3C
    )
    val orangeTonesMask3CI by stored { Mat() }
    Core.absdiff(orangeTonesMask3C, Scalar.all(255.0), orangeTonesMask3CI)
    val warmColor by stored(listOf(config.warmColorCast)) {
        val mat = Mat.zeros(image.size(), CvType.CV_8UC3)
        mat.setTo(config.warmColorCast.toScalar())
        mat
    }
    val warmColorPart by stored { Mat() }
    Core.multiply(warmColor, orangeTonesMask3C, warmColorPart, 1.0 / 255.0)
    val coldColor by stored(listOf(config.coldColorCast)) {
        val mat = Mat.zeros(image.size(), CvType.CV_8UC3)
        mat.setTo(config.coldColorCast.toScalar())
        mat
    }
    val coldColorPart by stored { Mat() }
    Core.multiply(coldColor, orangeTonesMask3CI, coldColorPart, 1.0 / 255.0)
    Core.add(image, warmColorPart, image)
    Core.add(image, coldColorPart, image)
}
```