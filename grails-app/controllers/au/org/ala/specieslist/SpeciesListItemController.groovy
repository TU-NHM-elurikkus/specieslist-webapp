package au.org.ala.specieslist

import grails.converters.*
import au.com.bytecode.opencsv.CSVWriter


class SpeciesListItemCommand {
    String order
    String sort
    int max
    int offset

    static constraints = {
        order(
            inList: ["asc", "desc"],
        )
        sort(
            inList: ["itemOrder", "matchedName", "imageUrl", "author", "commonName"],
        )
        max(
            size: 10..100,
        )
        offset(
            min: 0,
        )
    }
}


class SpeciesListItemController {

    BieService bieService
    LoggerService loggerService
    QueryService queryService
    int maxLengthForFacet = 30 // Note: is length of _name_ of the facet category/field

    /**
     * Public display of a species list
     */
    def list(SpeciesListItemCommand cmd) {
        if (cmd.hasErrors()) {
            if (cmd.errors.hasFieldErrors("order")) {
                params.order = "asc"
            }
            if (cmd.errors.hasFieldErrors("sort")) {
                params.sort = "itemOrder"
            }
            if (cmd.errors.hasFieldErrors("max")) {
                params.max = 25
            }
            if (cmd.errors.hasFieldErrors("offset")) {
                params.offset = 0
            }
        }

        // Default values
        params.order = params.order ?: "asc"
        params.sort = params.sort ?: "itemOrder"
        params.max = params.int("max", 25)
        params.offset = params.int("offset", 0)

        doListDisplay(params)
    }

