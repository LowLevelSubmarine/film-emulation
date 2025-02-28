#set heading(numbering: "1.")
#set par(justify: true)
#set text(lang: "de")
#set page(numbering: "1 / 1")
#show raw.where(block: true): (it) => {
  set par(justify: false)
  block(
    fill: rgb("#f4f4f4"),
    width: 100%,
    inset: 8pt,
    stroke: (
      left: rgb("#d3d3d3") + 3pt,
    ),
    text(fill: rgb("#131313"), it)
  )
}
#set outline.entry(fill: none)

#pad([
  #block([
    #text([Analoge Filmemulation in Echtzeit],
        size: 22pt, weight: "bold")
  ])
  #block([
    *Spezialgebiete der Bildtechnik* \
    WS 2024/25 \
    Leonie Wehser 852904 und Florian Weichert 871104 \
    
  ], above: 1.5em)
  #block([
    Betreut von: \
    Prof. Dr.-Ing. Thomas Bonse \
    B. Eng. Leonie Schuberth \
    28.02.2025
  ], above: 43em)
], top: 10em)

#pagebreak()

= Eidesstaatliche Erklärung

#v(1em)

Ich, Leonie Wehser 852904, versichere an Eides statt durch meine Unterschrift, dass ich die vorstehende Arbeit selbständig und ohne fremde Hilfe angefertigt und alle Stellen, die ich wörtlich oder sinngemäß aus veröffentlichten oder nicht veröffentlichten Schriften entnommen habe, als solche kenntlich gemacht habe und mich auch keiner anderen als der angegebenen Quellen oder sonstiger Hilfsmittel bedient habe. Ich versichere an Eides statt, dass ich die vorgenannten Angaben nach bestem Wissen und Gewissen gemacht habe und dass die Angaben der Wahrheit entsprechen und ich nichts verschwiegen habe.

Unterschrift: #line(length: 100%, stroke: 0.05em)

#v(2em)

Ich, Florian Weichert 871104, versichere an Eides statt durch meine Unterschrift, dass ich die vorstehende Arbeit selbständig und ohne fremde Hilfe angefertigt und alle Stellen, die ich wörtlich oder sinngemäß aus veröffentlichten oder nicht veröffentlichten Schriften entnommen habe, als solche kenntlich gemacht habe und mich auch keiner anderen als der angegebenen Quellen oder sonstiger Hilfsmittel bedient habe. Ich versichere an Eides statt, dass ich die vorgenannten Angaben nach bestem Wissen und Gewissen gemacht habe und dass die Angaben der Wahrheit entsprechen und ich nichts verschwiegen habe.

Unterschrift: #line(length: 100%, stroke: 0.05em)

#pagebreak()

#include "sections/kurzfassung.typ"

#pagebreak()

= Inhaltsverzeichnis

#outline(
  title: none,
  depth: 2,
  indent: auto,
)


#pagebreak()
#include "sections/einleitung.typ"
#pagebreak()
#include "sections/funktionsweise_analog_film.typ"
#pagebreak()
#include "sections/effekte_analog_film.typ"
#pagebreak()
#include "sections/weitere_implementierungen.typ"
#pagebreak()
#include "sections/fazit.typ"
#pagebreak()

= Quellenverzeichnis
#bibliography("sources.yaml", title: none)
