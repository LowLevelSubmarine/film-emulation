#import "@preview/wrap-it:0.1.1": wrap-content
#import "../components.typ": authored_by

= Funktionsweise des Analog-Films
#authored_by("Florian Weichert")

== Fotoemulsion <topic:fotoemulsion>
Der analoge Farbfilm beruht auf dem Prinzip der Fotoemulsion. Hierbei werden lichtempfindliche Salze verwendet um Informationen über die Intensität des einfallenden Lichts zu festzuhalten. Die lichtempfindlichen Salze bestehen aus einer Mischung der Silberhalogenide Silberbromid, Silberchlorid und Silberiodid. Diese Salze werden in einer Gelatineschicht auf einem Trägermaterial aufgebracht, sodass diese gleichmäßig verteilt sind. Wird nun Licht auf die Salze geworfen, bilden sich Belichtungskeime, welche für das menschliche Auge nicht sichtbar sind, jedoch über ihre lokale Konzentration Information über die Intensität des aufgetroffenen Lichts enthalten. Dieser Zustand wird als latentes#footnote[verborgenes] Bild bezeichnet. Während der Entwicklung werden dann chemische Vorgänge genutzt, um die Belichtungskeime sichtbar zu machen. So wird das latente Bild in ein sichtbares Bild umgewandelt. Zuletzt muss das Bild noch haltbar gemacht werden, da es sonst durch Lichteinwirkung oder Umwelteinflüsse zerstört werden könnte. Dies geschieht durch die Fixierung des Bildes, wobei die lichtempfindlichen Salze aus der Emulsionsschicht entfernt werden. @foto-emulsion

== Struktur
#wrap-content(
    [
      #pad(left: 12pt, bottom: 12pt)[
        #figure(
            image("../assets/film-layers.png"),
            caption: [Struktur \ eines Farbfilms],
        )<fig:film-layers>
      ]
    ],
    [
        Ein Farbfilm besteht aus mehreren Schichten (@fig:film-layers), die jeweils eine individuelle Aufgabe erfüllen.

        === Schutz-Schicht
        Die oberste Schicht ist die Schutz-Schicht, die das Bild vor Umwelteinflüssen schützt.

        === UV-Filter
        Das menschliche Auge ist nicht in der Lage ultraviolettes Licht wahrzunehmen. Daher befindet sich unter der Schutzschicht ein UV-Filter, der das ultraviolette Licht herausfiltert, sodass ulraviolettes Licht keinen Einfluss auf die darunter liegenden Emulsionsschichten haben kann.

        === Gelbe Emulsionsschichten
        Die erste Emulsionsschicht ist für die Aufnahme von blauem Licht zuständig. Sie wird als Gelb bezeichnet, da sie während der Entwicklung gelben Farbstoff freisetzt. Die Emulsionsschichten können je nach Film unterschiedlich aufgebaut sein. Es gibt Filme mit bis zu drei verschiedenen Empfindlichkeiten, um den Dynamik-Umfang zu erhöhen, diese werden dann als "Low speed-", "Medium speed-" und "High speed layers" bezeichnet. @multiple-emulsion-layers-per-color

        === Gelb-Filter
        Um die Farben des Bildes mölichst korrekt darzustellen, wird unter der Gelben Emulsionsschicht ein Gelb-Filter einesetzt um verbleibendes blaues Licht herauszufiltern, sodass weitere Emulsionsschichten nicht durch blaues Licht belichtet werden können.

        === Magenta Emulsionsschichten
        Die zweite Emulsionsschicht ist für die Aufnahme von grünem Licht zuständig. Während der Entwicklung wird ein Magenta-Farbstoff freigesetzt.

        === Rot-Filter
        Analog zum Gelb-Filter wird unter der Magenta Emulsionsschicht ein Rot-Filter eingesetzt, um verbleibendes grünes Licht herauszufiltern.

        === Cyan Emulsionsschichten
        Die letzte Emulsionsschicht ist für die Aufnahme von rotem Licht zuständig. Während der Entwicklung wird ein Cyan-Farbstoff freigesetzt.

        === Anti-Halation-Schicht
        Die unterste Schicht vor dem Schicht-Träger ist die Anti-Halation-Schicht. Ohne diese Schicht könnte Licht von der Rückseite des Films oder der Kamera reflektiert werden und so die Emulsionsschichten ungehindert erneut belichten.

        === Schicht-Träger
        Der Schicht-Träger ist das Trägermaterial, auf dem die Emulsionsschichten aufgebracht sind. Er sorgt für die Stabilität des Films und schützt die Emulsionsschichten vor Umwelteinflüssen. @film-structure
    ],
    align: right,
)
