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
        Halation ist ein leuchtender Schein um helle Bereiche. Es entsteht durch Streuung von Licht in der Filmschicht (@fig:halation-theorie). Dies ist besonders sichtbar an kontrastreichen Kanten (hell-dunkel Übergänge).
        Das Licht durchquert die Emulsionsschichten und wird auf der Rückseite des Kameragehäuses reflektiert. Das Streulicht trifft dabei erneut auf die lichtempfindlichen Schichten. 
        
        Besonders betroffen ist dabei die rot-empfindliche Schicht, weshalb der Lichtschein auf dem entwickelten Bild eher rötlich erscheint. Es gibt ein paar Faktoren, die die Stärke des Effekts beeinflussen können. Eine glatte Oberfläche des Kameragehäuses reflektiert stärker, genauso erzeugt helles Licht einen stärkeren Effekt. Wenn der Film eine höhere Empfindlichkeit hat, wird der Effekt ebenso verstärkt.

        Durch eine Antihalation-Schicht kann man die Halation deutlich reduzieren. Diese ist eine dunkle Schicht auf der Rückseite des Films und absorbiert das Licht weitesgehend. Somit wird die interne Reflektion auf die lichtempfindlichen Schichten reduziert. Außerdem hilft es, wenn die Rückseite des Kameragehäuses mattiert ist.
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

// #wrap-content(
//     [
//       #pad(
//         box(width: 150pt)[
//           #figure(
//               image("../../assets/effects/halation/input.png"),
//               caption: [Beispiel Eingabebild],
//           )<fig:halation-input>
//         ],
//         left: 12pt, bottom: 12pt
//       )
//     ],
//     [
      
//     ],
//     align: right,
// )

#pad(
  [
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
        #text("Extraktion des roten Bildkanals", weight: "bold") (@fig:halation-step1)
        - Halation entsteht fast ausschließlich durch rötliches Licht
        - Implementierung durch Extraktion des roten Bildkanals
          - OpenCV: extractChannel()
        - Folgeberechnungen sind durch Beschränkung auf 1/3 der Daten weniger rechenintensiv
      ],
      align: right,
    )
    ```kt
    val redChannelImage = store { Mat() }
    Core.extractChannel(inputImage, redChannelImage, 2) // red channel isolated
    ```
  ], bottom: 12pt
)


#pad(
  [
    #wrap-content(
      [
        #pad(
          box(width: 180pt)[
            #figure(
                image("../../assets/effects/halation/step2.png"),
                caption: [Isolierung der extrem hellen Bildbereiche],
            )<fig:halation-step2>
          ],
          left: 12pt
        )
      ],
      [
        #text("Isolierung der extrem hellen Bildbereiche", weight: "bold") (@fig:halation-step2)
        - Halation betrifft nur die extrem hellen Bildbereiche, welche eine Reflexion innerhalb des Films o. Gehäuses verursachen
        - Es müssen alle Bildelemente, die nicht extrem hell sind, entfernt werden
        - Implementierung durch Gamma-Anpassung mit γ=15
          - OpenCV: LUT()
        - Andere Lösungen sind denkbar
      ],
      align: right,
    )
    ```kt
    val halationRes = 0.5
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
    ```
  ], bottom: 12pt
)

#pad(
  [
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
          #text("Weichzeichnung der isolierten Bildbereiche", weight: "bold") (@fig:halation-step3)
          - Halation zeichnet sich durch Lichthöfe um helle Bildbereiche herum aus
            - Intensität nimmt proportional zur Entfernung ab
          - Implementierung durch Weichzeichnung
            - Gauß-Filter passt am besten
              - Nicht direktional
              - Intensität nimmt weich ab
          - OpenCV: GaussianBlur
        ],
        align: right,
    )
    ```kt
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
    ```
  ], bottom: 12pt
)

#pad(
  [
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
        #text("Rückführung in einen 3-Kanal-Buffer", weight: "bold") (@fig:halation-step4)
        - Halation ist immer rötlich gefärbt
        - Implementierung durch Kopieren des bestehenden 1-Kanal-Bildes in den roten Bereich eines schwarzen 3-Kanal-Bildes
          - OpenCV: Mat.zeros()
          - OpenCV: insertChannel()
        - Passend: 3-Kanal-Buffer für Folgeschritt sowieso Voraussetzung
      ],
      align: right,
    )
    ```kt
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
    ```
  ], bottom: 12pt
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
      #text("Addition auf das Eingabebild", weight: "bold") (@fig:halation-output)
      - Halation hellt das Bild in den relevanten Regionen auf und lässt es ansonsten unberührt
      - Implementierung durch Addition auf das Original-Bild
        - Schwarze Bereiche verändern nicht das Bild, da x + 0 = x
        - OpenCV: add()
    ],
    align: right,
)
```kt
Core.add(inputImage, threeChannelImage, destinationImage)
```