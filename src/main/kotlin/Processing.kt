import de.articdive.jnoise.core.api.functions.Interpolation
import de.articdive.jnoise.generators.noise_parameters.fade_functions.FadeFunction
import de.articdive.jnoise.pipeline.JNoise
import org.opencv.core.*
import org.opencv.core.CvType.CV_32F
import org.opencv.core.CvType.CV_8UC3
import org.opencv.imgcodecs.Imgcodecs
import org.opencv.imgproc.Imgproc
import org.opencv.imgproc.Imgproc.GaussianBlur
import kotlin.math.*
import kotlin.random.Random

/**
 * Processes an input image and applies various film emulation effects to the destination image.
 *
 * @param inputImage The source image to be processed.
 * @param destinationImage The image where the processed result will be stored.
 * @param config Configuration settings for the processing effects.
 */
fun ProcessingDsl.process(inputImage: Mat, destinationImage: Mat, config: Config) {
    //slog3ToSrgb(inputImage, destinationImage)
    measureTime("vignette") { vignette(inputImage, config) }
    measureTime("halation") { halation(inputImage, destinationImage, config) }
    measureTime("grain") { grain(destinationImage, destinationImage, config) }
    measureTime("colorCast") { colorCast(destinationImage, config) }
    measureTime("scratches") { scratches(destinationImage) }
    measureTime("dust") { dust(destinationImage, config) }
    measureTime("shake") { shake(destinationImage, destinationImage, config) }
    measureTime("crushedLuminance") { crushedLuminance(destinationImage, destinationImage, config) }
    measureTime("tone") { tone(destinationImage, config) }
}

/**
 * Converts an image from S-Log3 color space to sRGB color space using a Look-Up Table (LUT).
 *
 * @receiver ProcessingDsl The DSL context in which this function is called.
 * @param inputImage The input image in S-Log3 color space.
 * @param destinationImage The output image in sRGB color space.
 */
fun ProcessingDsl.slog3ToSrgb(inputImage: Mat, destinationImage: Mat) {
    val lut by stored { createSlog3ToSrgbLut() }
    Core.LUT(inputImage, lut, destinationImage)
}

/**
 * Applies a vignette effect to the given image using the specified configuration.
 *
 * @receiver The DSL context for processing.
 * @param image The image to which the vignette effect will be applied. This is a Mat object representing the image.
 * @param config The configuration object containing the vignette strength.
 */
fun ProcessingDsl.vignette(image: Mat, config: Config) {
    val mask by stored(dependencies = listOf(config.vignetteStrength)) {
        createVignetteMask(
            config.vignetteStrength.toDouble(),
            image.size()
        )
    }
    Core.subtract(image, mask, image)
}

/**
 * Applies a halation effect to the input image and stores the result in the destination image.
 *
 * @param inputImage The source image to which the halation effect will be applied.
 * @param destinationImage The image where the result will be stored.
 * @param config The configuration object containing parameters for the halation effect.
 */
fun ProcessingDsl.halation(inputImage: Mat, destinationImage: Mat, config: Config) {
    val halationRes = 0.5
    val redChannelImage = store { Mat() }
    Core.extractChannel(inputImage, redChannelImage, 2) // red channel isolated
    val gammaLut = store(listOf(config.halationThreshold)) { createGammaLUT(config.halationThreshold.toDouble()) }
    Imgproc.resize(redChannelImage, redChannelImage, Size(), halationRes, halationRes, Imgproc.INTER_LINEAR)
    Core.LUT(redChannelImage, gammaLut, redChannelImage)
    measureTime("halation: gaussian blur") {
        GaussianBlur(
            redChannelImage,
            redChannelImage,
            config.halationGaussianSize.toSize().map { (it * halationRes).roundToInt().odd().toDouble() },
            config.halationSigmaX.toDouble()
        ) // blurred red channel
    }
    adjustLuminance(redChannelImage, redChannelImage, brightness = config.halationStrength.toDouble())
    Imgproc.resize(redChannelImage, redChannelImage, Size(), 1.0 / halationRes, 1.0 / halationRes, Imgproc.INTER_LINEAR)
    val threeChannelImage by stored { Mat.zeros(inputImage.size(), CV_8UC3) }  // black image with 3 channels
    Core.insertChannel(redChannelImage, threeChannelImage, 2)
    Core.add(inputImage, threeChannelImage, destinationImage)
}

/**
 * Applies a grain effect to the input image and stores the result in the destination image.
 *
 * @param inputImage The source image to which the grain effect will be applied.
 * @param destinationImage The image where the result will be stored.
 * @param config The configuration object containing the grain strength.
 */
