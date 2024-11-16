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

