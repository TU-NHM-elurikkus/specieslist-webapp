package au.org.ala.specieslist

import groovy.json.JsonSlurper
import groovyx.net.http.HTTPBuilder
import grails.web.JSONBuilder

class BiocacheService {
    static final int DEFAULT_TIMEOUT_MILLIS = 60000

    def grailsApplication

    def getQid(guids, unMatchedNames, title, wkt){
        def http = new HTTPBuilder(grailsApplication.config.biocacheService.baseURL +"/webportal/params")

        def query = ""

        if (guids) {
            query = "lsid:" + guids.join(" OR lsid:")
        }

        if (unMatchedNames) {
            query += ((query) ? " OR " : "") + "raw_name:\"" + unMatchedNames.collect{ it.trim() }.join("\" OR raw_name:\"") + "\""
        }

        def postBody = [q:query, wkt: wkt, title: title]
        log.debug "postBody = " + postBody

        try {
            http.post(body: postBody, requestContentType:groovyx.net.http.ContentType.URLENC){ resp, reader ->
                //return the location in the header
                log.debug(resp.headers)
                if (resp.status == 302) {
                    log.debug "302 redirect response from biocache"
                    return [status:resp.status, result:resp.headers['location'].getValue()]
                } else if (resp.status == 200) {
                    log.debug "200 OK response from biocache"
                    return [status:resp.status, result:reader.getText()]
                } else {
                    return [status:500]
                }
            }
        } catch(ex) {
            log.error("Unable to get occurrences: " ,ex)
            return null;
        }
    }

    def getTimeout() {
        int timeout = DEFAULT_TIMEOUT_MILLIS
        def timeoutFromConfig = grailsApplication.config.httpTimeoutMillis
        if (timeoutFromConfig?.size() > 0) {
            timeout = timeoutFromConfig as int
        }
        timeout
    }

    /**
     * Create a URL for search with this list
     * @param drUid
     * @return
     */
    String getQueryUrlForList(drUid){
        grailsApplication.config.biocache.baseURL + "/occurrences/search?q=species_list_uid:" + drUid
    }

    /**
     * Checks to see if a list is indexed against in the biocache.
     *
     * @param drUid
     * @return
     */
    Boolean isListIndexed(drUid){
        try {
            def url = grailsApplication.config.biocacheService.baseURL + "/occurrences/search?pageSize=0&facet=off&q=species_list_uid:" + drUid
            def jsonText = new URL(url).getText("UTF-8")
            def jsSlurper = new JsonSlurper()
            def json = jsSlurper.parseText(jsonText)
            json.totalRecords > 0
        } catch (Exception e){
            log.error("Problem checking if list is indexed against: " + e.getMessage(), e)
            false
        }
    }

    /**
     * WKT version of batch search
     *
     * @param guids
     * @param action
     * @param title
     * @param wkt
     * @return
     */
    def performBatchSearchOrDownload(guids, unMatchedNames, downloadDto, title, wkt) {

        def resp = getQid(guids, unMatchedNames, title, wkt)
        if(resp?.status == 302){
            resp.result
        } else if (resp?.status == 200) {
            log.debug "200 OK response"
            def qid = resp.result
            def returnUrl = ""
            switch ( downloadDto.type ) {
                case "Search":
                    returnUrl = grailsApplication.config.biocache.baseURL + "/occurrences/search?q=qid:" + qid
                    break
                case "Download":
                    returnUrl = grailsApplication.config.biocacheService.baseURL + "/occurrences/index/download?q=qid:" + qid + "&file=" + downloadDto.file
                    returnUrl += "&reasonTypeId=" + downloadDto.reasonTypeId + "&email=" + downloadDto.email
                    break
            }
            returnUrl
        } else {
            null
        }
    }

    //Location	http://biocache.ala.org.au/occurrences/search?q=qid:1344230443917
    def createJsonForBatch(guids){
        def builder = new JSONBuilder()

        def result = builder.build{
            queries = guids.join(",")
            field = "lsid"
            separator = ","
            redirectBase = grailsApplication.config.biocache.baseURL
        }
        log.debug(result.toString(true))
        result.toString(false)
    }
}