fun ProcessingDsl.grain(inputImage: Mat, destinationImage: Mat, config: Config) {
    val grainScale = 0.4
    val staticGrain = store(dependencies = listOf(config.grainStrength)) {
        val texture = Imgcodecs.imread("./assets/grain/grain4.jpeg")
        Core.multiply(texture, Scalar.all(config.grainStrength.toDouble()), texture)
        val size = Size(texture.width().toDouble() * grainScale, texture.height().toDouble() * grainScale)
        Imgproc.resize(texture, texture, size)
        Mat(texture, Rect(Point(), inputImage.size()))
    }
    val dynamicGrain = store { Mat() }
    val transformation = createRandomOffsetTransformation(inputImage)
    Imgproc.warpAffine(staticGrain, dynamicGrain, transformation, dynamicGrain.size(), 0, Core.BORDER_REFLECT)
    Core.add(inputImage, Scalar.all(150.0 * config.grainStrength.toDouble()), destinationImage)
    Core.subtract(destinationImage, dynamicGrain, destinationImage)
}

/**
 * Applies a color cast to the given image using the specified configuration.
 *
 * @param image The image to which the color cast will be applied. This is a Mat object representing the image.
 * @param config The configuration containing the color cast information. This should include a colorCast property that can be converted to a Scalar.
 */
fun ProcessingDsl.colorCast(image: Mat, config: Config) {
    Core.add(image, config.colorCast.toScalar(), image)
}

/**
 * Applies random scratch textures to the given image.
 *
 * @param image The image to which the scratch textures will be applied.
 */
