import nu.pattern.OpenCV
import org.opencv.core.CvType
import org.opencv.core.Mat
import org.opencv.imgcodecs.Imgcodecs
import java.nio.file.Files
import java.nio.file.Paths
import kotlin.math.roundToInt
import kotlin.time.measureTime

const val LUT_SIZE = 64

/**
 * Reads a LUT (Look-Up Table) file and returns its contents as a list of lists of floats.
 *
 * @param path The path to the LUT file.
 * @return A list of lists of floats representing the LUT.
 */
fun readLutFile(path: String): List<List<Float>> {
    val lines = Files.readAllLines(Paths.get(path))
    return lines.takeLast(LUT_SIZE * LUT_SIZE * LUT_SIZE).map { line ->
        line.split(" ").map { it.toFloat() }
    }
}

/**
 * Converts a pixel using the provided LUT.
 *
 * @param pixel The pixel to convert, represented as a DoubleArray.
 * @param lut The LUT to use for conversion.
 * @return A ByteArray representing the converted pixel.
 */
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

/**
 * Converts an image using a LUT and saves the result to a specified output path.
 *
 * @param imgPath The path to the input image.
 * @param lutPath The path to the LUT file.
 * @param outputPath The path to save the converted image.
 */
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

/**
 * The main function that loads OpenCV, processes an image with a LUT, and measures the time taken.
 */
fun main() {
    OpenCV.loadLocally()

    val inputImagePath = "./assets/3dLutsTests/stairs.png"
    val lutFilePath = "./assets/luts/Kodak Portra 400 UC.cube"
    val outputImagePath = "./assets/3dLutsTests/stairsNew.png"

    val time = measureTime { convertWithLut(inputImagePath, lutFilePath, outputImagePath) }

    println("Image processed and saved to: $outputImagePath in ${time.inWholeMilliseconds}ms")
}
