#import "../../components.typ": authored_by

== Cache
#authored_by("Florian Weichert")
Für die Implementierung von Effekten ist es oft sinnvoll, dass bestimmte Werte nur einmal berechnet werden, um die Performance zu verbessern. Dafür kann ein Cache verwendet werden, der die Werte speichert und bei erneutem Zugriff auf den gleichen Wert zurückgibt. Der Cache sollte dabei in der Nutzung so einfach wie möglich sein, um die Implementierung der jeweiligen Effekte nicht unnötig zu verkomplizieren. Außerdem sollte der Cache ohne viel Aufwand invalidiert werden können, um sicherzustellen, dass die Werte immer aktuell sind. Das ist besonders dann relevant wenn gecachte Werte von den in Echtzeit anpassbaren Einstellungen des Nutzers abhängig sind.

=== Implementierung
Um die Nutzung des Caches möglichst einfach zu gestalten, sollte dieser ohne einen expliziten Schlüssel auskommen. So genügt als Parameter für die Nutzung eines gecachten Wertes ausschließlich die Funktion, die den jeweiligen Wert berechnet, sollte Wert noch nicht im Cache gespeichert worden sein:
```kotlin
fun storageTest() {
  val storage = Storage()
  // Beispiel Cache-Aufruf
  val veryExpensiveCalculationResult = storage.store({ 1 + 2 })
}
```
Aufgrund von Kotlins Syntactic Sugar kann die Funktion `storageTest` als Extension-Function eine Instanz von Storage für den Aufruf vorraussetzen. Zusätzlich kann der letzte Parameter einer Funktion, sollte er eine Funktion sein, außerhalb der Klammern übergeben werden. Diese beiden Sprach-Features ermöglichen es, den Cache-Aufruf noch weiter zu vereinfachen:
```kotlin
fun Storage.storageTest() {
  // Beispiel Cache-Aufruf
  val veryExpensiveCalculationResult = store { 1 + 2 }
}
```
Um den jeweiligen Wert im Cache jedoch auch ohne Schlüssel identifizieren zu können wird anstelle eines herkömmlichen Schlüssels ein Zähler verwendet. Dieser wird bei jedem Aufruf des Caches inkrementiert und dient als Identifikator für den jeweiligen Wert. Damit der Cache auch schlussendlich verwendet werden kann, muss der Zähler vor jedem einzelnen Durchlauf der Pipeline einmal zurückgesetzt werden. Die Inspiration für diese Implementierung stammt aus der Dokumentation zu der Flutter Bibliothek `flutter_hooks` @flutter-hooks-principle.
#parbreak()
Für die Invalidierung des Caches anhand von Abhängigkeiten wird neben dem Wert selbst auch eine List aller angegebenen Abhängigkeiten gespeichert. Sollte sich mit einem Aufruf des Caches eine der Abhängigkeiten geändert haben, wird der Wert neu berechnet und im Cache gespeichert:
```kotlin
fun Storage.storageTest() {
  var multiplier = 1
  val veryExpensiveCalculationResult =
      store(dependencies = listOf(multiplier)) { 3 * multiplier }
}
```