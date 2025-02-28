#import "@preview/wrap-it:0.1.1": wrap-content
#import "../../components.typ": authored_by

== Farbstich
#authored_by("Leonie Wehser")

=== Theorie
Analoge Farbfilme werden durch chemische Reaktionen verarbeitet, dabei kann es aus verschiedenen Gründen zu Farbstichen kommen. 
Zum Einen können die Farbstoffe mit dem Alter verblassen, wobei die 3 Farbschichten je nach Zusammensetzung unterschiedlich schnell verblassen. Dadurch können bei älteren Filmen oder Abzügen ein Rot-, Blau-, oder Grünstich entstehen.
Wenn die Filme oder Abzüge bei hohen Temperaturen oder Luftfeuchtigkeit gelagert werden, beschleunigt dies die chemischen Reaktionen. Außerdem kann UV-Licht die Farben verändern, besonders bei Dieas und Farbnegativen.
Bei falscher Belichtungszeit können auch Farbstiche entstehen. Bei Unterbelichtung kann es zu einem Blaustich kommen, bei Überbelichtung hingegen zu einem Gelbstich. Genauso können bei der Entwicklung Fehler auftreten, durch ungenaue Temperatur oder falsche Chemiekonzentrationen.
Zu guter Letzt kann auch der Scanner einen eigenen Farbstich hinzufügen, genauso kann bei dem Drucker ein falsches Farbprofie eingestellt sein oder es kann zu Tintenschwankungen kommen. Ungewollte Graustufenanpassungen verfälschen Tiefen und Höhen.
Man kann Farbstiche korrigieren, indem man den ursprünglichen Farbeindruck wiederherstellt, entweder manuell oder softwaregestützt.

#wrap-content(
    [
      #pad(box(width: 160pt)[
        #figure(
            image("../../assets/effects/input.png", width: 100%),
            caption: [Beispiel Eingabebild],
        )<fig:grain-input>
        #figure(
            image("../../assets/effects/color_cast/modification.png", width: 100%),
            caption: [Color Cast Maske],
        )<fig:grain-modification>
        #figure(
            image("../../assets/effects/color_cast/output.png", width: 100%),
            caption: [Ausgabebild für Color Cast],
        )<fig:grain-output>
      ], left: 12pt, bottom: 12pt)
    ],
    [
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
        fun ProcessingDsl.colorCast(
            image: Mat, config: Config
        ) {
            Core.add(
                image, 
                config.colorCast.toScalar(), 
                image
            )
        }   
        ```
     ],
  align: right,
)