    private doListDisplay(requestParams) {
        try {
            //check to see if the list exists
            def speciesList = SpeciesList.findByDataResourceUid(requestParams.id)

            if (!speciesList) {
                flash.message = message(code: "general.not.found.message", args: [requestParams.id])
                return redirect(controller: "public", action: "speciesLists")
            }
            if (requestParams.message) {
                flash.message = requestParams.message
            }

            log.debug(requestParams.toQueryString())

            //need to get all keys to be included in the table so no need to add the filter.
            def keys = SpeciesListKVP.executeQuery("select distinct key from SpeciesListKVP where dataResourceUid=? order by itemOrder", requestParams.id)

            def fqs, distinctCount, speciesListItems, totalCount, noMatchCount, facets

            def orderQuery = " ORDER BY ${requestParams.sort} ${requestParams.order}"

            // XXX TODO: Don't fully branch, but merge fq and search query and then
            // execute them (can probably merge all three branches). But that will
            // require some non-trivial refactoring because related methods are
            // very fq-specific and are used in other places
            if(requestParams.fq) {
                fqs = [requestParams.fq].flatten().findAll { it != null }

                def baseQueryAndParams = queryService.constructWithFacets(" from SpeciesListItem sli ", fqs, requestParams.id)
                def baseQuery = baseQueryAndParams[0]
                def baseQueryParams = baseQueryAndParams[1]

                if (requestParams.query) {
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

                if (requestParams.query) {
                    baseQuery = "dataResourceUid=? AND raw_scientific_name LIKE ?"
                    baseParams = [requestParams.id, "%${requestParams.query}%"]

                    facets = generateFacetValues([requestParams.query], ["FROM SpeciesListItem AS sli WHERE " + baseQuery, baseParams])
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

            render(view: "list", model: [
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
        } catch (Exception e) {
            log.error("Unable to view species list items.", e)
            render(view: "../error", model: [message: "Unable to retrieve species list items. Please let us know if this error persists. <br>Error:<br>" + e.getMessage()])
        }
    }

    // XXX: Doesn't actually use fqs
    private def generateFacetValues(List fqs, baseQueryParams) {
        def map = [:]

        //handle the user defined properties -- this will also make up the facets
        String selectPart = "SELECT DISTINCT kvp.key, kvp.value, kvp.vocabValue, COUNT(sli) AS cnt";

        def properties = null

        if (fqs) {
            //get the ids for the query -- this allows correct counts when joins are being performed.
            def ids = SpeciesListItem.executeQuery("SELECT DISTINCT sli.id " + baseQueryParams[0], baseQueryParams[1])

            Map queryParameters = [druid: params.id]
            if (ids) {
                queryParameters.ids = ids
            }

            def results = SpeciesListItem.executeQuery(
                "SELECT kvp.key, kvp.value, kvp.vocabValue, COUNT(sli) AS cnt " +
                "FROM SpeciesListItem AS sli JOIN sli.kvpValues AS kvp " +
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

            if (commonResults.size() > 1) {
                map.family = commonResults
            }

            properties = results.findAll { it[1].length() < maxLengthForFacet }.groupBy { it[0] }.findAll { it.value.size() > 1 }

        } else {
            def result = SpeciesListItem.executeQuery(
                "SELECT kvp.key, kvp.value, kvp.vocabValue, count(sli) as cnt " +
                "FROM SpeciesListItem AS sli JOIN sli.kvpValues AS kvp " +
                "WHERE sli.dataResourceUid=? " +
                "GROUP BY kvp.key, kvp.value, kvp.vocabValue " +
                "ORDER BY kvp.itemOrder,kvp.key,cnt desc",
                params.id
            )

            properties = result.findAll { it[1].length() < maxLengthForFacet }.groupBy { it[0] }.findAll { it.value.size() > 1 }

            //obtain the families from the common list facets
            def commonResults = SpeciesListItem.executeQuery(
                "SELECT family, count(*) AS cnt " +
                "FROM SpeciesListItem " +
                "WHERE family IS NOT NULL AND dataResourceUid=? " +
                "GROUP BY family " +
                "ORDER BY cnt DESC",
                params.id
            )

            if (commonResults.size() > 1) {
                map.family = commonResults
            }
        }

        //if there was a facet included in the result we will need to divide the
        if (properties) {
            map.listProperties = properties
        }

        //handle the configurable facets
        map
    }

    def facetsvalues() {
        if (params.id) {
            def result = SpeciesListItem.executeQuery(
                "SELECT kvp.key, kvp.value, kvp.vocabValue, count(sli) AS cnt " +
                "FROM SpeciesListItem AS sli " +
                "JOIN sli.kvpValues AS kvp " +
                "WHERE sli.dataResourceUid=? " +
                "GROUP BY kvp.key, kvp.value, kvp.vocabValue " +
                "ORDER BY kvp.key,cnt desc",
                params.id
            )
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
    def downloadList() {
        if (params.id) {
            params.fetch = [ kvpValues: "join" ]
            log.debug("Downloading Species List")
            def keys = SpeciesListKVP.executeQuery("select distinct key from SpeciesListKVP where dataResourceUid='${params.id}'")
            def fqs = params.fq ? [params.fq].flatten().findAll { it != null } : null
            def baseQueryAndParams = queryService.constructWithFacets(" from SpeciesListItem sli ",fqs, params.id)
            def sli
            try {
                sli = SpeciesListItem.executeQuery("Select sli " + baseQueryAndParams[0], baseQueryAndParams[1])
            } catch(Exception qEx) {
                log.error("SpeciesListItemController.downloadList() | " +
                          "query: 'Select sli ${baseQueryAndParams[0]}' '${baseQueryAndParams[1]}' | " +
                          "error: ${qEx}")
                render(view: "error", model: [exception: qEx], status: 400)
            }
            //def sli =SpeciesListItem.findAllByDataResourceUid(params.id,params)
            def out = new StringWriter()
            def csvWriter = new CSVWriter(out)
            def header = ["Supplied Name", "guid", "scientificName", "family", "kingdom"]
            header.addAll(keys)
            log.debug(header)
            csvWriter.writeNext(header as String[])
            sli.each {
                def values = keys.collect { key -> it.kvpValues.find { kvp -> kvp.key == key } }.collect { kvp -> kvp?.vocabValue ?: kvp?.value }
                def row = [it.rawScientificName, it.guid, it.matchedName, it.family, it.kingdom]
                row.addAll(values)
                csvWriter.writeNext(row as String[])
            }
            csvWriter.close()
            def filename = params.file ?: "list.csv"
            if (!filename.toLowerCase().endsWith(".csv")) {
                filename += ".csv"
            }

            response.addHeader("Content-Disposition", "attachment;filename=" + filename);
            render(contentType: "text/csv", text: out.toString())
        }
    }

    /**
     * Returns BIE details about the supplied guid
     * @return
     */
    def itemDetails() {
        log.debug("Returning item details for " + params)
        if (params.guids) {
            render bieService.bulkLookupSpecies(params.guid) as JSON
        } else {
            null
        }
    }
}
