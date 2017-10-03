package au.org.ala.specieslist

import au.org.ala.web.AuthService
import grails.converters.*
import au.com.bytecode.opencsv.CSVWriter

class SpeciesListItemController {

    BieService bieService
    LoggerService loggerService
    QueryService queryService
    LocalAuthService localAuthService
    AuthService authService
    int maxLengthForFacet = 30 // Note: is length of _name_ of the facet category/field

    def index() { }

    /**
     * Public display of a species list
     */
    def list(){
        doListDisplay(params)
    }

    /**
     * There is no functional difference between listAuth and list. This method has been retained to support existing
     * links/bookmarks/etc that may refer to it. Both URLs are in the authenticateOnlyIfLoggedInFilterPattern list
     * for CAS authentication.
     */
    def listAuth() {
        doListDisplay(params)
    }

    /**
     * Special (simple) page for displaying "Australia's Species", linked from homepage.
     *
     * @return
     */
    def iconicSpecies() {
        params.id = params.id?:grailsApplication.config.iconicSpecies?.uid?:""
        params.max = params.max?:25

        if (!params.fq) {
            redirect(action: 'iconicSpecies', params: [fq:'kvp group:Birds'])
        }
        try {
            def speciesList = SpeciesList.findByDataResourceUid(params.id)
            if (!speciesList) {
                flash.message = "${message(code: 'general.not.found.message', args: [message(code: 'speciesList.label', default: 'Species List'), params.id])}"
                render(view: "iconic-list")
            } else {
                params.max = Math.min(params.max ? params.int('max') : 25, 100)
                params.sort = params.sort ?: "itemOrder"
                params.fetch = [kvpValues: 'select']
                def fqs = params.fq ? [params.fq].flatten().findAll { it != null } : null
                def baseQueryAndParams = params.fq ? queryService.constructWithFacets(" from SpeciesListItem sli ", fqs, params.id) : null
                //need to get all keys to be included in the table so no need to add the filter.
                def speciesListItems = params.fq ? SpeciesListItem.executeQuery("select sli " + baseQueryAndParams[0], baseQueryAndParams[1], params) : SpeciesListItem.findAllByDataResourceUid(params.id, params)
                def totalCount = params.fq ? SpeciesListItem.executeQuery("select count(*) " + baseQueryAndParams[0], baseQueryAndParams[1]).head() : SpeciesListItem.countByDataResourceUid(params.id)
                def guids = speciesListItems.collect { it.guid }
                def bieItems = bieService.bulkLookupSpecies(guids)
                def facets = generateFacetValues(null, baseQueryAndParams)
                log.debug "speciesListItems = ${speciesListItems as JSON}"
                render(view: 'iconic-list', model: [
                        results: speciesListItems,
                        totalCount: totalCount,
                        bieItems: bieItems,
                        facets: facets
                ])
            }
        }  catch (Exception e) {
            def msg = "Unable to retrieve species list items. Please let us know if this error persists. <br>Error:<br>" + e.getMessage()
            log.error(msg, e)
            flash.message = msg
            render(view: 'iconic-list')
        }
    }

