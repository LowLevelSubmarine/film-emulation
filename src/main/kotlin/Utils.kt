package org.example

import dev.benedikt.math.bezier.spline.FloatBezierSpline
import dev.benedikt.math.bezier.vector.Vector2F
import org.opencv.core.CvType
import org.opencv.core.Mat
import org.opencv.core.Point
import org.opencv.core.Size
import java.lang.Math.pow
import kotlin.math.min
import kotlin.math.pow
import kotlin.math.sqrt

data class Knot(val x: Float, val y: Float)

fun createGammaLUT(gammaValue: Double): Mat {
    fun saturate(`val`: Double): Byte {
        var iVal = Math.round(`val`).toInt()
        iVal = if (iVal > 255) 255 else (if (iVal < 0) 0 else iVal)
        return iVal.toByte()
    }

    val lut = Mat(1, 256, CvType.CV_8U)
    val lutData = ByteArray((lut.total() * lut.channels()).toInt())
    for (i in 0 until lut.cols()) {
        lutData[i] = saturate((i / 255.0).pow(gammaValue) * 255.0)
    }
    lut.put(0, 0, lutData)
    return lut
}

fun createSplineLUT(knots: List<Knot>): Mat {
    val lut = Mat(1, 256, CvType.CV_8U)
    val spline = FloatBezierSpline<Vector2F>()
    spline.addKnots(*knots.map { Vector2F(x = it.x, y = it.y) }.toTypedArray())

    val lutData = ByteArray(256)
    for (i in 0 until 256) {
        lutData[i] = (spline.getCoordinatesAt(i / 256.0f).y * 256).toInt().toByte()
    }
    lut.put(0, 0, lutData)
    return lut
}

fun createSplineLUT(vararg knots: Knot) = createSplineLUT(knots.toList())

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
