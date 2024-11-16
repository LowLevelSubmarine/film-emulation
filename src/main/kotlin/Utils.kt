package org.example

import org.opencv.core.CvType
import org.opencv.core.Mat
import kotlin.math.pow


fun createGammaLut(gammaValue: Double): Mat {
    fun saturate(`val`: Double): Byte {
        var iVal = Math.round(`val`).toInt()
        iVal = if (iVal > 255) 255 else (if (iVal < 0) 0 else iVal)
        return iVal.toByte()
    }

    val lookUpTable = Mat(1, 256, CvType.CV_8U)
    val lookUpTableData = ByteArray((lookUpTable.total() * lookUpTable.channels()).toInt())
    for (i in 0 until lookUpTable.cols()) {
        lookUpTableData[i] = saturate((i / 255.0).pow(gammaValue) * 255.0)
    }
    lookUpTable.put(0, 0, lookUpTableData)
    return lookUpTable
}
