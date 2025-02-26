#import "../../components.typ": authored_by

== 3D Luts
#authored_by("")

=== Implementierung
- Ziel der Implementierung
    - Funktion zur Anwendung einer 3D-Lookup-Tabelle (LUT) auf ein Bild entwickeln
    - Farbkorrektur und -manipulation mit LUT-Dateien ermöglichen
    - OpenCV und Kotlin zur effizienten Bildverarbeitung nutzen
    - Verarbeitungsgeschwindigkeit für große Bilddateien optimieren
- Beschreibung der Funktion readLutFile:
    - 3D-LUT-Datei im .cube-Format einlesen
    - Letzte Zeilen der Datei enthalten die LUT-Werte
    - Werte als Liste von Float-Werten speichern und für Farbtransformation nutzen
- Beschreibung der Funktion convertPixel:
    - RGB-Werte des Pixels in LUT-Position umrechnen
    - Pixelwerte von 0-255 auf LUT-Wertebereich (0 bis LUT_SIZE - 1) skalieren
    - LUT zur Bestimmung neuer Farbwerte nutzen
    - Transformierte Farbwerte als Byte-Array zur weiteren Verarbeitung ausgeben
- Beschreibung der Funktion convertWithLut:
    - Eingabebild mit OpenCV laden
    - Leere Matrix für das Ausgabeformat erstellen
    - Alle Pixel des Bildes iterieren und Farbwerte durch LUT-Werte ersetzen
    - Verändertes Bild als neue Datei speichern
    - Fehlerbehandlung für nicht ladbare Bilder enthalten
- Vorteile der Implementierung
    - Automatisierte Farbkorrektur durch LUTs
    - Effiziente Verarbeitung durch direkten Zugriff auf LUT-Werte
    - Flexibel nutzbar mit verschiedenen LUT-Dateien
    - OpenCV-Integration für leistungsstarke Bildverarbeitung
    - Skalierbar für verschiedene Bildauflösungen und LUT-Größen

```kotlin
import nu.pattern.OpenCV
import org.opencv.core.CvType
import org.opencv.core.Mat
import org.opencv.imgcodecs.Imgcodecs
import java.nio.file.Files
import java.nio.file.Paths
import kotlin.math.roundToInt
import kotlin.time.measureTime

const val LUT_SIZE = 64

fun readLutFile(path: String): List<List<Float>> {
    val lines = Files.readAllLines(Paths.get(path))
    return lines.takeLast(LUT_SIZE * LUT_SIZE * LUT_SIZE).map { line ->
        line.split(" ").map { it.toFloat() }
    }
}

fun convertPixel(pixel: DoubleArray, lut: List<List<Float>>): ByteArray {
    val r = ((pixel[0] / 255) * (LUT_SIZE - 1)).roundToInt()
    val g = ((pixel[1] / 255) * (LUT_SIZE - 1)).roundToInt()
    val b = ((pixel[2] / 255) * (LUT_SIZE - 1)).roundToInt()

    val idx = r + g * LUT_SIZE + b * LUT_SIZE * LUT_SIZE
    val result = lut[idx]

    return byteArrayOf(
        (result[0] * 255).toInt().toByte(),
        (result[1] * 255).toInt().toByte(),
        (result[2] * 255).toInt().toByte(),
    )
}

fun convertWithLut(imgPath: String, lutPath: String, outputPath: String) {
    val lut = readLutFile(lutPath)
    val img = Imgcodecs.imread(imgPath, Imgcodecs.IMREAD_COLOR)
    if (img.empty()) {
        throw IllegalArgumentException("Image not found at path: $imgPath")
    }
    val output = Mat(img.size(), CvType.CV_8UC3)
    for (y in 0 until img.rows()) {
        for (x in 0 until img.cols()) {
            val pixel = img.get(y, x)
            val newPixel = convertPixel(pixel, lut)
            output.put(y, x, newPixel)
        }
    }

    Imgcodecs.imwrite(outputPath, output)
}

fun main() {
    OpenCV.loadLocally()

    val inputImagePath = "./assets/3dLutsTests/stairs.png"
    val lutFilePath = "./assets/luts/Kodak Portra 400 UC.cube"
    val outputImagePath = "./assets/3dLutsTests/stairsNew.png"

    val time = measureTime {
      convertWithLut(inputImagePath, lutFilePath, outputImagePath)
    }

    println(
      "Image processed and saved to: $outputImagePath in ${time.inWholeMilliseconds}ms"
    )
}
```

=== Probleme und Herausforderungen