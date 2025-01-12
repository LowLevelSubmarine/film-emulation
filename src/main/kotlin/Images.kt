package org.example

import nu.pattern.OpenCV
import org.opencv.core.Mat
import org.opencv.core.Size
import org.opencv.imgcodecs.Imgcodecs
import org.opencv.imgproc.Imgproc

val config = Config.default.copy(
    crushedLuminanceStrength = 0.2f,

)

fun main() {
    OpenCV.loadLocally()
    val path = "./assets/spok.png"
    val source = Imgcodecs.imread(path, Imgcodecs.IMREAD_COLOR)
    val processing = ProcessingDsl()
    val destination = Mat()
    processing.apply {
        Imgproc.resize(source, destination, source.size() / 5)
        adjustLuminance(destination, destination, contrast = 2.0, brightness = 1.3)
        Imgcodecs.imwrite("$path-im.png", destination)
        process(destination, destination, config)
    }
    Imgcodecs.imwrite("$path-edit.png", destination)
}

private operator fun Size.div(i: Number) = Size(this.width / i.toDouble(), this.height / i.toDouble())
