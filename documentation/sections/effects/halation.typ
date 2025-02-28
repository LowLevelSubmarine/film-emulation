#import "@preview/wrap-it:0.1.1": wrap-content
#import "../../components.typ": authored_by

== Halation
#authored_by("Leonie Wehser")

=== Theorie
#wrap-content(
    [
      #pad(box(width: 180pt)[
        #figure(
            image("../../assets/effects/halation/theorie.png"),
            caption: [Darstellung des \ einfallenden
           Lichts auf einen Farbfilm],
        )<fig:halation-theorie>
        #figure(
            image("../../assets/effects/halation/example.jpg"),
            caption: [Beispielbild für Halation @halation-example-image ],
        )<fig:halation-example>
      ], left: 12pt, bottom: 12pt)
    ],
    [
      Halation ist ein leuchtender Schein um helle Bereiche im Bild, der durch Streuung von Licht in der Filmschicht entsteht (@fig:halation-theorie). Dieser Effekt tritt besonders an kontrastreichen Kanten (hell-dunkel Übergänge) auf.
      Das Licht durchquert die Emulsionsschichten und wird auf der Rückseite des Kameragehäuses reflektiert, wodurch es erneut auf die lichtempfindlichen Schichten trifft.
      
      Besonders betroffen ist dabei die rot-empfindliche Schicht, weshalb der Lichtschein auf dem entwickelten Bild eher rötlich erscheint. Mehrere Faktoren können die Stärke des Effekts beeinflussen: Eine glatte Oberfläche des Kameragehäuses reflektiert stärker, helles Licht erzeugt einen intensiveren Effekt, und eine höhere Filmempfindlichkeit verstärkt die Halation ebenfalls.

      Eine Antihalation-Schicht kann die Halation deutlich reduzieren. Diese dunkle Schicht auf der Rückseite des Films absorbiert das Licht weitgehend und reduziert somit die interne Reflexion auf die lichtempfindlichen Schichten. Auch eine mattierte Rückseite des Kameragehäuses kann helfen, den Effekt zu minimieren.
    ],
    align: right,
)

=== Implementierung
#figure(
  image("../../assets/effects/halation/diagram.png",
      height: 250pt),
  caption: [Implementierungsablauf für die Halation],
)<fig:halation-diagram>

 #figure(
      image("../../assets/effects/halation/input.png"),
      caption: [Beispiel Eingabebild],
  )<fig:halation-input>

#wrap-content(
  [
    #pad(
      box(width: 180pt)[
        #figure(
            image("../../assets/effects/halation/step1.png"),
            caption: [Extraktion des roten Bildkanals],
        )<fig:halation-step1>
      ],
      left: 12pt
    )
  ],
  [
    #text("Extraktion des roten Bildkanals", weight: "bold") 

    Wie in dem Theorie-Abschnitt festgehalten, entsteht Halation fast ausschließlich durch rötlich reflektiertes Licht.
    Deshalb isoliert man mithilfe von `extractChannel()` der rote Bildkanal, welcher in OpenCV der zweite Kanal ist (@fig:halation-step1). Dies hat einen weiteren Vorteil, denn dadurch sind die Folgeberechnungen weniger rechenintensiv, da man sich auf 1/3 der Daten beschränkt.
  ],
  align: right,
)

 #text("Isolierung der extrem hellen Bildbereiche", weight: "bold") 
    
Es sind nur die extrem hellen Bildbereiche von Interesse, welche eine Reflexion innerhalb des Films oder Gehäuses verursachen.
Deshalb müssen alle Bildelemente, die nicht extrem hell sind, entfernt werden.
Dafür wurde ein Gamma-LUT (`config.halationThreshold`= γ = 20.0) mit einer starken Helligkeitskompression definiert, wodurch alle Eingabewerte sehr dunkel erscheinen abgesehen von Werte, die in der Nähe von 255 liegen.
Dieser Lookup-Table wird noch mit `Core.LUT()` auf den roten Bildkanal angewendet (@fig:halation-lut).

Außerdem wird die Maske mit `Imgproc.resize()` verkleinert. Für diese sind die genauen Details im Bild nicht relevant, da im nächsten Schritt auf die Maske ein Weichzeicher angewendet wird und die Details dort ohnehin verloren gehen würden.

#grid(
    columns: (1fr, 1fr),
    gutter: 93pt,
    [
      #box(width: 180pt)[
        #figure(
            image("../../assets/effects/halation/lut.png", height: 110pt),
            caption: [Gamma-Lookup-Table (γ = 20.0)]
        )<fig:halation-lut>
      ]
    ],
    [
      #box(width: 180pt)[#figure(
            image("../../assets/effects/halation/step2.png", height: 110pt),
            caption: [Isolierung der extrem hellen Bildbereiche],
        )<fig:halation-step2>
      ]
    ]
)

