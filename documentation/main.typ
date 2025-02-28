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
  #block([Leonie Wehser und Florian Weichert], above: 1.5em)
], top: 10em)

#pagebreak()

#outline(
  title: [Inhaltsverzeichnis],
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
