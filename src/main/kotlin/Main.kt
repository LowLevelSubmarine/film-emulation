package org.example

import nu.pattern.OpenCV
import org.opencv.core.Mat
import org.opencv.highgui.HighGui
import org.opencv.highgui.ImageWindow
import org.opencv.videoio.VideoCapture
import kotlin.time.Duration
import kotlin.time.Duration.Companion.seconds
import kotlin.time.TimeSource


fun main() {
    OpenCV.loadLocally()

    ImageWindow("test", 0)
    val videoCapture = VideoCapture(0)  // cameraIndex = 0
    val inputImage = Mat()
    val processedImage = Mat()
    val processing = ProcessingDsl()
    val fpsCounter = FpsCounter()

    async {
        while (!Thread.interrupted()) {
            Thread.sleep(1000)
            println("fps: ${fpsCounter.fps}")
        }
    }

    // Start streaming
    do {
        videoCapture.read(inputImage)
        processing.apply {
            reset()
            process(inputImage, processedImage)
            fpsCounter.count()
        }
        HighGui.imshow("test", processedImage)
    } while (HighGui.waitKey(1) != 27)

    // Close Window
    HighGui.destroyWindow("test")
    HighGui.waitKey(1) // actually closes the window
    videoCapture.release()
}

fun async(block: () -> Unit) = Thread(block).start()

class FpsCounter(
    private val sampleDuration: Duration = 2.seconds
) {
    private val samples = mutableListOf<TimeSource.Monotonic.ValueTimeMark>()

    fun count() {
        val now = TimeSource.Monotonic.markNow()
        samples.removeAll { mark -> now.minus(mark) > sampleDuration }
        samples.add(now)
    }

    val fps: Int
        get() {
            val now = TimeSource.Monotonic.markNow()
            val second = 1.seconds
            return samples.count { mark -> now.minus(mark) < second }
        }
}
