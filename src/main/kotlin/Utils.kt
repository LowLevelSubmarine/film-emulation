package org.example

import dev.benedikt.math.bezier.spline.FloatBezierSpline
import dev.benedikt.math.bezier.vector.Vector2F
import org.opencv.core.CvType
import org.opencv.core.CvType.CV_32F
import org.opencv.core.Mat
import org.opencv.core.Point
import org.opencv.core.Size
import kotlin.math.log10
import kotlin.math.min
import kotlin.math.pow
import kotlin.math.sqrt
import kotlin.random.Random

data class Knot(val x: Float, val y: Float)

fun createGammaLUT(gammaValue: Double): Mat {
    fun saturate(floatValue: Double): Byte {
        var value = Math.round(floatValue).toInt()
        value = if (value > 255) 255 else (if (value < 0) 0 else value)
        return value.toByte()
    }

    return createLUT { i -> saturate((i / 255.0).pow(gammaValue) * 255.0) }
}

fun createSplineLUT(knots: List<Knot>): Mat {
    val spline = FloatBezierSpline<Vector2F>()
    spline.addKnots(*knots.map { Vector2F(x = it.x, y = it.y) }.toTypedArray())
    return createLUT { i -> (spline.getCoordinatesAt(i / 256.0f).y * 256).toInt().toByte() }
}

fun createSplineLUT(vararg knots: Knot) = createSplineLUT(knots.toList())

fun createSlog3ToSrgbLut(): Mat = createLUT { i ->
    val normalizedValue = i / 255.0
    val normalizedSrgbValue = mapSlrToSrgb(mapSlog3ToSlr(normalizedValue))
    (normalizedSrgbValue * 255.0).toInt().toByte()
}

private fun createLUT(fn: (i: Int) -> Byte): Mat {
    val lut = Mat(1, 256, CvType.CV_8U)
    val lutData = ByteArray(256)
    for (i in 0 until 256) {
        lutData[i] = fn(i)
    }
    lut.put(0, 0, lutData)
    return lut
}

// https://pro.sony/s3/cms-static-content/uploadfile/06/1237494271406.pdf
private fun mapSlog3ToSlr(slog3Value: Double): Double {
    // Constants for S-Log3
    val a = 0.037584
    val b = 0.01125000
    val c = 0.00807360
    val d = 0.432699
    val e = 0.030001222851889303 // Derived value for e
    val m = 0.432699

    // Threshold for logarithmic vs linear
    val threshold = m * log10(c) + d

    val out =  if (slog3Value >= threshold) {
        10.0.pow((slog3Value - d) / m) - c
    } else {
        (slog3Value - e) * b / a
    }
    return (out * 0.01).coerceIn(0.0, 1.0)
}

private fun mapSlrToSrgb(slrValue: Double): Double {
    return slrValue
    val a = 0.055
    return if (slrValue <= 0.0031308) {
        12.92 * slrValue
    } else {
        (1 + a) * slrValue.pow(1/2.4) - a
    }
}

fun createVignetteMask(strength: Double, size: Size): Mat {
    val mask = Mat(size, CvType.CV_8UC3)
    val center = Point(size.height / 2, size.width / 2)
    val maxDist = sqrt(center.x.pow(2.0) + center.y.pow(2.0))
    for (x in 0 until size.height.toInt()) {
        for (y in 0 until size.width.toInt()) {
            val delta = Point(x - center.x, y - center.y)
            val dist = sqrt(delta.x.pow(2.0) + delta.y.pow(2.0)) / maxDist
            val value = min((dist * strength * 256).toInt(), 255).toByte()
            mask.at(Byte::class.java, x, y).v3c = Mat.Tuple3(value, value, value)
        }
    }
    return mask
}

fun createRandomOffsetTransformation(image: Mat): Mat {
    return Mat.zeros(2, 3, CV_32F).apply {
        put(0, 0, floatArrayOf(1.0F))
        put(1, 1, floatArrayOf(1.0F))
        put(0, 2, floatArrayOf(Random.Default.nextFloat() * image.width()))
        put(1, 2, floatArrayOf(Random.Default.nextFloat() * image.height()))
    }
}
/*
fun loadLUT(cubeFilePath: String): Mat {
    val file = File(cubeFilePath)
    val regex = Regex("^(?<key>\\w+) (?<value>.+)\$")

    //var lutSize = 33 // default size
    val rgbValues = mutableListOf<FloatArray>()

    file.forEachLine { line ->
        if (line.startsWith("#") || line.isBlank()) return@forEachLine
        val config = regex.matchEntire(line)?.let { it.groups["key"]!!.value to it.groups["value"]!!.value }
        if (config != null) {
            /*when (config.first) {
                "LUT_3D_SIZE" -> lutSize = config.second.toInt()
            }*/
            return@forEachLine
        }
        rgbValues.add(line.split(" ").map { it.toFloat() }.toFloatArray())
    }

    val length = rgbValues.size.toFloat().pow(1/3.toFloat())


    fun getColor(input: ByteArray): ByteArray {
        fun mapInput(input: Byte) = input.toFloat() / 255 * length
        val index = (mapInput(input[0]) * 64 * 64).toInt() + (mapInput(input[1]) * 64).toInt() + mapInput(input[2]).toInt()
        return rgbValues[index].map { (it * 255).toInt().toByte() }.toByteArray()
    }

    val lut = Mat(1, 256, CvType.CV_8UC3)
    for (i in 0 until 256) {
        lut.put(0, i, getColor())
    }

    return lut
}

private fun <T> List<T>.takeEquallyDistributed(amount: Int): List<T> {
    val list = mutableListOf<T>()
    val offset = size / (amount - 1)
    for (i in 0 until size - offset step offset) {
        list.add(get(i))
    }
    list.add(get(size - 1))
    return list
}
*/