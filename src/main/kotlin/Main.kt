package org.example

import nu.pattern.OpenCV
import org.opencv.core.Core
import org.opencv.core.CvType
import org.opencv.core.CvType.CV_8UC3
import org.opencv.core.Mat
import org.opencv.core.Size
import org.opencv.highgui.HighGui
import org.opencv.highgui.ImageWindow
import org.opencv.imgcodecs.Imgcodecs
import org.opencv.imgproc.Imgproc.GaussianBlur
import org.opencv.videoio.VideoCapture
import kotlin.math.pow
import kotlin.random.Random


fun main() {
    OpenCV.loadLocally()

    val window = ImageWindow("test", 0)
    val videoCapture = VideoCapture(0)  // cameraIndex = 0
    val inputImage = Mat()
    val processedImage = Mat()
    val processing = ProcessingDsl()

    // Start streaming
    do {
        videoCapture.read(inputImage)
        processing.apply {
            reset()
            process(inputImage, processedImage)
        }
        HighGui.imshow("test", processedImage)
    } while (HighGui.waitKey(20) != 27)

    // Close Window
    HighGui.destroyWindow("test")
    HighGui.waitKey(1) // actually closes the window
    videoCapture.release()
}

fun ProcessingDsl.process(inputImage: Mat, destinationImage: Mat) {
    halation(inputImage, destinationImage)
    //grain(inputImage, destinationImage)
}

fun ProcessingDsl.halation(inputImage: Mat, destinationImage: Mat) {
    log("calculating halation")
    val redChannelImage = store { Mat() }
    Core.extractChannel(inputImage, redChannelImage, 2) // red channel isolated
    val gammaLut = store { createGammaLut(20.0) }
    Core.LUT(redChannelImage, gammaLut, redChannelImage)
    GaussianBlur(redChannelImage, redChannelImage, Size(99.0,99.0), 0.0) // blurred red channel
    val threeChannelImage = store { Mat.zeros(inputImage.size(), CV_8UC3) }  // black image with 3 channels
    Core.insertChannel(redChannelImage, threeChannelImage, 2)
    Core.add(inputImage, threeChannelImage, destinationImage)
}

fun ProcessingDsl.grain(inputImage: Mat, destinationImage: Mat) {
    val grain = store { Imgcodecs.imread("./grain.jpeg") }

    //grain.copyTo(destinationImage.adjustROI(random))
}

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

class ProcessingDsl {
    private val storage = Storage()
    fun <T> store(creator: () -> T) = storage.store { creator() }
    fun reset() = storage.reset()
    fun log(text: String) {
        println(text)
    }
}

class Storage {
    private val storage = mutableMapOf<Int, Any?>()
    private var counter = 0

    @Suppress("UNCHECKED_CAST")
    fun <T> store(creator: () -> T): T {
        val value = if (storage.containsKey(counter)) {
            storage[counter] as T
        } else {
            val value = creator()
            storage[counter] = value
            value
        }
        counter++
        return value
    }

    fun reset() { counter = 0 }
}
