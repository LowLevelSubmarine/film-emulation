#import "../../components.typ": authored_by

== Color Cast
=== Theorie 
#authored_by("")

=== Implementierung
#authored_by("")


```kotlin
fun ProcessingDsl.colorCast(image: Mat, config: Config) {
    Core.add(image, config.colorCast.toScalar(), image)
}
```