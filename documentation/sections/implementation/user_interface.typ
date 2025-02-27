#import "../../components.typ": authored_by

== User Interface
#authored_by("Leonie Wehser")

=== Implementierung
- Grundstruktur
  - Anwendung basiert auf Preact, besteht aus mehreren Komponenten
  - Hauptkomponente App rendert ConfigUi und VideoStream
  - UI-Elemente mittig ausgerichtet
- ConfigUi-Komponente
  - Verwaltung der Konfigurationseinstellungen
  - useState zur Speicherung des aktuellen Zustands
  - Initialwerte mit getConfig laden
  - Änderungen mit postConfigDebounced speichern
  - CoolSlider-Elemente zur Parameteranpassung
- Wichtige Einstellungen
  - Grain Strength: Körnung
  - Dust Strength: Staubeffekte
  - Vignette Strength: Vignettierung
  - Color Cast: Farbverschiebungen in RGB-Kanälen
  - Warm Color Cast / Cold Color Cast: Steuerung warmer/kalter Farbtöne
  - Halation: Lichtstreueffekte (Stärke, Gaussian Blur)
  - Crushed Luminance: Helligkeitskompression
  - Gate Weave: Filmprojektionseffekte
  - Reset-Button für Standardwerte
- CoolSlider-Komponente
  - Individuelles Slider-Element
  - HTML ```html <input type='range'>``` für Wertsteuerung
  - Optische Anpassung mit linear-gradient
  - onValue-Funktion zur Aktualisierung in ConfigUi
- VideoStream-Komponente
  - Live-Stream über <img>-Element
  - Zugriff auf http://localhost:8080/stream
- API-Kommunikation
  - getConfig(): Lädt Konfiguration vom Server
  - postConfig(config): Sendet aktualisierte Konfiguration
  - resetConfig(): Setzt Standardwerte zurück
- Performance-Optimierung
  - useMemo für debounce-Wrapping von postConfig
  - Gezielte State-Updates zur Vermeidung unnötiger Neuberechnungen