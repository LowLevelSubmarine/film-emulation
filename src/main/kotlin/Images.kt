import nu.pattern.OpenCV
import org.opencv.core.Mat
import org.opencv.core.Size
import org.opencv.imgcodecs.Imgcodecs
import org.opencv.imgproc.Imgproc

val config = Config.default.copy(
    crushedLuminanceStrength = 0.2f,
    halationStrength = 1f,
)

fun main() {
    OpenCV.loadLocally()
    val path = "./assets/presentation/stairs.png"
    val source = Imgcodecs.imread(path, Imgcodecs.IMREAD_COLOR)
    val processing = ProcessingDsl()
    val destination = Mat()
    processing.apply {
        Imgproc.resize(source, destination, source.size() / 5)
        adjustLuminance(destination, destination, contrast = 1.7, brightness = 1.2)
        adjustSaturation(destination, destination, saturation = 0.7)
        //Imgcodecs.imwrite("$path-im.png", destination)
        process(destination, destination, config)
    }
    Imgcodecs.imwrite("$path-tone_cold.png", destination)
}
