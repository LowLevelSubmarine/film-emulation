import kotlin.reflect.KProperty
import kotlin.time.Duration
import kotlin.time.measureTimedValue

class ProcessingDsl {
    private val storage = Storage()
    private val timings = mutableMapOf<String, Duration>()
    fun <T> store(dependencies: List<Any>? = null, creator: () -> T) = storage.store(dependencies) { creator() }
    fun <T> stored(dependencies: List<Any>? = null, creator: () -> T) = storage.stored(dependencies) { creator() }
    fun reset() {
        storage.reset()
        timings.clear()
    }

    fun logTimings() {
        println(timings)
    }

    fun storeTime(name: String, duration: Duration) {
        timings[name] = duration
    }

    inline fun <R> measureTime(name: String, fn: () -> R): R {
        val timedValue = measureTimedValue(fn)
        storeTime(name, timedValue.duration)
        return timedValue.value
    }
}

private class Storage {
    private val storage = mutableMapOf<Int, Any?>()
    private val lastDependencies = mutableMapOf<Int, List<Any>?>()
    private var counter = 0

    @Suppress("UNCHECKED_CAST")
    fun <T> store(dependencies: List<Any>?, creator: () -> T): T {
        val value = if (storage.containsKey(counter) && lastDependencies[counter] == dependencies) {
            storage[counter] as T
        } else {
            lastDependencies[counter] = dependencies
            val value = creator()
            storage[counter] = value
            value
        }
        counter++
        return value
    }

    fun <T> stored(dependencies: List<Any>?, creator: () -> T) =
        store(dependencies) { StoredValueDelegate(creator()) }

    fun reset() {
        counter = 0
    }
}

class StoredValueDelegate<T>(private var value: T) {
    operator fun getValue(thisRef: Nothing?, property: KProperty<*>): T {
        return this.value
    }

    operator fun setValue(thisRef: Nothing?, property: KProperty<*>, value: T) {
        this.value = value
    }
}
