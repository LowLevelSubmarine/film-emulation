import org.opencv.core.Size

operator fun Size.div(i: Number) = Size(this.width / i.toDouble(), this.height / i.toDouble())
operator fun Size.times(i: Number) = Size(this.width * i.toDouble(), this.height * i.toDouble())
fun Size.map(mapping: (value: Double) -> Double) = Size(mapping(this.width), mapping(this.height))
