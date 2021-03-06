/*
 * Copyright (C) 2012 Atlas of Living Australia
 * All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 */
package au.org.ala.specieslist

import org.springframework.web.servlet.support.RequestContextUtils
import au.com.bytecode.opencsv.CSVWriter
import grails.converters.*
import grails.web.JSONBuilder
import org.apache.http.HttpStatus

/**
 * Provides all the webservices to be used from other sources eg the BIE
 */
class WebServiceController {

    def helperService
    def queryService
    def beforeInterceptor = [action: this.&prevalidate, only: ["getListDetails"]]

    private def prevalidate() {
        //ensure that the supplied druid is valid
        log.debug("Prevalidating...")
        if(params.druid) {
            def list = SpeciesList.findByDataResourceUid(params.druid)
            if (list) {
                params.splist = list
            }
            else {
                notFound "Unable to locate species list ${params.druid}"
                return false
            }
        }
        return true
    }

    def index() { }

    def getDistinctValues() {
        def field = params.field

        def props = [fetch: [mylist: "join"]]
        log.debug("Distinct values " + field + " " + params)
        def results = queryService.getFilterListItemResult(props, params, null, null, field )
        helperService.asJson(results, response)
    }

    def getTaxaOnList() {
        def druid = params.druid
        def results = SpeciesListItem.executeQuery("select guid from SpeciesListItem where dataResourceUid=?", [druid])
        render results as JSON
    }

    def getListItemsForSpecies() {
        def guid = params.guid
        def lists = params.dr?.split(",")
        def isBIE = params.boolean("isBIE")
        def props = [fetch: [kvpValues: "join", mylist: "join"]]

        def results = queryService.getFilterListItemResult(props, params, guid, lists, null)

        //def results = lists ? SpeciesListItem.findAllByGuidAndDataResourceUidInList(guid, lists,props) : SpeciesListItem.findAllByGuid(guid,props)
        //def result2 =results.collect {[id: it.id, dataResourceUid: it.dataResourceUid, guid: it.guid, kvpValues: it.kvpValue.collect{ id:it.}]}
        def builder = new JSONBuilder()

        log.debug("RESULTS: " + results)

        def filteredRecords = results.findAll { !it.mylist.isPrivate }

        if (isBIE) {
            // BIE only want lists with isBIE == true
            filteredRecords = filteredRecords.findAll { it.mylist.isBIE }
        }

        def locale = RequestContextUtils.getLocale(request).toString()

        def listOfRecordMaps = filteredRecords.collect { li -> // don't output private lists
            [
                dataResourceUid: li.dataResourceUid,
                guid: li.guid,
                list: [
                        username: li.mylist.username,
                        listName: li.mylist.getLocalizedName(locale),
                        sds: li.mylist.isSDS ?: false,
                        isBIE: li.mylist.isBIE ?: false
                ],
                kvpValues: li.kvpValues.collect { kvp ->
                    [
                        key: kvp.key,
                        value: kvp.value,
                        vocabValue: kvp.vocabValue
                    ]
                }
            ]
        }
        render builder.build { listOfRecordMaps }
    }

    /**
     *   Returns either a JSON list of species lists or a specific species list
     *
     *   @param druid - the data resource uid for the list to return (optional)
     *   @param splist - optional instance (added by the beforeInterceptor)
     */
    def getListDetails = {
        log.debug("params" + params)
        if(params.splist) {
            def sl = params.splist
            log.debug("The speciesList: " + sl)
            def builder = new JSONBuilder()

            def retValue = builder.build {
                dataResourceUid = sl.dataResourceUid
                listName = sl.listName
                if(sl.listType) listType = sl?.listType?.toString()
                dateCreated = sl.dateCreated
                username =  sl.username
                itemCount = sl.itemsCount//SpeciesListItem.countByList(sl)
                isAuthoritative = sl.isAuthoritative ?: false
                isInvasive = sl.isInvasive ?: false
                isThreatened = sl.isThreatened ?: false
            }
            log.debug(" The retvalue: " + retValue)
            render retValue
        } else {
            //we need to return a summary of all lists
            //allowing for customisation in sort order and paging
            params.fetch = [items: "lazy"]
            if(params.sort)
                params.user = null
            if(!params.user)
                params.sort = params.sort ?: "listName"
            if(params.sort == "count") params.sort = "itemsCount"
            params.order = params.order ?: "asc"

            //AC 20141218: Previous behaviour was ignoring custom filter code in queryService.getFilterListResult when params.user
            //parameter was present and params.sort was absent. Moved special case sorting when params.user is present
            //and params.sort is absent into queryService.getFilterListResults so the custom filter code will always be applied.

            def allLists = queryService.getFilterListResult(params)
            def listCounts = allLists.totalCount
            def retValue =[listCount: listCounts, sort: params.sort, order: params.order, max: params.max, offset: params.offset,
                    lists: allLists.collect { [dataResourceUid: it.dataResourceUid,
                                            listName: it.listName,
                                            listType: it?.listType?.toString(),
                                            dateCreated: it.dateCreated,
                                            lastUpdated: it.lastUpdated,
                                            username: it.username,
                                            itemCount: it.itemsCount,
                                            region: it.region,
                                            category: it.category,
                                            generalisation: it.generalisation,
                                            authority: it.authority,
                                            sdsType: it.sdsType,
                                            isAuthoritative: it.isAuthoritative ?: false,
                                            isInvasive: it.isInvasive ?: false,
                                            isThreatened: it.isThreatened ?: false] }]

            render retValue as JSON
        }
    }

