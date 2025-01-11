package org.example

import de.articdive.jnoise.core.api.functions.Interpolation
import de.articdive.jnoise.generators.noise_parameters.fade_functions.FadeFunction
import de.articdive.jnoise.pipeline.JNoise
import org.opencv.core.*
import org.opencv.core.CvType.CV_32F
import org.opencv.core.CvType.CV_8UC3
import org.opencv.imgcodecs.Imgcodecs
import org.opencv.imgproc.Imgproc
import org.opencv.imgproc.Imgproc.GaussianBlur
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.pow
import kotlin.math.sin
import kotlin.random.Random


fun ProcessingDsl.process(inputImage: Mat, destinationImage: Mat, config: Config) {
    //slog3ToSrgb(inputImage, destinationImage)
    vignette(inputImage, config)
    halation(inputImage, destinationImage)
    grain(destinationImage, destinationImage, config)
    colorCast(destinationImage, config)
    //applyLUT(destinationImage)
    scratches(destinationImage)
    dust(destinationImage, config)
    shake(destinationImage, destinationImage)
    crushedLuminance(destinationImage, destinationImage, config)
}

fun ProcessingDsl.slog3ToSrgb(inputImage: Mat, destinationImage: Mat) {
    val lut by stored { createSlog3ToSrgbLut() }
    Core.LUT(inputImage, lut, destinationImage)
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

fun ProcessingDsl.grain(inputImage: Mat, destinationImage: Mat, config: Config) {
    val grainScale = 0.2
    val staticGrain = store(dependencies = listOf(config.grainStrength)) {
        val texture = Imgcodecs.imread("./assets/grain/grain3.jpeg")
        Core.multiply(texture, Scalar.all(config.grainStrength.toDouble()), texture)
        val size = Size(texture.width().toDouble() * grainScale, texture.height().toDouble() * grainScale)
        Imgproc.resize(texture, texture, size)
        Mat(texture, Rect(Point(), inputImage.size()))
    }
    val dynamicGrain = store { Mat() }
    val transformation = createRandomOffsetTransformation(inputImage)
    Imgproc.warpAffine(staticGrain, dynamicGrain, transformation, dynamicGrain.size(), 0, Core.BORDER_REFLECT)
    Core.add(inputImage, Scalar.all(150.0 * config.grainStrength), destinationImage)
    Core.subtract(destinationImage, dynamicGrain, destinationImage)
}

fun ProcessingDsl.crushedLuminance(inputImage: Mat, destinationImage: Mat, config: Config) {
    val contrastLut by stored { createSplineLUT(Knot(0.2f, 0.0f), Knot(0.8f, 1.0f)) }
    Core.LUT(inputImage, contrastLut, destinationImage)
    val lut by stored {
        createSplineLUT(
            Knot(0.0f, config.crushedLuminanceStrength * 0.2f),
            Knot(0.2f, 0.2f),
            Knot(0.8f, 0.8f),
            Knot(1.0f, 1.0f - config.crushedLuminanceStrength * 0.2f)
        )
    }
    Core.LUT(destinationImage, lut, destinationImage)
}

fun ProcessingDsl.vignette(image: Mat, config: Config) {
    val mask by stored(dependencies = listOf(config.vignetteStrength)) {
        createVignetteMask(
            config.vignetteStrength.toDouble(),
            image.size()
        )
    }
    Core.subtract(image, mask, image)
}

fun ProcessingDsl.scratches(image: Mat) {
    val textures by stored {
        val rawTextures = (0 until 10).map { i -> Imgcodecs.imread("./assets/scratches/$i.png") }
        (0 until 30).map {
            val transformation = buildTransformation {
                rotate(Random.Default.nextFloat() * PI * 2)
            }
            val texture = Mat()
            Imgproc.warpAffine(rawTextures.random(), texture, transformation, texture.size())
            texture
        }
    }
    val scratchAmount = if (Random.Default.nextFloat() > 0.9) {
        (Random.Default.nextFloat().pow(2) * 5).toInt()
    } else 0
    for (i in 0 until scratchAmount) {
        val texture = textures.random()
        val roiRect = Rect(
            Random.Default.nextInt(image.width() - texture.width()),
            Random.Default.nextInt(image.height() - texture.height()),
            texture.width(),
            texture.height()
        )
        val roi = Mat(image, roiRect)
        Core.add(roi, texture, roi)
    }
}

fun ProcessingDsl.dust(image: Mat, config: Config) {
    val dustScale = 0.7
    val staticDust = store(dependencies = listOf(config.dustStrength)) {
        val texture = Imgcodecs.imread("./assets/dust/dust-2.png")
        Core.multiply(texture, Scalar.all(config.dustStrength.toDouble()), texture)
        val size = Size(texture.width().toDouble() * dustScale, texture.height().toDouble() * dustScale)
        Imgproc.resize(texture, texture, size)
        Mat(texture, Rect(Point(), image.size()))
    }
    val dynamicDust = store { Mat() }
    if (Random.Default.nextFloat() > 0.05) return
    val transformation = createRandomOffsetTransformation(image)
    Imgproc.warpAffine(staticDust, dynamicDust, transformation, dynamicDust.size(), 0, Core.BORDER_REFLECT)
    Core.subtract(image, dynamicDust, image)
}

fun ProcessingDsl.colorCast(image: Mat, config: Config) {
    Core.add(image, config.colorCast.toScalar(), image)
}

fun ProcessingDsl.tone(image: Mat, config: Config) {
    val hsv by stored { Mat() }
    val mask by stored { Mat() }
    Imgproc.cvtColor(image, hsv, Imgproc.COLOR_BGR2HSV)
}

/*fun ProcessingDsl.applyLUT(image: Mat) {
    val lut by stored { loadLUT("./assets/luts/Kodak Portra 400 NC.cube") }
    Core.LUT(image, lut, image)
}*/

class TransformationBuilder {
    private fun new(values: List<Double>) = Mat.zeros(2, 3, CV_32F).apply {
        put(0, 0, values.map { it.toFloat() }.toFloatArray())
    }

    private var transformation: Mat? = null

    fun rotate(radians: Double) {
        val rotation = new(listOf(cos(radians), sin(radians), 0.0, -sin(radians), cos(radians), 0.0))
        transform(rotation)
    }

    fun translate(x: Double, y: Double) {
        val translation = new(listOf(1.0, 0.0, x, 0.0, 1.0, y))
    }

    private fun transform(transformation: Mat) {
        if (this.transformation == null) {
            this.transformation = transformation
            return
        }
        this.transformation = this.transformation!!.mul(transformation)
    }

    internal fun build() = transformation!!
}

fun buildTransformation(block: TransformationBuilder.() -> Unit): Mat = TransformationBuilder().apply(block).build()
