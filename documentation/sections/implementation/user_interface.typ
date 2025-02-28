#import "../../components.typ": authored_by

// prevent breaks
#box[
== User Interface
#authored_by("Leonie Wehser")

Die Frontend-Anwendung basiert auf `Preact` und besteht aus mehreren Komponenten. In `App` werden `ConfigUi` und `VideoStream` gerendert. 
Die Komponente `ConfigUi` dient der Verwaltung der Konfigurationseinstellungen. Intial werden alle Werte mit `getConfig()` aus dem Backend geladen. In useState werden die aktuellen Werte im Frontend zwischengespeichert und Änderungen mit `postConfigDebounced()` an das Backend zurück gesendet. 
Zur Performance-Optimierung wird nur alle 300ms eine Änderung rausgesendet, so dass die Zwischenwerte beim Verschieben des Sliders nicht auch versendet werden. So können unnötige Neuberechnungen vermieden werden.
Die Konfigurationseinstellungen können mithilfe des `ConfigSliders` vom User geändert werden.
Angepasst werden können folgende Parameter: 
  - Grain-Strength: Stärke des Grain-Effekts
  - Dust-Strength: Stärke des Dust-Effekts
  - Vignette-Strength: Stärke des Vignetten-Effekts
  - Color-Cast: Farbverschiebungen in RGB-Kanälen
  - Warm-Color-Cast: Steuerung warmer Bildbereiche
  - Cold-Color-Cast: Steuerung kalter Bildbereiche
  - Halation: Lichtstreueffekte (Stärke, Gaussian Blur)
  - Crushed Luminance: Helligkeitskompression
  - Gate-Weave: Filmprojektionseffekte
Es gibt einen Reset-Button, der die Einstellungen mit `resetConfig()` auf die Standardwerte zurücksetzt.
Die ConfigSlider-Komponente verwendet ```html <input type='range'>``` für die Wertsteuerung. Es kann angegeben werden in welchen `Steps` der Slider bewegt werden darf, z.B. 0.01 oder 1. Ebenso werden `min` und `max` definiert um die Skala des Sliders festzulegen, z.B. von 0 bis 1. Ansonsten wird der aktuelle Wert im `value` übergeben. `onValue` wird bei Veränderungen an dem Slider aktiviert und ruft `updateConfig()` auf, welches zum Einen die Methode zur Weiterleitung ans Backend aufruft, als auch das neue Value in den useState speichert.

Die `VideoStream`-Komponente hat über `http://localhost:8080/stream`auf die Frames, welche als einzelne Bilder übermittelt werden. Anzeigt werden diese als Live-Stream über ein ```html <img>```-Element. 
]