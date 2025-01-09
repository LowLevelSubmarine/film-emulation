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
import kotlinx.coroutines.delay
import kotlinx.serialization.json.Json
import nu.pattern.OpenCV
import org.opencv.core.Mat
import org.opencv.core.MatOfByte
import org.opencv.highgui.HighGui
import org.opencv.highgui.ImageWindow
import org.opencv.imgcodecs.Imgcodecs
import org.opencv.videoio.VideoCapture
import kotlin.time.Duration
import kotlin.time.Duration.Companion.milliseconds
import kotlin.time.Duration.Companion.seconds
import kotlin.time.TimeSource


fun main() {
    OpenCV.loadLocally()

    val imageWindowName = "filmEmulation"
    ImageWindow(imageWindowName, 0)
    val videoCapture = VideoCapture(0)  // cameraIndex = 0
    val inputImage = Mat()
    val processedImage = Mat()
    val processing = ProcessingDsl()
    val fpsCounter = FpsCounter()
    var config = Config.default

    embeddedServer(Netty, 8080) {
        install(CORS) {
            allowOrigins { _ -> true }
            allowMethod(HttpMethod.Get)
            allowMethod(HttpMethod.Post)
            allowHeader(HttpHeaders.ContentType)
        }

        routing {
            get("/") {
                call.respond(Json.encodeToString(config))
            }
            post("/") {
                val receivedConfig = call.receive<String>()
                config = Json.decodeFromString(receivedConfig)
                println("received config: $config")
                call.respond(HttpStatusCode.OK)
            }
            get("/stream") {
                call.respondBytesWriter(contentType = ContentType("multipart", "x-mixed-replace; boundary=frame")) {
                    while (true) {
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
                        delay(30.milliseconds) // ~30 FPS
                    }
                }
            }
        }
    }.start()

    val fpsThread = async {
        while (!Thread.interrupted()) {
            Thread.sleep(1000)
            println("fps: ${fpsCounter.fps}")
        }
    }

    try {
        // Start streaming
        do {
            videoCapture.read(inputImage)
            processing.apply {
                reset()
                process(inputImage, processedImage, config)
                fpsCounter.count()
            }
            HighGui.imshow(imageWindowName, processedImage)
        } while (HighGui.waitKey(1) != 27)
    } catch (e: Exception) {
        e.printStackTrace()
    }

    // Close Window
    HighGui.destroyWindow(imageWindowName)
    HighGui.waitKey(1) // actually closes the window
    videoCapture.release()
    fpsThread.interrupt()
    fpsThread.join()
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
