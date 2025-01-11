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
}

@Serializable
data class BlurSize(
    val width: Float,
    val height: Float,
) {
    fun toSize() = Size(width.toDouble(), height.toDouble())
}
