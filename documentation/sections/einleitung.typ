= Einleitung
== Vorstellung
Diese Arbeit beschäftigt sich mit der Implementierung von Effekten in der digitalen Bildverarbeitung. Es soll gezeigt werden, wie einzelne Aspekte des Analog-Films digital emuliert werden können.

== Ziele
Das Primärziel ist eine glaubwürdige Emulation eines Analog-Film in Echtzeit. Dafür sollen die Aspekte Vignettiertung, Halation, Grain, Farbstich, Kratzer, Staub, Gate Weave, Crushed Luminance und Farbanpassungen umgesetzt werden. Zusätzlich sollen die Parameter der Effekte einfach in Echzeit anpassbar sein, um ihre Auswirkungen sichtbar zu machen.

== Vorgehensweise
Die Implementierung der Effekte erfolgt in der hohen Programmiersprache Kotlin. Die Bibliothek OpenCV wird verwendet, um die Bildverarbeitung hardwarenah zu realisieren. Die Effekte werden in einer Pipeline nacheinander auf das Bild angewendet. Zur Verbesserung der Performance, werden statische Werte, die wiederholt berechnet werden müssten, in einem Cache gespeichert.

== Aufbau
Da die Theorie und die Implementierung der Effekte thematisch nah beieinander sind, werden diese jeweils in einem Abschnitt zusammengefasst, anstatt zunächst allgemein die Theorie und anschließend die Implementierung zu beschreiben. In den Theorie-Abschnitten wird der Effekt beschrieben und wie dieser typischerweise entsteht. In der Implementierung wird gezeigt, wie der Effekt umgesetzt wurde. Im Anschluss an die einzelnen Effekte wird auf die Performance eingegangen und beschrieben wie das User-Interface umgesetzt wurde.
