#import "/components.typ": authored_by

== Optimierung
#authored_by("Florian Weichert")
Obwohl das Frameraten-Ziel für dieses Projekt eigentlich bei 25 fps (Bilder pro Sekunde) lag, musste schlussendlich tatsächlich eine Framerate von 30 fps erreicht werden, da die verwendte Capture-Card nur diese, oder 60fps, unterstützt. So ergibt sich ein maximales Zeit-Budget pro Frame von 33.33 ms. Zum Ende der Implementierungs-Phase wurde jedoch für die Berechnung jedes Frames eine Zeit von Durchschnittlich \~37 ms#footnote[Die Zeit-Angabe wurde auf einem MacBook mit Apple M1 Pro Prozessor gemessen]<fn:timings-refer-to-m1-pro> benötigt. Also mussten Optimierungen vorgenommen werden, sodass keine Frame-Drops entstehen. Um einen besseren Einblick in die Performance der einzelnen Effekte zu erhalten, wurden die Durchlaufzeiten der Effekte jeweils einzelnd gemessen (@fig:frame-timings).

#figure(
    image("../../assets/processing-times.png"),
    caption: [Durchlaufzeiten @fn:timings-refer-to-m1-pro der einzelnen Effekte],
)<fig:frame-timings>
