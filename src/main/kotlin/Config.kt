import kotlinx.serialization.Serializable
import org.opencv.core.Scalar
import org.opencv.core.Size

/**
 * Configuration data class for film emulation settings.
 *
 * @property grainStrength Strength of the grain effect.
 * @property dustStrength Strength of the dust effect.
 * @property vignetteStrength Strength of the vignette effect.
 * @property halationStrength Strength of the halation effect.
 * @property halationThreshold Threshold for the halation effect.
 * @property halationSigmaX Sigma X value for the halation Gaussian blur.
 * @property halationGaussianSize Size of the Gaussian blur for halation.
 * @property colorCast General color cast applied to the image.
 * @property warmColorCast Warm color cast applied to the image.
 * @property coldColorCast Cold color cast applied to the image.
 * @property crushedLuminanceStrength Strength of the crushed luminance effect.
 * @property jitterScale Scale of the jitter effect.
 * @property weaveNoiseSpeed Speed of the weave noise effect.
 * @property weaveNoiseScale Scale of the weave noise effect.
 */
@Serializable
data class Config(
    val grainStrength: Float,
    val dustStrength: Float,
    val vignetteStrength: Float,
    val halationStrength: Float,
    val halationThreshold: Float,
    val halationSigmaX: Float,
    val halationGaussianSize: BlurSize,
    val colorCast: Color,
    val warmColorCast: Color,
    val coldColorCast: Color,
    val crushedLuminanceStrength: Float,
    val jitterScale: Float,
    val weaveNoiseSpeed: Float,
    val weaveNoiseScale: Float,
) {
    companion object {
        /**
         * Default configuration values.
         */
        val default = Config(
            grainStrength = 0.25f,
            dustStrength = 0.5f,
            vignetteStrength = 0.1f,
            halationStrength = 1.0f,
            halationThreshold = 20.0f,
            halationSigmaX = 0.0f,
            halationGaussianSize = BlurSize(99.0f, 99.0f),
            colorCast = Color(0.0f, 0.04f, 0.0f),
            warmColorCast = Color(red = 0.12f, green = 0.014f, blue = 0.0f) * 1.4f,
            coldColorCast = Color(red = 0.04f, green = 0.0f, blue = 0.04f) * 2f,
            crushedLuminanceStrength = 0.5f,
            jitterScale = 0.0005f,
            weaveNoiseSpeed = 0.015f,
            weaveNoiseScale = 0.01f,
        )
    }
}

/**
 * Data class representing a color with red, green, and blue components.
 *
 * @property red Red component of the color.
 * @property green Green component of the color.
 * @property blue Blue component of the color.
 */
@Serializable
data class Color(
    val red: Float,
    val green: Float,
    val blue: Float,
) {
    /**
     * Converts the color to an OpenCV Scalar.
     *
     * @return Scalar representation of the color.
     */
    fun toScalar() = Scalar(blue * 255.0, green * 255.0, red * 255.0)

    /**
     * Multiplies the color by a given number.
     *
     * @param i The number to multiply by.
     * @return A new Color instance with multiplied values.
     */
    operator fun times(i: Number): Color {
        return Color(red * i.toFloat(), green * i.toFloat(), blue * i.toFloat())
    }

    /**
     * Divides the color by a given number.
     *
     * @param i The number to divide by.
     * @return A new Color instance with divided values.
     */
    operator fun div(i: Number) = Color(red / i.toFloat(), green / i.toFloat(), blue / i.toFloat())
}

/**
 * Data class representing the size of a blur effect.
 *
 * @property width Width of the blur.
 * @property height Height of the blur.
 */
@Serializable
data class BlurSize(
    val width: Float,
    val height: Float,
) {
    /**
     * Converts the blur size to an OpenCV Size.
     *
     * @return Size representation of the blur size.
     */
    fun toSize() = Size(width.toDouble(), height.toDouble())
}
