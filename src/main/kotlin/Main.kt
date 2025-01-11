package org.example

import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.server.plugins.cors.routing.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.utils.io.*
import kotlinx.serialization.json.Json
import nu.pattern.OpenCV
import org.opencv.core.Mat
import org.opencv.core.MatOfByte
import org.opencv.imgcodecs.Imgcodecs
import org.opencv.videoio.VideoCapture
import kotlin.time.Duration
import kotlin.time.Duration.Companion.seconds
import kotlin.time.TimeSource


data class Ref<T>(var value: T)

fun main() {
    OpenCV.loadLocally()
    val configRef = Ref(Config.default)

    embeddedServer(Netty, 8080) {
        install(CORS) {
            allowOrigins { _ -> true }
            allowMethod(HttpMethod.Get)
            allowMethod(HttpMethod.Post)
            allowHeader(HttpHeaders.ContentType)
        }

        routing {
            get("/") {
                call.respond(Json.encodeToString(configRef.value))
            }
            post("/") {
                val receivedConfig = call.receive<String>()
                configRef.value = Json.decodeFromString(receivedConfig)
                println("updated config: $configRef")
                call.respond(HttpStatusCode.OK)
            }
            get("/stream") {
                call.respondWithVideoStream(configRef, targetFrameRate = 24)
            }
        }
    }.start(wait = true)
}

suspend fun RoutingCall.respondWithVideoStream(config: Ref<Config>, targetFrameRate: Int) = respondBytesWriter(
    contentType = ContentType("multipart", "x-mixed-replace; boundary=frame")
) {
    val videoCapture = VideoCapture(0)  // cameraIndex = 0
    val fpsCounter = FpsCounter()
    val fpsThread = async {
        while (true) {
            try {
                Thread.sleep(5000)
                println("fps: ${fpsCounter.fps}")
            } catch (e: InterruptedException) {
                // interrupting this is ok
            }
        }
    }

    var closed = false
    onClose { closed = true }

    val processing = ProcessingDsl()
    val inputImage = Mat()
    val processedImage = Mat()
    var lastFrame = TimeSource.Monotonic.markNow()
    val targetFrameTime = 1.seconds / targetFrameRate
    while (!closed) {
        if (lastFrame + targetFrameTime > TimeSource.Monotonic.markNow()) continue
        lastFrame = TimeSource.Monotonic.markNow()
        videoCapture.read(inputImage)
        fpsCounter.count()

        processing.apply {
            reset()
            process(inputImage, processedImage, config.value)
        }

        val jpegBytes = run {
            val buffer = MatOfByte()
            Imgcodecs.imencode(".jpg", processedImage, buffer)
            buffer.toArray()
        }

        writeByteArray("--frame\r\n".toByteArray())
        writeByteArray("Content-Type: image/jpeg\r\n\r\n".toByteArray())
        writeByteArray(jpegBytes)
        writeByteArray("\r\n".toByteArray())
        flush()

        //println("frame time: ${lastFrame.elapsedNow().inWholeMilliseconds}ms")
    }

    fpsThread.interrupt()
    fpsThread.join()
    videoCapture.release()
}

fun async(block: () -> Unit) = Thread(block).apply { start() }

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
            return samples.toList().count { mark -> now.minus(mark) < second }
        }
}
