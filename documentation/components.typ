#let authored_by(name) = block()[
  _Geschrieben von #(name)_
]

#let input_output_figures(effect_name, output_source) = {
  let height = 180pt
  grid(
    columns: (1fr, 1fr),
    gutter: 20pt,
    [#figure(
        image("/assets/effects/input.png", height: height),
        caption: [Eingabebild – #effect_name],
    )],
    [#figure(
        image(output_source, height: height),
        caption: [Ausgabebild – #effect_name],
    )],
)
}
