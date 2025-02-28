= Fazit
== Zusammenfassung
Die Ziele der Arbeit wurden erreicht. Es konnte eine glaubwürdige Emulation eines Analog-Films in Echtzeit umgesetzt werden. Die Aspekte Vignettierung, Halation, Grain, Farbstich, Kratzer, Staub, Gate Weave, Crushed Luminance und Farbanpassungen wurden implementiert. Es gibt keinen Effekt, der nicht umgesetzt werden konnte. Die Parameter der Effekte sind einfach in Echtzeit anpassbar, um ihre Auswirkungen sichtbar zu machen. Die Bearbeitung geschieht in Echtzeit ohne Frame-Drops.

== Ausblick
Obwohl schon einige Optimierungen vorgenommen wurden, besteht noch viel Potenzial zur Verbesserung der Performance. Die Implementierung könnte auf eine hardwarenähere Sprache portiert werden, um die Effizienz zu steigern. Auch die Implementierung der Effekte in einer Shader-Sprache könnte die Performance verbessern. Interessant wäre auch, die Effekte eher zu simulieren als zu emulieren, um die künstlerische Freiheit zu erhöhen. Beispielsweise könnten die Grain-Körner einzeln simuliert werden, um so verschiedene Körnungen zu erzeugen. Dies wäre jedoch mit einem erhöhten Rechenaufwand verbunden und mutmaßlich nicht in Echtzeit umsetzbar.

== Anwendungsbereiche
Aufgrund der Echtzeitfähigkeit der Effekte eignet sich die Implementierung für die Anwendung in der Live-Produktion von Bewegtbildern. Auch in Videospielen könnten die Effekte eingesetzt werden, jedoch wäre dafür eine Implementierung in einer hardwarenäheren Sprache sinnvoll, um die Effizienz für diesen Anwendungsfall zu steigern. Zusätzlich könnte die Implementierung aufgrund ihres Fokus auf die Performance in abgewandelter Form sinnvoll für die Postproduktion auf schwächerer Hardware eingesetzt werden, beispielsweise in der Bearbeitung von Videos auf dem Smartphone.