    private doListDisplay(requestParams) {
        if (requestParams.id) {
            try {
                //check to see if the list exists
                def speciesList = SpeciesList.findByDataResourceUid(requestParams.id)

                if (!speciesList) {
                    flash.message = "${message(code: 'general.not.found.message', args: [message(code: 'speciesList.label', default: 'Species List'), requestParams.id])}"
                    redirect(controller: "public", action: "speciesLists")
                } else {
                    if (requestParams.message) {
                        flash.message = requestParams.message
                    }

                    requestParams.max = Math.min(requestParams.max ? requestParams.int('max') : 25, 100)
                    requestParams.sort = requestParams.sort ?: "itemOrder"
                    requestParams.offset = requestParams.int('offset') ?: 0
                    requestParams.fetch = [kvpValues: 'select']

                    log.debug(requestParams.toQueryString())

                    //need to get all keys to be included in the table so no need to add the filter.
                    def keys = SpeciesListKVP.executeQuery("select distinct key from SpeciesListKVP where dataResourceUid=? order by itemOrder", requestParams.id)

                    def fqs, distinctCount, speciesListItems, totalCount, noMatchCount, facets

                    def orderQuery = " ORDER BY ${requestParams.sort} ${requestParams.order ?: 'asc'}"

                    // XXX TODO: Don't fully branch, but merge fq and search query and then
                    // execute them (can probably merge all three branches). But that will
                    // require some non-trivial refactoring because related methods are
                    // very fq-specific and are used in other places
                    if(requestParams.fq) {
                        fqs = [requestParams.fq].flatten().findAll { it != null }

                        def baseQueryAndParams = queryService.constructWithFacets(" from SpeciesListItem sli ", fqs, requestParams.id)
                        def baseQuery = baseQueryAndParams[0]
                        def baseQueryParams = baseQueryAndParams[1]

                        if(requestParams.query) {
                            baseQuery += "AND sli.rawScientificName LIKE '%${requestParams.query}%' "
                        }

                        log.debug("Base query & params:")
                        log.debug(baseQueryAndParams)

                        speciesListItems = SpeciesListItem.executeQuery(
                            "select sli " + baseQuery + orderQuery,
                            baseQueryParams,
                            requestParams
                        )

                        distinctCount = SpeciesList.executeQuery(
                            "select count(distinct guid) " + baseQuery,
                            baseQueryParams
                        ).head()

                        totalCount = SpeciesListItem.executeQuery(
                            "select count(*) " + baseQuery,
                            baseQueryParams
                        ).head()

                        noMatchCount = SpeciesListItem.executeQuery(
                            "select count(*) " + baseQuery + " AND sli.guid is null",
                            baseQueryParams,
                        ).head()

                        facets = generateFacetValues(fqs, baseQueryAndParams)
                    } else {
                        def baseQuery, baseParams;

                        if(requestParams.query) {
                            baseQuery = "dataResourceUid=? AND raw_scientific_name LIKE ?"
                            baseParams = [requestParams.id, "%" + requestParams.query + "%"]

                            facets = generateFacetValues([requestParams.query], ['FROM SpeciesListItem AS sli WHERE ' + baseQuery, baseParams])
                        } else {
                            baseQuery = "dataResourceUid=?"
                            baseParams = [requestParams.id]

                            facets = generateFacetValues(null, null)
                        }

                        speciesListItems = SpeciesListItem.findAll(
                            "FROM SpeciesListItem WHERE " + baseQuery + orderQuery,
                            baseParams,
                            requestParams
                        )

                        distinctCount = SpeciesListItem.executeQuery(
                            "SELECT COUNT(DISTINCT guid) FROM SpeciesListItem WHERE " + baseQuery,
                            baseParams
                        ).head()

                        totalCount = SpeciesListItem.executeQuery(
                            "SELECT COUNT(guid) FROM SpeciesListItem WHERE " + baseQuery,
                            baseParams
                        ).head()

                        noMatchCount = SpeciesListItem.executeQuery(
                            "SELECT COUNT(guid) FROM SpeciesListItem WHERE guid IS NOT NULL AND " + baseQuery,
                            baseParams
                        ).head()
                    }

                    def users = SpeciesList.executeQuery("select distinct sl.username from SpeciesList sl")

                    def guids = speciesListItems.collect { it.guid }

                    def downloadReasons = loggerService.getReasons()

                    render(view: 'list', model: [
                        speciesList: speciesList,
                        params: requestParams,
                        results: speciesListItems,
                        totalCount: totalCount,
                        noMatchCount: noMatchCount,
                        distinctCount: distinctCount,
                        hasUnrecognised: noMatchCount > 0,
                        keys: keys,
                        downloadReasons: downloadReasons,
                        users: users,
                        facets: facets,
                        fqs : fqs,
                        query: requestParams.query
                    ])
                }
            } catch (Exception e) {
                log.error("Unable to view species list items.", e)
                render(view: '../error', model: [message: "Unable to retrieve species list items. Please let us know if this error persists. <br>Error:<br>" + e.getMessage()])
            }
        } else {
            //redirect to the public species list page
            redirect(controller: "public", action: "speciesLists")
        }
    }

