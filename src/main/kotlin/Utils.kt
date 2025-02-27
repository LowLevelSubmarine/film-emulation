import dev.benedikt.math.bezier.spline.FloatBezierSpline
import dev.benedikt.math.bezier.vector.Vector2F
import org.opencv.core.*
import org.opencv.core.CvType.CV_32F
import org.opencv.imgproc.Imgproc
import kotlin.math.log10
import kotlin.math.min
import kotlin.math.pow
import kotlin.math.sqrt
import kotlin.random.Random

data class Knot(val x: Float, val y: Float)

/**
 * Creates a gamma Look-Up Table (LUT) for image processing.
 *
 * @param gammaValue The gamma correction value to be applied. A higher value results in a brighter image,
 *                   while a lower value results in a darker image.
 * @return A Mat object representing the gamma LUT.
 */
fun createGammaLUT(gammaValue: Double): Mat {
    fun saturate(floatValue: Double): Byte {
        var value = Math.round(floatValue).toInt()
        value = if (value > 255) 255 else (if (value < 0) 0 else value)
        return value.toByte()
    }

    return createLUT { i -> saturate((i / 255.0).pow(gammaValue) * 255.0) }
}

/**
 * Creates a Lookup Table (LUT) using a spline interpolation based on the provided knots.
 *
 * @param knots A list of Knot objects representing the control points for the spline.
 * @return A Mat object representing the generated LUT.
 */
fun createSplineLUT(knots: List<Knot>): Mat {
    val spline = FloatBezierSpline<Vector2F>()
    spline.addKnots(*knots.map { Vector2F(x = it.x, y = it.y) }.toTypedArray())
    return createLUT { i -> (spline.getCoordinatesAt(i / 255.0f).y * 255.0f).toInt().toByte() }
}

/**
 * Creates a spline Look-Up Table (LUT) from the provided knots.
 *
 * @param knots A variable number of `Knot` objects representing the control points for the spline.
 * @return A spline LUT created from the provided knots.
 */
fun createSplineLUT(vararg knots: Knot) = createSplineLUT(knots.toList())

/**
 * Creates a linear Look-Up Table (LUT) based on the provided knots.
 *
 * @param knots A list of `Knot` objects that define the points for the linear mapping.
 * @return A `Mat` object representing the linear LUT.
 */
fun createLinearLUT(knots: List<Knot>): Mat {
    val mapping = createLinearMapping(knots)
    return createLUT { i -> (mapping(i / 255.0f) * 255.0).toInt().toByte() }
}

/**
 * Creates a linear mapping function based on a list of points (knots).
 * The function will interpolate the y-values for given x-values using linear interpolation.
 *
 * @param points A list of Knot objects representing the points to be used for interpolation.
 *               Each Knot object should have x and y properties.
 *               The list should contain at least two points.
 * @return A function that takes a Float input and returns the interpolated Float output.
 *         The function will clamp the output to the y-values of the first and last points
 *         if the input is outside the range of the x-values of the provided points.
 */
fun createLinearMapping(points: List<Knot>): (Float) -> Float {
    // Ensure the points are sorted by their x-coordinate
    val sortedPoints = points.sortedBy { it.x }

    return { input ->
        when {
            // If input is less than the smallest x, clamp to the first y
            input <= sortedPoints.first().x -> sortedPoints.first().y

            // If input is greater than the largest x, clamp to the last y
            input >= sortedPoints.last().x -> sortedPoints.last().y

            // Otherwise, find the segment containing the input
            else -> {
                // Find the two points the input lies between
                val (p1, p2) = sortedPoints.zipWithNext().first { (p1, p2) ->
                    input >= p1.x && input <= p2.x
                }

                // Perform linear interpolation
                val t = (input - p1.x) / (p2.x - p1.x) // Fraction of the way between p1.x and p2.x
                p1.y + t * (p2.y - p1.y)             // Interpolated y value
            }
        }
    }
}

/**
 * Creates a Look-Up Table (LUT) for converting S-Log3 encoded values to sRGB values.
 *
 * @return A matrix (Mat) representing the LUT for S-Log3 to sRGB conversion.
 */
fun createSlog3ToSrgbLut(): Mat = createLUT { i ->
    val normalizedValue = i / 255.0
    val normalizedSrgbValue = mapSlrToSrgb(mapSlog3ToSlr(normalizedValue))
    (normalizedSrgbValue * 255.0).toInt().toByte()
}

/**
 * Creates a Look-Up Table (LUT) using the provided function.
 *
 * @param fn A function that takes an integer input (ranging from 0 to 255) and returns a Byte.
 * @return A Mat object representing the LUT, with 1 row and 256 columns, of type CV_8U.
 */
private fun createLUT(fn: (i: Int) -> Byte): Mat {
    val lut = Mat(1, 256, CvType.CV_8U)
    val lutData = ByteArray(256)
    for (i in 0 until 256) {
        lutData[i] = fn(i)
    }
    lut.put(0, 0, lutData)
    return lut
}

/**
 * Converts a given S-Log3 value to a standard linear representation (SLR).
 *
 * @param slog3Value The S-Log3 value to be converted.
 * @return The corresponding linear value, clamped between 0.0 and 1.0.
 */
// https://pro.sony/s3/cms-static-content/uploadfile/06/1237494271406.pdf
private fun mapSlog3ToSlr(slog3Value: Double): Double {
    // Constants for S-Log3
    val a = 0.037584
    val b = 0.01125000
    val c = 0.00807360
    val d = 0.432699
    val e = 0.030001222851889303 // Derived value for e
    val m = 0.432699

    // Threshold for logarithmic vs linear
    val threshold = m * log10(c) + d

    val out = if (slog3Value >= threshold) {
        10.0.pow((slog3Value - d) / m) - c
    } else {
        (slog3Value - e) * b / a
    }
    return (out * 0.01).coerceIn(0.0, 1.0)
}

