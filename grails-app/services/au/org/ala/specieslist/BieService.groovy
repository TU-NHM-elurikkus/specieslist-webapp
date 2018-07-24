package au.org.ala.specieslist
import grails.converters.JSON
import grails.web.JSONBuilder
import groovyx.net.http.HTTPBuilder
import javax.annotation.PostConstruct


class BieService {

    def grailsApplication

    String BIE_SERVICE_BACKEND_URL, LISTS_BACKEND_URL

    @PostConstruct
    def init() {
        BIE_SERVICE_BACKEND_URL = grailsApplication.config.bieService.internal.url
        LISTS_BACKEND_URL = grailsApplication.config.lists.internal.url
    }

    def bulkLookupSpecies(list) {
        Map map = [:]
        List jsonResponse = bulkSpeciesLookupWithGuids(list)
        jsonResponse.each {
            if (it && it.guid) {
                def guid = it.guid
                def image = it.smallImageUrl
                def commonName = it.commonNameSingle
                def scientificName = it.name
                def author = it.author
                map.put(guid, [image, commonName, scientificName, author])
            }
        }
        map
    }

    public List bulkSpeciesLookupWithGuids(list) {
        def http = new HTTPBuilder("${BIE_SERVICE_BACKEND_URL}/species/guids/bulklookup.json")
        http.getClient().getParams().setParameter("http.socket.timeout", new Integer(8000))
        def jsonBody = (list as JSON).toString()
        try {
            Map jsonResponse =  http.post(body: jsonBody, requestContentType:groovyx.net.http.ContentType.JSON)
            jsonResponse?.searchDTOList
        } catch (IOException | FileNotFoundException | Exception err) {
            // netowork error most likely. no need to send errors everywhere
            log.info("Unable to obtain species details from BIE - ${ex.getMessage()}", ex)
            []
        }
    }

    def updateBieIndex(List<Map> guidImageList) {
        def response
        def http = new HTTPBuilder("${BIE_SERVICE_BACKEND_URL}/updateImages")
        http.setHeaders(["Authorization": grailsApplication.config.bieApiKey])
        def jsonBody = (guidImageList as JSON).toString()
        try {
            response =  http.post(body: jsonBody, requestContentType:groovyx.net.http.ContentType.JSON)
        } catch(ex) {
            log.error("Unable to obtain species details from BIE - ${ex.getMessage()}", ex)

        }
        response
    }

    def generateFieldGuide(druid,guids){
        def title = "The field guide for " + druid
        def link = "${LISTS_BACKEND_URL}/speciesListItems/list/${druid}"
        try {
            // fieldGuide.baseURL is empty though
            def http = new HTTPBuilder(grailsApplication.config.fieldGuide.baseURL + "/generate")
            def response = http.post(body: createJsonForFieldGuide(title, link, guids), requestContentType:groovyx.net.http.ContentType.JSON){ resp ->
                def responseURL = grailsApplication.config.fieldGuide.baseURL + "/guide/" + resp.headers['fileId'].getValue()
                log.debug(responseURL)
                return responseURL
            }
        } catch(ex) {
            log.error("Unable to generate field guide " , ex)
            return null
        }
    }

    def createJsonForFieldGuide(t, l, g){
        def builder = new JSONBuilder()
        def result = builder.build {
            title = t
            link = l
            guids = g
        }
        result.toString(false)
    }
}
