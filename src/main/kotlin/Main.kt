import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.server.plugins.cors.routing.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.utils.io.*
import kotlinx.coroutines.*
import kotlinx.serialization.json.Json
import nu.pattern.OpenCV
import org.opencv.core.Mat
import org.opencv.core.MatOfByte
import org.opencv.imgcodecs.Imgcodecs
import org.opencv.videoio.VideoCapture
import org.opencv.videoio.Videoio
import kotlin.time.Duration
import kotlin.time.Duration.Companion.days
import kotlin.time.Duration.Companion.seconds
import kotlin.time.TimeSource
import kotlin.time.measureTime

data class Ref<T>(var value: T)

/**
 * Main entry point of the application.
 * Initializes OpenCV, sets up the server, and starts video streaming.
 */
suspend fun main() = coroutineScope {
    OpenCV.loadLocally()
    val configRef = Ref(Config.default)
    val frameReceivers = mutableListOf<suspend (bytes: ByteArray) -> Unit>()
    launch { createVideoStream(configRef, 24, { frame -> frameReceivers.forEach { it(frame) }}) }

    embeddedServer(Netty, 8080) {
        install(CORS) {
            allowOrigins { _ -> true }
            allowMethod(HttpMethod.Get)
            allowMethod(HttpMethod.Post)
            allowHeader(HttpHeaders.ContentType)
        }

        println(configRef.value)
        routing {
            get("/") {
                call.respond(Json.encodeToString(configRef.value))
            }
            post("/") {
                val receivedConfig = call.receive<String>()
                println("Received config: $receivedConfig")
                configRef.value = Json.decodeFromString(receivedConfig)
                println("updated config: $configRef")
                call.respond(HttpStatusCode.OK)
            }
            get("/stream") {
                call.respondBytesWriter(ContentType("multipart", "x-mixed-replace; boundary=frame")) {
                    val onNewFrameBytes: suspend (bytes: ByteArray) -> Unit = { bytes: ByteArray ->
                        if (!isClosedForWrite) {
                            writeByteArray("--frame\r\n".toByteArray())
                            writeByteArray("Content-Type: image/jpeg\r\n\r\n".toByteArray())
                            writeByteArray(bytes)
                            writeByteArray("\r\n".toByteArray())
                            flush()
                        }
                    }

                    frameReceivers.add(onNewFrameBytes)
                    onClose { frameReceivers.remove(onNewFrameBytes) }
                    awaitCancellation()
                }
            }
            get("/reset") {
                configRef.value = Config.default
                call.respond(Json.encodeToString(configRef.value))
            }
        }
    }.start(wait = true)

    Unit
}

/**
 * Creates a video stream from the default camera and processes frames.
 *
 * @param configRef Reference to the configuration object.
 * @param targetFrameRate Target frame rate for the video stream.
 * @param onFrameBytes Callback function to handle the processed frame bytes.
 */
suspend fun createVideoStream(configRef: Ref<Config>, targetFrameRate: Int, onFrameBytes: suspend (bytes: ByteArray) -> Unit) {
    coroutineScope {
        val videoCapture = VideoCapture(0)  // cameraIndex = 0
        val fpsCounter = FpsCounter()

        videoCapture.set(Videoio.CAP_PROP_FPS, targetFrameRate.toDouble())

        launch {
            while (isActive) {
                try {
                    Thread.sleep(2000)
                    println("fps: ${fpsCounter.fps}")
                } catch (e: InterruptedException) {
                    // interrupting this is ok
                }
            }
        }

        var currentFrame: Mat? = null

        launch {
            val processing = ProcessingDsl()
            val processedFrame = Mat()
            while (isActive) {
                if (currentFrame == null) continue
                val frame = currentFrame!!
                processing.apply {
                    reset()
                    measureTime("processing") { process(frame, processedFrame, configRef.value) }
                }
                currentFrame = null

                launch {
                    val buffer = run {
                        val buffer = MatOfByte()
                        Imgcodecs.imencode(".jpg", processedFrame, buffer)
                        buffer.toArray()
                    }
                    onFrameBytes(buffer)
                }
            }
        }

        val capturedFrame = Mat()
        while (isActive) {
            videoCapture.read(capturedFrame)
            if (currentFrame != null) {
                println("processing couldn't keep up with frame rate")
                continue
            }
            currentFrame = capturedFrame
            fpsCounter.count()
        }

        videoCapture.release()
    }
}

/**
 * Class to count frames per second (FPS).
 *
 * @param sampleDuration Duration over which to sample FPS.
 */
class FpsCounter(
    private val sampleDuration: Duration = 2.seconds
) {
    private val samples = mutableListOf<TimeSource.Monotonic.ValueTimeMark>()

    /**
     * Records a frame count at the current time.
     */
    fun count() {
        val now = TimeSource.Monotonic.markNow()
        samples.removeAll { mark -> now.minus(mark) > sampleDuration }
        samples.add(now)
    }

    /**
     * Gets the current FPS.
     */
    val fps: Int
        get() {
            val now = TimeSource.Monotonic.markNow()
            val second = 1.seconds
            return samples.toList().count { mark -> now.minus(mark) < second }
        }
}
