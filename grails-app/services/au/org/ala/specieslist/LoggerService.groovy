package au.org.ala.specieslist

import grails.plugin.cache.Cacheable
import groovyx.net.http.HTTPBuilder


class LoggerService {

    def grailsApplication

    // @Cacheable("loggerCache")
    def getReasons() {
        log.info("Refreshing the download reasons")
        def http = new HTTPBuilder("${grailsApplication.config.loggerService.baseURL}")
        http.getClient().getParams().setParameter("http.socket.timeout", new Integer(10000))

        def map = [:]
        try {
            def result = http.get(path: "/service/logger/reasons")

            result.toArray().each{
                map.put(it.getAt("id"), it.getAt("name"))
            }
            log.debug "download reasons map = ${map}"
            return map
        } catch(ex) {
            // TODO return a default list - who's gonna do it? It's been sitting here more than 3 years
            log.error "Error loading download reasons: ${ex}", ex
            return map
        }
    }
}
