package org.example

import dev.benedikt.math.bezier.spline.FloatBezierSpline
import dev.benedikt.math.bezier.vector.Vector2F
import org.opencv.core.CvType
import org.opencv.core.Mat
import kotlin.math.pow

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

    val lutData = ByteArray((lut.total() * lut.channels()).toInt())
    for (i in 0 until lut.cols()) {
        lutData[i] = (spline.getCoordinatesAt(i / 256.0f).y * 256).toInt().toByte()
    }
    lut.put(0, 0, lutData)
    return lut
}

fun createSplineLUT(vararg knots: Knot) = createSplineLUT(knots.toList())
