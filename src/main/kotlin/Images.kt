import nu.pattern.OpenCV
import org.opencv.core.Core
import org.opencv.core.Mat
import org.opencv.core.Scalar
import org.opencv.core.Size
import org.opencv.imgcodecs.Imgcodecs
import org.opencv.imgproc.Imgproc

val config = Config.default.copy(
    colorCast = Color(
        red = 0.0f,
        green = 0.0f,
        blue = 0.03f,
    ),
    crushedLuminanceStrength = 0.2f,
)

fun main() {
    OpenCV.loadLocally()
    val source = Imgcodecs.imread("./assets/spok.png", Imgcodecs.IMREAD_COLOR)
    val processing = ProcessingDsl()
    val destination = Mat()
    processing.apply {
        Imgproc.resize(source, destination, source.size() / 5)
        Core.add(destination, Scalar.all(40.0), destination)
        val contrastLut =
            createSplineLUT(
                listOf(
                    Knot(0.0f, 0.0f),
                    Knot(0.30f, 0.05f),
                    Knot(0.70f, 0.95f),
                    Knot(1.0f, 1.0f)
                )
            )
        Core.LUT(destination, contrastLut, destination)
        process(destination, destination, config)
    }
    Imgcodecs.imwrite("./assets/spok-edit.png", destination)
}

private operator fun Size.div(i: Number) = Size(this.width / i.toDouble(), this.height / i.toDouble())
