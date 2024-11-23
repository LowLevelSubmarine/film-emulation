package org.example

import kotlin.reflect.KProperty

class ProcessingDsl {
    private val storage = Storage()
    fun <T> store(creator: () -> T) = storage.store { creator() }
    fun <T> stored(creator: () -> T) = storage.stored { creator() }
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

    fun <T> stored(creator: () -> T) = store { StoredValueDelegate(creator()) }

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