    /**
     * Returns a summary list of items that form part of the supplied species list.
     */
    def getListItemDetails = {
        if(params.druid) {
            params.sort = params.sort ?: "itemOrder" // default to order the items were imported in
            def list
            if(!params.q) {
                list = params.nonulls ?
                        SpeciesListItem.findAllByDataResourceUidAndGuidIsNotNull(params.druid, params)
                        : SpeciesListItem.findAllByDataResourceUid(params.druid, params)
            } else {
                // if query parameter is passed, search in common name, supplied name and scientific name
                String query = "%${params.q}%"
                String druid = params.druid
                def criteria = SpeciesListItem.createCriteria()
                if(params.nonulls) {
                    // search among SpeciesListItem that has matched ALA taxonomy
                    list = criteria {
                        isNotNull("guid")
                        eq("dataResourceUid", druid)
                        or {
                            ilike("commonName", query)
                            ilike("matchedName", query)
                            ilike("rawScientificName", query)
                        }
                    }
                } else {
                    // search all SpeciesListItem
                    list = criteria {
                        eq("dataResourceUid", druid)
                        or {
                            ilike("commonName", query)
                            ilike("matchedName", query)
                            ilike("rawScientificName", query)
                        }
                    }
                }
            }

            List newList
            if (params.includeKVP?.toBoolean()) {
                newList = list.collect( { [id: it.id, name: it.rawScientificName, commonName: it.commonName, scientificName: it.matchedName, lsid: it.guid,
                                        kvpValues: it.kvpValues.collect( { [key: it.key, value: it.value] })] })
            }
            else {
                newList = list.collect { [id: it.id,name: it.rawScientificName, commonName: it.commonName, scientificName: it.matchedName, lsid: it.guid] }
            }
            render newList as JSON
        } else {
            //no data resource uid was supplied.
            def props = [fetch: [kvpValues: "join"]]
            def list = queryService.getFilterListItemResult(props, params, null, null, null)
            render list.collect { [guid: it.guid, name: it.matchedName ?: it.rawScientificName, family: it.family, dataResourceUid: it.dataResourceUid, kvpValues: it.kvpValues?.collect { i -> [key: i.key, value: i.vocabValue ?: i.value] }] } as JSON
        }
    }

    def getSpeciesListItemKvp() {
        def speciesListDruid = params.druid

        List newList = []
        if (speciesListDruid) {
            def speciesList = SpeciesListItem.findAllByDataResourceUid(speciesListDruid)
            if (speciesList.size() > 0) {
                speciesList.each( {
                    def scientificName = it.rawScientificName
                    if (it.kvpValues) {
                        Map kvps = new HashMap();
                        it.kvpValues.each {
                            if (kvps.containsKey(it.key)) {
                                def val = kvps.get(it.key) + "|" + it.value
                                kvps.put(it.key, val)
                            } else {
                                kvps.put(it.key, it.value)
                            }
                        }
                        newList.push(name: scientificName, kvps: kvps)
                    }
                })
            }
        }
        render newList as JSON

    }

    def created = { uid, guids ->
        response.addHeader "druid", uid
        response.status = 201
        def outputMap = [status: 200, message: "added species list", druid: uid, data: guids]
        render outputMap as JSON
    }

    def badRequest = { text ->
        render(status: 400, text: text)
    }

    def notFound = { text ->
        render(status: 404, text: text)
    }

    def markAsPublished() {
        //marks the supplied data resource as published
        if (params.druid) {
            SpeciesListItem.executeUpdate("update SpeciesListItem set isPublished=true where dataResourceUid='" + params.druid + "'")
            render "Species list " + params.druid + " has been published"
        } else {
            render(view: "../error", model: [message: "No data resource has been supplied"])
        }
    }