fun ProcessingDsl.scratches(image: Mat) {
    val textures by stored {
        val rawTextures = (0 until 10).map { i -> Imgcodecs.imread("./assets/scratches/$i.png") }
        (0 until 30).map {
            val transformation = buildTransformation {
                rotate(Random.nextFloat() * PI * 2)
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

/**
 * Applies a dust effect to the given image using the provided configuration.
 *
 * @param image The image to which the dust effect will be applied.
 * @param config The configuration object containing the dust strength.
 *
 * @throws IllegalArgumentException if the dust texture cannot be loaded.
 */
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
    Core.add(image, dynamicDust, image)
}

/**
 * Applies a shake effect to the input image and stores the result in the destination image.
 *
 * @param inputImage The source image to which the shake effect will be applied.
 * @param destinationImage The image where the result will be stored.
 * @param config The configuration object containing parameters for the shake effect.
 */
fun ProcessingDsl.shake(inputImage: Mat, destinationImage: Mat, config: Config) {
    var weaveNoiseOffset by stored { 0.0 }
    val weaveNoiseGenerator =
        store { JNoise.newBuilder().perlin(3301, Interpolation.COSINE, FadeFunction.QUINTIC_POLY).build() }
    val x = Random.nextFloat() * config.jitterScale + weaveNoiseGenerator.evaluateNoise(weaveNoiseOffset, 0.0)
        .toFloat() * config.weaveNoiseScale
    val y = Random.nextFloat() * config.jitterScale + weaveNoiseGenerator.evaluateNoise(weaveNoiseOffset, 100.0)
        .toFloat() * config.weaveNoiseScale * 0.5f

    weaveNoiseOffset += config.weaveNoiseSpeed

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

/**
 * Applies a crushed luminance effect to the input image and stores the result in the destination image.
 *
 * @param inputImage The source image to be processed.
 * @param destinationImage The image where the processed result will be stored.
 * @param config The configuration object containing the strength of the crushed luminance effect.
 */
fun ProcessingDsl.crushedLuminance(inputImage: Mat, destinationImage: Mat, config: Config) {
    val contrastLut by stored { createSplineLUT(Knot(0.2f, 0.0f), Knot(0.8f, 1.0f)) }
    Core.LUT(inputImage, contrastLut, destinationImage)
    val lut by stored(listOf(config.crushedLuminanceStrength)) {
        createSplineLUT(
            Knot(0.0f, config.crushedLuminanceStrength * 0.2f),
            Knot(0.2f, 0.2f),
            Knot(0.8f, 0.8f),
            Knot(1.0f, 1.0f - config.crushedLuminanceStrength * 0.2f)
        )
    }
    Core.LUT(destinationImage, lut, destinationImage)
}

/**
 * Applies a tone mapping effect to the given image based on the provided configuration.
 *
 * @param image The input image to be processed.
 * @param config The configuration object containing parameters for the tone mapping.
 */
fun ProcessingDsl.tone(image: Mat, config: Config) {
    val hsv by stored { Mat() }
    val hue by stored { Mat() }
    val sat by stored { Mat() }
    val lum by stored { Mat() }
    val orangeTonesMask by stored { Mat() }
    Imgproc.cvtColor(image, hsv, Imgproc.COLOR_BGR2HSV)
    Core.extractChannel(hsv, hue, 0)
    Core.extractChannel(hsv, sat, 1)
    Core.extractChannel(hsv, lum, 2)
    Core.multiply(hue, Scalar.all(255.0 / 179.0), hue)
    val orangeRangeLut by stored {
        createLinearLUT(
            listOf(
                Knot(0.2f, 1.0f),
                Knot(0.3f, 0.0f),
                Knot(0.9f, 0.0f),
                Knot(1.0f, 1.0f),
            )
        )
    }
    Core.LUT(hue, orangeRangeLut, orangeTonesMask)
    Core.multiply(orangeTonesMask, sat, orangeTonesMask, 1.0 / 255.0 * 1)
    Core.multiply(orangeTonesMask, lum, orangeTonesMask, 1.0 / 255.0 * 2.0)
    adjustLuminance(orangeTonesMask, orangeTonesMask, contrast = 2.0, brightness = 1.5)
    val orangeTonesMask3C by stored { Mat() }
    Core.merge(listOf(orangeTonesMask, orangeTonesMask, orangeTonesMask), orangeTonesMask3C)
    val orangeTonesMask3CI by stored { Mat() }
    Core.absdiff(orangeTonesMask3C, Scalar.all(255.0), orangeTonesMask3CI)
    val warmColor by stored(listOf(config.warmColorCast)) {
        val mat = Mat.zeros(image.size(), CvType.CV_8UC3)
        mat.setTo(config.warmColorCast.toScalar())
        mat
    }
    val warmColorPart by stored { Mat() }
    Core.multiply(warmColor, orangeTonesMask3C, warmColorPart, 1.0 / 255.0)
    val coldColor by stored(listOf(config.coldColorCast)) {
        val mat = Mat.zeros(image.size(), CvType.CV_8UC3)
        mat.setTo(config.coldColorCast.toScalar())
        mat
    }
    val coldColorPart by stored { Mat() }
    Core.multiply(coldColor, orangeTonesMask3CI, coldColorPart, 1.0 / 255.0)
    Core.add(image, warmColorPart, image)
    Core.add(image, coldColorPart, image)
}

/**
 * A builder class for creating and manipulating transformation matrices.
 */
class TransformationBuilder {
    /**
     * Creates a new 2x3 matrix of type CV_32F and populates it with the given values.
     *
     * @param values A list of Double values to be inserted into the matrix. The list should contain exactly 6 elements.
     * @return A Mat object representing a 2x3 matrix with the provided values.
     * @throws IllegalArgumentException if the size of the values list is not 6.
     */
    private fun new(values: List<Double>) = Mat.zeros(2, 3, CV_32F).apply {
        put(0, 0, values.map { it.toFloat() }.toFloatArray())
    }

    private var transformation: Mat? = null

    /**
     * Rotates the current transformation matrix by the specified angle in radians.
     *
     * @param radians The angle of rotation in radians.
     */
    fun rotate(radians: Double) {
        val rotation = new(listOf(cos(radians), sin(radians), 0.0, -sin(radians), cos(radians), 0.0))
        transform(rotation)
    }

    /**
     * Translates the current position by the given x and y offsets.
     *
     * @param x The horizontal offset by which to translate.
     * @param y The vertical offset by which to translate.
     */
    fun translate(x: Double, y: Double) {
        val translation = new(listOf(1.0, 0.0, x, 0.0, 1.0, y))
    }

    /**
     * Applies a transformation matrix to the current transformation.
     *
     * @param transformation The transformation matrix to be applied.
     */
    private fun transform(transformation: Mat) {
        if (this.transformation == null) {
            this.transformation = transformation
            return
        }
        this.transformation = this.transformation!!.mul(transformation)
    }

    /**
     * Builds and returns the transformation object.
     *
     * @return The transformation object that has been built.
     * @throws IllegalStateException if the transformation object is not initialized.
     */
    internal fun build() = transformation!!
}

/**
 * Builds a transformation matrix using the provided block of transformation instructions.
 *
 * @param block A lambda with receiver of type `TransformationBuilder` that defines the transformation instructions.
 * @return A `Mat` object representing the transformation matrix.
 */
fun buildTransformation(block: TransformationBuilder.() -> Unit): Mat = TransformationBuilder().apply(block).build()
