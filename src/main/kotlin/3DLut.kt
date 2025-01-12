import nu.pattern.OpenCV
import org.opencv.core.CvType
import org.opencv.core.Mat
import org.opencv.imgcodecs.Imgcodecs
import java.nio.file.Files
import java.nio.file.Paths
import kotlin.math.roundToInt
import kotlin.time.measureTime

const val LUT_SIZE = 32

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
    // Read the LUT file
    val lut = readLutFile(lutPath)

    // Load the image using OpenCV
    val img = Imgcodecs.imread(imgPath, Imgcodecs.IMREAD_COLOR)
    if (img.empty()) {
        throw IllegalArgumentException("Image not found at path: $imgPath")
    }

    // Prepare the output image with appropriate type for floating-point data
    val output = Mat(img.size(), CvType.CV_8UC3)

    // Process each pixel
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

    val inputImagePath = "./assets/spok.png"
    val lutFilePath = "./assets/luts/IWLTBAP Sedona - Standard.cube"
    val outputImagePath = "./assets/spokNew.png"

    val time = measureTime { convertWithLut(inputImagePath, lutFilePath, outputImagePath) }

    println("Image processed and saved to: $outputImagePath in ${time.inWholeMilliseconds}ms")
}