    def getBieUpdates() {
        //retrieve all the unpublished list items in batches of 100
        def max = 100
        def offset = 0
        def hasMore = true
        def out = response.outputStream
        //use a criteria so that paging can be supported.
        def criteria = SpeciesListItem.createCriteria()
        while(hasMore) {
            def results = criteria.list([sort:"guid", max: max, offset:offset, fetch:[kvpValues: "join"]]) {
                isNull("isPublished")
                //order("guid")
            }
            //def results =SpeciesListItem.findAllByIsPublishedIsNull([sort:"guid",max: max, offset:offset,fetch:[kvpValues: "join"]])
            results.each {
                //each of the results are rendered as CSV
                def sb = ''<<''
                if(it.kvpValues) {
                    it.kvpValues.each { kvp ->
                        sb<<toCsv(it.guid)<<","<<toCsv(it.dataResourceUid)<<","<<toCsv(kvp.key)<<","<<toCsv(kvp.value)<<","<<toCsv(kvp.vocabValue)<<"\n"
                    }
                } else {
                    sb << toCsv(it.guid) << "," << toCsv(it.dataResourceUid) << ",,,\n"
                }
                out.print(sb.toString())
            }
            offset += max
            hasMore = offset<results.getTotalCount()
        }
        out.close()
    }
    def toCsv(value) {
        if(!value) return ""
        return '"' + value.replaceAll('"', '~"') + '"'
    }

    /**
     * Lists all unique keys from the key value pairs of all records owned by the requested data resource(s)
     *
     * @param druid one or more DR UIDs (comma-separated if there are more than 1)
     * @return JSON list of unique key names
     */
    def listKeys() {
        if (!params.druid) {
            response.status = HttpStatus.SC_BAD_REQUEST
            response.sendError(HttpStatus.SC_BAD_REQUEST, "Must provide a comma-separated list of druid value(s).")
        } else {
            List<String> druids = params.druid.split(",")

            def kvps = SpeciesListKVP.withCriteria {
                "in"("dataResourceUid", druids)

                projections {
                    distinct("key")
                }

                order("key")
            }

            render kvps as JSON
        }
    }

    /**
     * Finds species list items that contains specific keys
     *
     * @param druid one or more DR UIDs (comma-separated if there are more than 1). Mandatory.
     * @param keys one or more KVP keys (comma-separated if there are more than 1). Mandatory.
     * @param format either "json" or "csv". Optional - defaults to json. Controls the output format.
     *
     * @return if format = json, {scientificName1: [{key: key1, value: value1}, ...], scientificName2: [{key: key1, value: value1}, ...]}. If format = csv, returns a CSV download with columns [ScientificName,Key1,Key2...].
     */
    def listItemsByKeys() {
        if (!params.druid || !params.keys) {
            response.status = HttpStatus.SC_BAD_REQUEST
            response.sendError(HttpStatus.SC_BAD_REQUEST, "Must provide a comma-separated list of druid value(s) and a comma-separated list of key(s). Parameter 'format' is optional ('json' or 'csv').")
        } else {
            List<String> druids = params.druid.split(",")
            List<String> keys = params.keys.split(",")

            def listItems = SpeciesListItem.withCriteria {
                projections {
                    property "rawScientificName"
                    kvpValues {
                        property "key"
                        property "value"
                    }
                }

                "in"("dataResourceUid", druids)

                kvpValues {
                    "in"("key", keys)
                }

                order("rawScientificName")
            }

            Map<String, List> results = [:]

            listItems.each {
                if (!results.containsKey(it[0])) {
                    results[it[0]] = []
                }
                results[it[0]] << [key: it[1], value: it[2]]
            }

            if (!params.format || params.format.toLowerCase() == "json") {
                render results as JSON
            } else if (params.format.toLowerCase() == "csv") {
                StringWriter out = new StringWriter();
                CSVWriter csv = new CSVWriter(out)

                csv.writeNext((["ScientificName"] << keys.sort()).flatten() as String[])

                results.each { key, value ->
                    List line = []

                    line << key
                    results[key].each {
                        line << it.value
                    }

                    csv.writeNext(line as String[])
                }

                render(contentType: "text/csv", text: out.toString())
            }
        }
    }

    def filterLists() {
        def json = request.getJSON()
        if (!json.scientificNames) {
            response.status = HttpStatus.SC_BAD_REQUEST
            response.sendError(HttpStatus.SC_BAD_REQUEST, "Must provide a JSON body with a mandatory list of scientific names to filter on. An optional list of data resource ids (drIds) can also be provided.")
        } else {
            List<String> results = queryService.filterLists(json.scientificNames, json.drIds ?: null)

            render results as JSON
        }
    }
}
