import kotlinx.serialization.Serializable
import org.opencv.core.Scalar
import org.opencv.core.Size

@Serializable
data class Config(
    val grainStrength: Float,
    val dustStrength: Float,
    val vignetteStrength: Float,
    val threshold: Float,
    val sigmaX: Float,
    val gaussianSize: BlurSize,
    val colorCast: Color,
    val warmColorCast: Color,
    val coldColorCast: Color,
    val crushedLuminanceStrength: Float,
) {
    companion object {
        val default = Config(
            grainStrength = 0.3f,
            dustStrength = 0.5f,
            vignetteStrength = 0.1f,
            threshold = 20.0f,
            sigmaX = 0.0f,
            gaussianSize = BlurSize(99.0f, 99.0f),
            colorCast = Color(0.0f, 0.0f, 0.0f),
            warmColorCast = Color(red = 0.1f, green = 0.04f, blue = 0.0f),
            coldColorCast = Color(red = 0.04f, green = 0.0f, blue = 0.02f),
            crushedLuminanceStrength = 0.5f,
        )
    }
}

@Serializable
data class Color(
    val red: Float,
    val green: Float,
    val blue: Float,
) {
    fun toScalar() = Scalar(blue * 255.0, green * 255.0, red * 255.0)
    operator fun times(i: Number): Color {
        return Color(red * i.toFloat(), green * i.toFloat(), blue * i.toFloat())
    }

    operator fun div(i: Number) = Color(red / i.toFloat(), green / i.toFloat(), blue / i.toFloat())
}

@Serializable
data class BlurSize(
    val width: Float,
    val height: Float,
) {
    fun toSize() = Size(width.toDouble(), height.toDouble())
}
