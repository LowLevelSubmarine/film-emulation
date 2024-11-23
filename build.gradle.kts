plugins {
    kotlin("jvm") version "2.0.20"
}

group = "org.example"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    implementation("org.openpnp:opencv:4.9.0-0")
    implementation("de.articdive:jnoise-pipeline:4.1.0")
    testImplementation(kotlin("test"))
}

tasks.test {
    useJUnitPlatform()
}