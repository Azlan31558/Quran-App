allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    afterEvaluate {
        val androidExtension = extensions.findByName("android") ?: return@afterEvaluate
        val compileSdkSetter = androidExtension.javaClass.methods.firstOrNull {
            (it.name == "setCompileSdk" || it.name == "setCompileSdkVersion") &&
                it.parameterCount == 1 &&
                (it.parameterTypes[0] == Integer.TYPE ||
                    it.parameterTypes[0] == Integer::class.java)
        } ?: return@afterEvaluate

        compileSdkSetter.invoke(androidExtension, 36)
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
