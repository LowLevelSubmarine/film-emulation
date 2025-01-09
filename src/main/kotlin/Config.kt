package org.example

import kotlinx.serialization.Serializable

@Serializable
data class Config(
    val grainStrength: Float,
    val dustStrength: Float,
) {
    companion object {
        val default = Config(
            grainStrength = 0.2f,
            dustStrength = 0.5f,
        )
    }
}