    // XXX: Doesn't actually use fqs
    private def generateFacetValues(List fqs, baseQueryParams){
        def map = [:]

        //handle the user defined properties -- this will also make up the facets
        String selectPart = "SELECT DISTINCT kvp.key, kvp.value, kvp.vocabValue, COUNT(sli) AS cnt";

        def properties = null

        if(fqs) {
            //get the ids for the query -- this allows correct counts when joins are being performed.
            def ids = SpeciesListItem.executeQuery("SELECT DISTINCT sli.id " + baseQueryParams[0], baseQueryParams[1])

            Map queryParameters = [druid: params.id]
            if (ids) {
                queryParameters.ids = ids
            }

            def results = SpeciesListItem.executeQuery(
                "SELECT kvp.key, kvp.value, kvp.vocabValue, COUNT(sli) AS cnt " +
                "FROM SpeciesListItem AS sli JOIN sli.kvpValues AS  kvp " +
                "WHERE sli.dataResourceUid=:druid ${ids ? 'and sli.id in (:ids)' : ''} " +
                "GROUP BY kvp.key, kvp.value, kvp.vocabValue " +
                "ORDER BY kvp.itemOrder,kvp.key,cnt DESC",
                queryParameters
            )

            //obtain the families from the common list facets
            def commonResults = SpeciesListItem.executeQuery(
                "SELECT sli.family, COUNT(sli) AS cnt " +
                "FROM SpeciesListItem AS sli " +
                "WHERE sli.family IS NOT NULL AND sli.dataResourceUid=:druid ${ids ? 'and sli.id in (:ids)' : ''} " +
                "GROUP BY sli.family " +
                "ORDER BY cnt desc",
                queryParameters
            )

            if(commonResults.size() > 1) {
                map.family = commonResults
            }

            properties = results.findAll{ it[1].length()<maxLengthForFacet }.groupBy { it[0] }.findAll{ it.value.size()>1}

        } else {
            def result = SpeciesListItem.executeQuery(
                'SELECT kvp.key, kvp.value, kvp.vocabValue, count(sli) as cnt ' +
                'FROM SpeciesListItem AS sli JOIN sli.kvpValues AS kvp ' +
                'WHERE sli.dataResourceUid=? ' +
                'GROUP BY kvp.key, kvp.value, kvp.vocabValue ' +
                'ORDER BY kvp.itemOrder,kvp.key,cnt desc',
                params.id
            )

            properties = result.findAll{it[1].length()<maxLengthForFacet}.groupBy{it[0]}.findAll{it.value.size()>1 }

            //obtain the families from the common list facets
            def commonResults = SpeciesListItem.executeQuery(
                "SELECT family, count(*) AS cnt " +
                "FROM SpeciesListItem " +
                "WHERE family IS NOT NULL AND dataResourceUid=? " +
                "GROUP BY family " +
                "ORDER BY cnt DESC",
                params.id
            )

            if(commonResults.size() > 1) {
                map.family = commonResults
            }
        }

        //if there was a facet included in the result we will need to divide the
        if(properties) {
            map.listProperties = properties
        }

        //handle the configurable facets
        map
    }

    def facetsvalues(){
        if(params.id){
          def result = SpeciesListItem.executeQuery('select kvp.key, kvp.value, kvp.vocabValue, count(sli) as cnt from SpeciesListItem as sli join sli.kvpValues  as kvp where sli.dataResourceUid=? group by kvp.key, kvp.value, kvp.vocabValue order by kvp.key,cnt desc', params.id)
          //group the same properties keys together
          def properties = result.groupBy { it[0] }
          def map = [:]
          map.listProperties = properties
          render map as JSON
        }
        null
    }

    /**
     * Downloads the records for the supplied species list
     * @return
     */
    def downloadList(){
        if (params.id){
            params.fetch = [ kvpValues: 'join' ]
            log.debug("Downloading Species List")
            def keys = SpeciesListKVP.executeQuery("select distinct key from SpeciesListKVP where dataResourceUid='"+params.id+"'")
            def fqs = params.fq?[params.fq].flatten().findAll{ it != null } : null
            def baseQueryAndParams = queryService.constructWithFacets(" from SpeciesListItem sli ",fqs, params.id)
            def sli = SpeciesListItem.executeQuery("Select sli " + baseQueryAndParams[0], baseQueryAndParams[1])
            //def sli =SpeciesListItem.findAllByDataResourceUid(params.id,params)
            def out = new StringWriter()
            def csvWriter = new CSVWriter(out)
            def header =  ["Supplied Name","guid","scientificName","family","kingdom"]
            header.addAll(keys)
            log.debug(header)
            csvWriter.writeNext(header as String[])
            sli.each {
                def values = keys.collect{key->it.kvpValues.find {kvp -> kvp.key == key}}.collect { kvp -> kvp?.vocabValue?:kvp?.value}
                def row = [it.rawScientificName, it.guid, it.matchedName, it.family, it.kingdom]
                row.addAll(values)
                csvWriter.writeNext(row as String[])
            }
            csvWriter.close()
            def filename = params.file?:"list.csv"
            if(!filename.toLowerCase().endsWith('.csv')){
                filename += '.csv'
            }

            response.addHeader("Content-Disposition", "attachment;filename="+filename);
            render(contentType: 'text/csv', text:out.toString())
        }
    }

    /**
     * Returns BIE details about the supplied guid
     * @return
     */
    def itemDetails(){
        log.debug("Returning item details for " + params)
        if(params.guids){
            render bieService.bulkLookupSpecies(params.guid) as JSON
        } else {
            null
        }
    }
}
