package org.example

import kotlinx.serialization.Contextual
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
    val warmHue: Float,
    val warmStrength: Float,
    val coldHue: Float,
    val coldStrength: Float,
    val crushedLuminanceStrength: Float,
) {
    companion object {
        val default = Config(
            grainStrength = 0.2f,
            dustStrength = 0.5f,
            vignetteStrength = 0.1f,
            threshold = 20.0f,
            sigmaX = 0.0f,
            gaussianSize = BlurSize(99.0f, 99.0f),
            colorCast = Color(0.0f, 0.0f, 0.1f),
            warmHue = 0.08f,
            warmStrength = 0.2f,
            coldHue = 0.58f,
            coldStrength = 0.0f,
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
    operator fun div(i: Number) = Color(red / i.toFloat(), green / i.toFloat(), red / i.toFloat())
}

@Serializable
data class BlurSize(
    val width: Float,
    val height: Float,
) {
    fun toSize() = Size(width.toDouble(), height.toDouble())
}
