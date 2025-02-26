import kotlin.reflect.KProperty
import kotlin.time.Duration
import kotlin.time.DurationUnit
import kotlin.time.measureTimedValue

/**
 * A DSL for processing tasks with dependency management and timing measurement.
 */
class ProcessingDsl {
    private val storage = Storage()
    private val timings = mutableMapOf<String, Duration>()

    /**
     * Stores a value created by the given creator function, with optional dependencies.
     *
     * @param dependencies List of dependencies for the value.
     * @param creator Function to create the value.
     * @return The stored value.
     */
    fun <T> store(dependencies: List<Any>? = null, creator: () -> T) = storage.store(dependencies) { creator() }

    /**
     * Stores a value created by the given creator function, with optional dependencies,
     * and returns a delegate for the stored value.
     *
     * @param dependencies List of dependencies for the value.
     * @param creator Function to create the value.
     * @return A delegate for the stored value.
     */
    fun <T> stored(dependencies: List<Any>? = null, creator: () -> T) = storage.stored(dependencies) { creator() }

    /**
     * Resets the storage and clears all recorded timings.
     */
    fun reset() {
        storage.reset()
        timings.clear()
    }

    /**
     * Logs the recorded timings to the console.
     */
    fun logTimings() {
        println(timings.map { "${it.key}: ${it.value.toString(DurationUnit.MILLISECONDS)}" })
    }

    /**
     * Stores the duration of a named task.
     *
     * @param name The name of the task.
     * @param duration The duration of the task.
     */
    fun storeTime(name: String, duration: Duration) {
        timings[name] = duration
    }

    /**
     * Measures the execution time of a function and stores the duration with the given name.
     *
     * @param name The name of the task.
     * @param fn The function to measure.
     * @return The result of the function.
     */
    inline fun <R> measureTime(name: String, fn: () -> R): R {
        val timedValue = measureTimedValue(fn)
        storeTime(name, timedValue.duration)
        return timedValue.value
    }
}

/**
 * A storage class for managing values with dependencies.
 */
private class Storage {
    private val storage = mutableMapOf<Int, Any?>()
    private val lastDependencies = mutableMapOf<Int, List<Any>?>()
    private var counter = 0

    /**
     * Stores a value created by the given creator function, with optional dependencies.
     *
     * @param dependencies List of dependencies for the value.
     * @param creator Function to create the value.
     * @return The stored value.
     */
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

    /**
     * Stores a value created by the given creator function, with optional dependencies,
     * and returns a delegate for the stored value.
     *
     * @param dependencies List of dependencies for the value.
     * @param creator Function to create the value.
     * @return A delegate for the stored value.
     */
    fun <T> stored(dependencies: List<Any>?, creator: () -> T) =
        store(dependencies) { StoredValueDelegate(creator()) }

    /**
     * Resets the storage counter.
     */
    fun reset() {
        counter = 0
    }
}

/**
 * A delegate class for storing a value.
 *
 * @param T The type of the value.
 * @property value The stored value.
 */
class StoredValueDelegate<T>(private var value: T) {
    /**
     * Gets the stored value.
     *
     * @param thisRef The reference to the object.
     * @param property The property being accessed.
     * @return The stored value.
     */
    operator fun getValue(thisRef: Nothing?, property: KProperty<*>): T {
        return this.value
    }

    /**
     * Sets the stored value.
     *
     * @param thisRef The reference to the object.
     * @param property The property being accessed.
     * @param value The new value to store.
     */
    operator fun setValue(thisRef: Nothing?, property: KProperty<*>, value: T) {
        this.value = value
    }
}
