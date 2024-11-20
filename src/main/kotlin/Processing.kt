package org.example

import org.opencv.core.*
import org.opencv.core.CvType.*
import org.opencv.imgcodecs.Imgcodecs
import org.opencv.imgproc.Imgproc
import org.opencv.imgproc.Imgproc.GaussianBlur
import kotlin.random.Random


fun ProcessingDsl.process(inputImage: Mat, destinationImage: Mat) {
    halation(inputImage, destinationImage)
    grain(destinationImage, destinationImage)
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
    val grainScale = 0.2
    val grainStrength = 0.15
    val staticGrain = store {
        val texture = Imgcodecs.imread("./grain3.jpeg")
        Core.multiply(texture, Scalar.all(grainStrength), texture)
        val size = Size(texture.width().toDouble() * grainScale, texture.height().toDouble() * grainScale)
        Imgproc.resize(texture, texture, size)
        Mat(texture, Rect(Point(), inputImage.size()))
    }
    val dynamicGrain = store { Mat() }
    val transformation = Mat.zeros(2, 3, CV_32F).apply {
        put(0, 0, floatArrayOf(1.0F))
        put(1, 1, floatArrayOf(1.0F))
        put(0, 2, floatArrayOf(Random.Default.nextFloat() * inputImage.width()))
        put(1, 2, floatArrayOf(Random.Default.nextFloat() * inputImage.height()))
    }
    Imgproc.warpAffine(staticGrain, dynamicGrain, transformation, dynamicGrain.size(), 0, Core.BORDER_REFLECT)

    Core.subtract(inputImage, dynamicGrain, destinationImage)
    //dynamicGrain.copyTo(destinationImage)
}
