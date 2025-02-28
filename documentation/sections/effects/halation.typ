#import "@preview/wrap-it:0.1.1": wrap-content
#import "../../components.typ": authored_by

#pagebreak()

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
      Halation ist ein leuchtender Schein um helle Bereiche im Bild, der durch Streuung von Licht in der Filmschicht entsteht (@fig:halation-theorie). Dieser Effekt ist besonders an kontrastreichen Kanten (hell-dunkel Übergänge) sichtbar.
      Das Licht durchquert die Emulsionsschichten und wird auf der Rückseite des Kameragehäuses reflektiert, wodurch es erneut auf die lichtempfindlichen Schichten trifft.
      
      Besonders betroffen ist dabei die rot-empfindliche Schicht, weshalb der Lichtschein auf dem entwickelten Bild eher rötlich erscheint. Mehrere Faktoren können die Stärke des Effekts beeinflussen: Eine glatte Oberfläche des Kameragehäuses reflektiert stärker, helles Licht erzeugt einen intensiveren Effekt, und eine höhere Filmempfindlichkeit verstärkt die Halation ebenfalls.

      Eine Antihalation-Schicht kann die Halation deutlich reduzieren. Diese dunkle Schicht auf der Rückseite des Films absorbiert das Licht weitgehend und reduziert somit die interne Reflexion auf die lichtempfindlichen Schichten. Auch eine mattierte Rückseite des Kameragehäuses kann helfen, den Effekt zu minimieren.
    ],
    align: right,
)

=== Implementierung
Die @fig:halation-diagram zeigt den Verarbeitungsablauf zur Simulation von Halation. Der Prozess beginnt mit der Extraktion des roten Farbkanals, da Halation hauptsächlich in diesem Spektrum auftritt. Durch eine Kombination aus Hochpassfilterung und Weichzeichnung wird ein diffuses Leuchten erzeugt, das anschließend auf das Originalbild addiert wird. Dadurch entsteht ein natürlicher, filmischer Halation-Effekt.

#box(width: 100%)[
  #figure(
    image("../../assets/effects/halation/diagram.png", height: 250pt),
    caption: [Verarbeitungsablauf für die Halation],
  )<fig:halation-diagram>
]

Um Halation zu simulieren, wird ein Eingabebild benötigt, das helle Bildbereiche enthält, die den Effekt verursachen. In diesem Beispielbild sind die hellsten Bereiche die Fenster, durch die das Tageslicht ins Zimmer fällt. Dieses Bild wird in den folgenden Schritten bearbeitet, um die Halation zu simulieren.

#box(width: 100%)[
  #figure(
      image("../../assets/effects/halation/input.png"),
      caption: [Beispiel Eingabebild],
  )<fig:halation-input>
]

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
    #text("Extraktion des roten Bildkanals", weight: "bold") \ 
    Wie im Theorie-Abschnitt beschrieben, entsteht Halation hauptsächlich durch rötlich reflektiertes Licht.
    Daher wird der rote Bildkanal isoliert, indem man `extractChannel()` verwendet, wobei der rote Kanal in OpenCV der zweite Kanal ist (@fig:halation-step1). Dies hat den zusätzlichen Vorteil, dass die nachfolgenden Berechnungen weniger rechenintensiv sind, da nur ein Drittel der Daten verarbeitet werden müssen.
  ],
  align: right,
)

#text("High-Pass-Filter (Helligkeit)", weight: "bold") \
Es sind nur die extrem hellen Bildbereiche von Interesse, welche eine Reflexion innerhalb des Films oder Gehäuses verursachen.
Deshalb müssen alle Bildelemente, die nicht extrem hell sind, entfernt werden.
Dafür wurde ein Gamma-LUT (`config.halationThreshold`= γ = 20.0) mit einer starken Helligkeitskompression definiert, wodurch alle Eingabewerte sehr dunkel erscheinen, abgesehen von Werten, die in der Nähe von 255 liegen.
Dieser Lookup-Table wird mit `Core.LUT()` auf den roten Bildkanal angewendet (@fig:halation-lut).

Außerdem wird die Maske mit `Imgproc.resize()` verkleinert. Für diese sind die genauen Details im Bild nicht relevant, da im nächsten Schritt auf die Maske ein Weichzeichner angewendet wird und die Details dort ohnehin verloren gehen würden.

#grid(
    columns: (1fr, 1fr),
    align: (left, right),
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
      #text("Weichzeichnen (Gauß)", weight: "bold")\
      Ziel dieses Schrittes ist es, weiche Lichthöfe um die hellen Bildbereiche zu erzeugen.
      Dies wird durch die Anwendung des `GaussianBlur()` erreicht, da dieser nicht direktional ist und die Intensität proportional zur Entfernung weich abnimmt (@fig:halation-step3).
      In diesem Schritt können auch Anpassungen an der Kurve des Gaussian Blur mit `config.halationGaussianSize` und `config.halationSigmaX` vorgenommen werden.
      
      Anschließend wird die Helligkeit der Maske angepasst und die Maske wieder auf die Größe des Eingabebildes skaliert.
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
    #text("Umformung zu einem 3-Kanal-Buffer", weight: "bold")\
    Um die erstellte Halation-Maske zum Eingangsbild hinzufügen zu können, muss die 1-Kanal-Maske wieder in ein 3-Kanal-Bild umgewandelt werden. Dazu erstellt man zunächst mit `Mat.zeros()` ein schwarzes 3-Kanal-Bild. Anschließend wird der vorhandene rote Kanal mit der Maske durch `Core.insertChannel()` überschrieben.
  ],
  align: right,
)

#text("Addition auf das Eingabebild", weight: "bold")\
Zum Schluss wird die Halation-Maske mit `Core.add()` auf das Eingabebild addiert, um ein Bild mit simuliertem Halation-Effekt zu erzeugen (@fig:halation-output).
Dabei werden nur die relevanten Bereiche des Bildes aufgehellt, während die anderen Bereiche unverändert bleiben.
Dies liegt daran, dass die schwarzen Bereiche in der Maske den Wert 0 enthalten. Wenn ein Pixelwert x aus dem Eingabebild mit 0 addiert wird, bleibt dieser unverändert.

Am Ende erhält man ein Bild, das die Halation simuliert. Die hellsten Bereiche des Bildes sind nun von einem leichten rötlichen Schimmer umgeben, der den Effekt der Lichtstreuung in der Filmschicht nachahmt.

#box(width: 100%)[
  #figure(
      image("../../assets/effects/halation/output.png"),
      caption: [Beispiel Ausgabebild mit Halation],
  )<fig:halation-output>
]

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