package au.org.ala.specieslist

import groovy.json.JsonSlurper
import grails.plugin.cache.Cacheable
import javax.annotation.PostConstruct


class LoggerService {

    def grailsApplication

    String LOGGER_SERVICE_BACKEND_URL

    @PostConstruct
    def init() {
        LOGGER_SERVICE_BACKEND_URL = "${grailsApplication.config.loggerService.internal.url}/service"
    }

    // @Cacheable("loggerCache")
    def getReasons() {
        log.info("Refreshing the download reasons")

        String queryUrl = "${LOGGER_SERVICE_BACKEND_URL}/logger/reasons"

        try {
            def queryResponse = new URL(queryUrl).getText("UTF-8")
            def jslurper = new JsonSlurper()
            if(!queryResponse?.trim()) {
                queryResponse = "{}"
            }
            def jsonResponse = jslurper.parseText(queryResponse)
            return jsonResponse

        } catch(ex) {
            log.error "[lists.LoggerService] Error loading download reasons: ${ex}", ex
            return [:]
        }
    }
}
