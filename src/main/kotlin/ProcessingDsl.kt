package org.example

class ProcessingDsl {
    private val storage = Storage()
    fun <T> store(creator: () -> T) = storage.store { creator() }
    fun reset() = storage.reset()
    fun log(text: String) {
        println(text)
    }
}

private class Storage {
    private val storage = mutableMapOf<Int, Any?>()
    private var counter = 0

    @Suppress("UNCHECKED_CAST")
    fun <T> store(creator: () -> T): T {
        val value = if (storage.containsKey(counter)) {
            storage[counter] as T
        } else {
            val value = creator()
            storage[counter] = value
            value
        }
        counter++
        return value
    }

    fun reset() { counter = 0 }
}