#wrap-content(
    [
      #pad(
        box(width: 180pt)[
          #figure(
              image("../../assets/effects/halation/step3.png"),
              caption: [Weichzeichnung der isolierten Bildbereiche],
          )<fig:halation-step3>
        ],
        left: 12pt
      )
    ],
    [
      #text("Weichzeichnung der isolierten Bildbereiche", weight: "bold")

      Ziel der Funktion ist es weiche Lichthöfe um die hellen Bildbereich herum zu erstellen.
      Dies konnte durch Implementierung des `GaussionBlur()` realisiert werden, da dieser nicht direktional ist und die Intensität weich proportional zur Entfernung abnimmt(@fig:halation-step3).
      In diesem Schritt können auch noch mit `config.halationGaussianSize` und `config.halationSigmaX` Änderungen an der Kurve des Gaussian Blur vorgenommen werden.
      
      Anschließend wird die Helligkeit der Maske angepasst und die Maske wieder zurück auf die Größe des Eingabebildes skaliert.
    ],
    align: right,
)

#wrap-content(
  [
    #pad(
      box(width: 180pt)[
        #figure(
            image("../../assets/effects/halation/step4.png"),
            caption: [Rückführung in einen 3-Kanal-Buffer],
        )<fig:halation-step4>
      ],
      left: 12pt
    )
  ],
  [
    #text("Rückführung in einen 3-Kanal-Buffer", weight: "bold")

    Um am Ende die erstellte Halation-Maske zum Eingangsbild hinzufügen zu können, muss die 1-Kanal-Maske wieder in ein 3-Kanal-Bild umgewandelt werden. Dafür erstellt man zunächst mit `Mat.zeros()`ein schwarzes 3-Kanal-Bild. Durch `Core.insertChannel()` kann man nun den vorhandenen roten Kanal mit der Maske überschreiben.
  ],
  align: right,
)

#wrap-content(
    [
      #pad(
        box(width: 180pt)[
          #figure(
              image("../../assets/effects/halation/output.png"),
              caption: [Addition auf das Eingabebild],
          )<fig:halation-output>
        ],
        left: 12pt
      )
    ],
    [
      #text("Addition auf das Eingabebild", weight: "bold")

      Zuletzt addiert man mit `Core.add()` die Maske auf das Eingabebild und erhält ein Bild mit künstlich erzeugter Halation, die die analoge Halation simulieren soll (@fig:halation-output). 
      Das Bild wird nur in den relevanten Regionen aufgehellt und lässt es ansonsten unberührt.
      Dies liegt daran, dass die schwarzen Bereiche in der Maske den Wert 0 enthalten. Addiert man einen Pixelwert x aus dem Eingabebild mit 0, so verändert sich dieser nicht.
    ],
    align: right,
)

```kt
fun ProcessingDsl.halation(
  inputImage: Mat, 
  destinationImage: Mat, 
  config: Config
) {
  val halationRes = 0.5
  val redChannelImage = store { Mat() }
  Core.extractChannel(inputImage, redChannelImage, 2) // red channel isolated
  val gammaLut = store(listOf(config.halationThreshold)) { 
    createGammaLUT(config.halationThreshold.toDouble()) 
  }
  Imgproc.resize(
    redChannelImage, 
    redChannelImage, 
    Size(), 
    halationRes, 
    halationRes, 
    Imgproc.INTER_LINEAR
  )
  Core.LUT(redChannelImage, gammaLut, redChannelImage)
  measureTime("halation: gaussian blur") {
      GaussianBlur(
          redChannelImage,
          redChannelImage,
          config.halationGaussianSize.toSize().map { 
            (it * halationRes).roundToInt().odd().toDouble() 
          },
          config.halationSigmaX.toDouble()
      ) // blurred red channel
  }
  adjustLuminance(
    redChannelImage, 
    redChannelImage, 
    brightness = config.halationStrength.toDouble()
  )
  Imgproc.resize(
    redChannelImage, 
    redChannelImage, 
    Size(), 
    1.0 / halationRes, 
    1.0 / halationRes, 
    Imgproc.INTER_LINEAR
  )
  val threeChannelImage by stored { 
    Mat.zeros(inputImage.size(), CV_8UC3) 
  }  // black image with 3 channels
  Core.insertChannel(redChannelImage, threeChannelImage, 2)
  Core.add(inputImage, threeChannelImage, destinationImage)
}
```