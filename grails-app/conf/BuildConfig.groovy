grails.servlet.version = "3.0" // Change depending on target container compliance (2.5 or 3.0)
grails.project.class.dir = "target/classes"
grails.project.test.class.dir = "target/test-classes"
grails.project.test.reports.dir = "target/test-reports"
grails.project.target.level = 1.8
grails.project.source.level = 1.8
grails.project.work.dir = "target/work"

grails.project.fork = [
    test: [maxMemory: 768, minMemory: 64, debug: false, maxPerm: 256, daemon: true], // configure settings for the test-app JVM
    run: [maxMemory: 768, minMemory: 64, debug: false, maxPerm: 256], // configure settings for the run-app JVM
    war: [maxMemory: 768, minMemory: 64, debug: false, maxPerm: 256], // configure settings for the run-war JVM
    console: [maxMemory: 768, minMemory: 64, debug: false, maxPerm: 256] // configure settings for the Console UI JVM
]

grails.project.dependency.resolver = "maven" // or ivy
grails.project.dependency.resolution = {
    // inherit Grails' default dependencies
    inherits("global") {
        // specify dependency exclusions here; for example, uncomment this to disable ehcache:
        // excludes 'ehcache'
    }
    log "error" // log level of Ivy resolver, either 'error', 'warn', 'info', 'debug' or 'verbose'
    checksums true // Whether to verify checksums on resolve
    legacyResolve false // whether to do a secondary resolve on plugin installation, not advised and here for backwards compatibility

    repositories {
        mavenLocal()
        mavenCentral()
        mavenRepo("http://nexus.ala.org.au/content/groups/public/") {
            updatePolicy "daily"
        }
    }

    dependencies {
        // specify dependencies here under either 'build', 'compile', 'runtime', 'test' or 'provided' scopes eg.
        compile(group: "com.google.guava", name: "guava", version: "19.0")
        compile("au.org.ala:ala-name-matching:2.4.0") {
            excludes "log4j","slf4j-log4j12"
        }
        compile "org.nibor.autolink:autolink:0.5.0"
        runtime "mysql:mysql-connector-java:5.1.44"
    }

    plugins {
        build(":tomcat:7.0.70",
            ":release:3.0.1") {
            export = false
        }

        runtime ":cors:1.1.8"
        runtime ":hibernate:3.6.10.15"
        compile ":asset-pipeline:2.14.1"
        compile ":cache:1.1.8"
        compile ":cache-ehcache:1.0.0"
        compile ":elurikkus-commons:0.2-SNAPSHOT"
        compile ":jsonp:0.2"
        compile ":rest:0.8"
        compile ":jquery:1.11.1"
    }
}
