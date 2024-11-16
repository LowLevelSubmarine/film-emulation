package org.example

import org.opencv.core.Core
import org.opencv.core.CvType.CV_8UC3
import org.opencv.core.Mat
import org.opencv.core.Size
import org.opencv.imgcodecs.Imgcodecs
import org.opencv.imgproc.Imgproc.GaussianBlur


fun ProcessingDsl.process(inputImage: Mat, destinationImage: Mat) {
    halation(inputImage, destinationImage)
    //grain(inputImage, destinationImage)
}

fun ProcessingDsl.halation(inputImage: Mat, destinationImage: Mat) {
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
