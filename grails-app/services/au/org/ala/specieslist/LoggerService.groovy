package au.org.ala.specieslist

import groovy.json.JsonSlurper
import grails.plugin.cache.Cacheable


class LoggerService {

    def grailsApplication

    // @Cacheable("loggerCache")
    def getReasons() {
        log.info("Refreshing the download reasons")

        String queryUrl = "${grailsApplication.config.loggerService.baseURL}/service/logger/reasons"

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
