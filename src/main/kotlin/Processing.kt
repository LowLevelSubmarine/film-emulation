package org.example

import de.articdive.jnoise.core.api.functions.Interpolation
import de.articdive.jnoise.generators.noise_parameters.fade_functions.FadeFunction
import de.articdive.jnoise.pipeline.JNoise
import org.opencv.core.*
import org.opencv.core.CvType.*
import org.opencv.imgcodecs.Imgcodecs
import org.opencv.imgproc.Imgproc
import org.opencv.imgproc.Imgproc.GaussianBlur
import kotlin.math.pow
import kotlin.random.Random


fun ProcessingDsl.process(inputImage: Mat, destinationImage: Mat) {
    vignette(inputImage)
    halation(inputImage, destinationImage)
    grain(destinationImage, destinationImage)
    crushedLuminance(destinationImage, destinationImage)
    scratches(destinationImage)
    shake(destinationImage, destinationImage)
}

fun ProcessingDsl.shake(inputImage: Mat, destinationImage: Mat) {
    val jitterScale = 0.0005f
    val weaveNoiseSpeed = 0.015f
    val weaveNoiseScale = 0.01f

    var weaveNoiseOffset by stored { 0.0 }
    val weaveNoiseGenerator =
        store { JNoise.newBuilder().perlin(3301, Interpolation.COSINE, FadeFunction.QUINTIC_POLY).build() }
    val x = Random.nextFloat() * jitterScale + weaveNoiseGenerator.evaluateNoise(weaveNoiseOffset, 0.0)
        .toFloat() * weaveNoiseScale
    val y = Random.nextFloat() * jitterScale + weaveNoiseGenerator.evaluateNoise(weaveNoiseOffset, 100.0)
        .toFloat() * weaveNoiseScale * 0.5f

    weaveNoiseOffset += weaveNoiseSpeed

    val transformation = Mat.zeros(2, 3, CV_32F).apply {
        put(0, 0, floatArrayOf(1.0F))
        put(1, 1, floatArrayOf(1.0F))
        put(0, 2, floatArrayOf(inputImage.width().toFloat() * x))
        put(1, 2, floatArrayOf(inputImage.height().toFloat() * y))
    }
    Imgproc.warpAffine(
        inputImage,
        destinationImage,
        transformation,
        destinationImage.size(),
        0,
        Core.BORDER_REFLECT
    )
}

fun ProcessingDsl.halation(inputImage: Mat, destinationImage: Mat) {
    val redChannelImage = store { Mat() }
    Core.extractChannel(inputImage, redChannelImage, 2) // red channel isolated
    val gammaLut = store { createGammaLUT(20.0) }
    Core.LUT(redChannelImage, gammaLut, redChannelImage)
    GaussianBlur(redChannelImage, redChannelImage, Size(99.0, 99.0), 0.0) // blurred red channel
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

fun ProcessingDsl.crushedLuminance(inputImage: Mat, destinationImage: Mat) {
    val contrastLut by stored { createSplineLUT(Knot(0.2f, 0.0f), Knot(0.8f, 1.0f)) }
    Core.LUT(inputImage, contrastLut, destinationImage)
    val lut by stored { createSplineLUT(Knot(0.0f, 0.1f), Knot(0.2f, 0.2f), Knot(0.8f, 0.8f), Knot(1.0f, 0.9f)) }
    Core.LUT(destinationImage, lut, destinationImage)
}

fun ProcessingDsl.vignette(image: Mat) {
    val mask by stored { createVignetteMask(0.1, image.size()) }
    Core.subtract(image, mask, image)
}

