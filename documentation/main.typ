#set heading(numbering: "1.")
#show raw: it => block(
  fill: rgb("#f4f4f4"),
  width: 100%,
  inset: 8pt,
  stroke: (
    left: rgb("#d3d3d3") + 3pt,
  ),
  text(fill: rgb("#131313"), it)
)

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

#bibliography("sources.yaml", title: "Quellenverzeichnis")