/**
 * Converts a linear SLR (Standard Light Response) value to sRGB.
 *
 * @param slrValue The linear light intensity value (SLR), typically in the range [0,1].
 * @return The gamma-corrected sRGB value.
 */
private fun mapSlrToSrgb(slrValue: Double): Double {
    val a = 0.055
    return if (slrValue <= 0.0031308) {
        12.92 * slrValue
    } else {
        (1 + a) * slrValue.pow(1 / 2.4) - a
    }
}

/**
 * Creates a vignette mask with the specified strength and size.
 *
 * @param strength The strength of the vignette effect. A higher value results in a stronger vignette.
 * @param size The size of the mask to be created.
 * @return A Mat object representing the vignette mask.
 */
fun createVignetteMask(strength: Double, size: Size): Mat {
    val mask = Mat(size, CvType.CV_8UC3)
    val center = Point(size.height / 2, size.width / 2)
    val maxDist = sqrt(center.x.pow(2.0) + center.y.pow(2.0))
    for (x in 0 until size.height.toInt()) {
        for (y in 0 until size.width.toInt()) {
            val delta = Point(x - center.x, y - center.y)
            val dist = sqrt(delta.x.pow(2.0) + delta.y.pow(2.0)) / maxDist
            val value = min((dist * strength * 256).toInt(), 255).toByte()
            mask.at(Byte::class.java, x, y).v3c = Mat.Tuple3(value, value, value)
        }
    }
    return mask
}

/**
 * Creates a random offset transformation matrix for the given image.
 *
 * @param image The input image for which the transformation matrix is created.
 * @return A 2x3 transformation matrix with random offsets.
 */
fun createRandomOffsetTransformation(image: Mat): Mat {
    return Mat.zeros(2, 3, CV_32F).apply {
        put(0, 0, floatArrayOf(1.0F))
        put(1, 1, floatArrayOf(1.0F))
        put(0, 2, floatArrayOf(Random.Default.nextFloat() * image.width()))
        put(1, 2, floatArrayOf(Random.Default.nextFloat() * image.height()))
    }
}

/**
 * Adjusts the luminance of the given image by modifying its contrast and brightness.
 *
 * @param image The source image to be adjusted.
 * @param destination The destination image where the adjusted result will be stored.
 * @param contrast The contrast factor to be applied. Default is 1.0 (no change).
 * @param brightness The brightness factor to be applied. Default is 1.0 (no change).
 */
fun adjustLuminance(image: Mat, destination: Mat, contrast: Number = 1.0, brightness: Number = 1.0) {
    image.convertTo(
        destination,
        -1,
        contrast.toDouble(),
        127.0 - contrast.toDouble() * 127.0 + (255.0 * brightness.toDouble() - 255.0)
    )
}

/**
 * Adjusts the saturation of an image.
 *
 * @param image The source image in BGR color space.
 * @param destination The destination image where the result will be stored.
 * @param saturation The factor by which to adjust the saturation.
 *                   A value of 1.0 means no change, less than 1.0 decreases saturation,
 *                   and greater than 1.0 increases saturation.
 */
fun adjustSaturation(image: Mat, destination: Mat, saturation: Number) {
    Imgproc.cvtColor(image, destination, Imgproc.COLOR_BGR2HSV)
    val sat = Mat()
    Core.extractChannel(destination, sat, 1)
    Core.multiply(sat, Scalar.all(saturation.toDouble()), sat)
    Core.insertChannel(sat, destination, 1)
    Imgproc.cvtColor(image, destination, Imgproc.COLOR_HSV2BGR)
}


/**
 * Extension function to convert an integer to the next odd number.
 *
 * @return Int The next odd number.
 */
fun Int.odd() = this + 1 - this % 2

/*
fun loadLUT(cubeFilePath: String): Mat {
    val file = File(cubeFilePath)
    val regex = Regex("^(?<key>\\w+) (?<value>.+)\$")

    //var lutSize = 33 // default size
    val rgbValues = mutableListOf<FloatArray>()

    file.forEachLine { line ->
        if (line.startsWith("#") || line.isBlank()) return@forEachLine
        val config = regex.matchEntire(line)?.let { it.groups["key"]!!.value to it.groups["value"]!!.value }
        if (config != null) {
            //when (config.first) {
            //    "LUT_3D_SIZE" -> lutSize = config.second.toInt()
            //}
            return@forEachLine
        }
        rgbValues.add(line.split(" ").map { it.toFloat() }.toFloatArray())
    }

    val length = rgbValues.size.toFloat().pow(1/3.toFloat())


    fun getColor(input: ByteArray): ByteArray {
        fun mapInput(input: Byte) = input.toFloat() / 255 * length
        val index = (mapInput(input[0]) * 64 * 64).toInt() + (mapInput(input[1]) * 64).toInt() + mapInput(input[2]).toInt()
        return rgbValues[index].map { (it * 255).toInt().toByte() }.toByteArray()
    }

    val lut = Mat(1, 256, CvType.CV_8UC3)
    for (i in 0 until 256) {
        lut.put(0, i, getColor())
    }

    return lut
}

private fun <T> List<T>.takeEquallyDistributed(amount: Int): List<T> {
    val list = mutableListOf<T>()
    val offset = size / (amount - 1)
    for (i in 0 until size - offset step offset) {
        list.add(get(i))
    }
    list.add(get(size - 1))
    return list
}
*/