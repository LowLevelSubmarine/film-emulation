#set heading(numbering: "1.")
#set par(justify: true)
#set text(lang: "de")
#show raw: it => block(
  fill: rgb("#f4f4f4"),
  width: 100%,
  inset: 8pt,
  stroke: (
    left: rgb("#d3d3d3") + 3pt,
  ),
  text(fill: rgb("#131313"), it)
)
// Disable justification for paragraphs inside code blocks
#show raw.where(block: true): set par(justify: false)

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
  fill: none,
  depth: 2,
  indent: auto,
)

#pagebreak()

#include "sections/einleitung.typ"
#include "sections/funktionsweise_analog_film.typ"
#include "sections/effekte_analog_film.typ"
#include "sections/weitere_implementierungen.typ"
#include "sections/fazit.typ"

#pagebreak()

= Quellenverzeichnis
#bibliography("sources.yaml", title: none)
