#import "@preview/wrap-it:0.1.1": wrap-content
#import "../../components.typ": authored_by

== Farbstich
#authored_by("Leonie Wehser")

=== Theorie
Analoge Farbfilme werden durch chemische Reaktionen verarbeitet, wobei es aus verschiedenen Gründen zu Farbstichen kommen kann. Zum einen können die Farbstoffe mit der Zeit verblassen, wobei die drei Farbschichten je nach Zusammensetzung unterschiedlich schnell verblassen. Dadurch können bei älteren Filmen oder Abzügen Rot-, Blau- oder Grünstiche entstehen.

Wenn die Filme oder Abzüge bei hohen Temperaturen oder hoher Luftfeuchtigkeit gelagert werden, beschleunigt dies die chemischen Reaktionen. Außerdem kann UV-Licht die Farben verändern, besonders bei Dias und Farbnegativen. 

Auch falsche Belichtungszeiten können Farbstiche verursachen. Bei Unterbelichtung kann es zu einem Blaustich kommen, bei Überbelichtung hingegen zu einem Gelbstich. Ebenso können bei der Entwicklung Fehler auftreten, etwa durch ungenaue Temperaturen oder falsche Chemiekonzentrationen.

Zu guter Letzt kann auch der Scanner einen eigenen Farbstich hinzufügen, ebenso wie ein Drucker, wenn ein falsches Farbprofil eingestellt ist oder es zu Tintenschwankungen kommt. Ungewollte Graustufenanpassungen verfälschen zudem Tiefen und Höhen.

Farbstiche können korrigiert werden, indem der ursprüngliche Farbeindruck wiederhergestellt wird, entweder manuell oder softwaregestützt.

=== Implementierung
Die Funktion `colorCast` simuliert oder kompensiert einen globalen Farbstich. Durch den Konfigurationswert `config.colorCast` kann die Anpassung flexibel gesteuert werden. Der Wert wird mittels `Core.add(image, config.colorCast.toScalar(), image)` auf alle Pixel des Bildes angewendet (@fig:color_cast-output).
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

#grid(
  columns: (1fr, 1fr, 1fr),
  align: (left, center, right),
  [
    #box(width: 145pt)[
      #figure(
            image("../../assets/effects/input.png", width: 100%),
            caption: [Eingabebild - Color Cast],
        )<fig:color_cast-input>
    ] ],
  [
    #box(width: 145pt)[
       #figure(
            image("../../assets/effects/color_cast/modification.png", width: 100%),
            caption: [Modifikation - Color Cast],
        )<fig:color_cast-modification>
    ]],
    [
    #box(width: 145pt)[
      #figure(
            image("../../assets/effects/color_cast/output.png", width: 100%),
            caption: [Ausgabebild - Color Cast],
        )<fig:color_cast-output>
    ]
  ]
)
