<div class="speciesList table-responsive">
    <table class="table table-sm" id="speciesListTable">
        <thead>
            <tr>
                <th class="action">
                    <g:message code="general.action" />
                </th>

                <g:sortableColumn
                    property="rawScientificName"
                    params="${[fq: fqs, query: query]}"
                    titleKey="general.suppliedName"
                />

                <g:sortableColumn
                    property="matchedName"
                    params="${[fq: fqs, query: query]}"
                    titleKey="general.scientificName"
                />

                <g:sortableColumn
                    property="imageUrl"
                    params="${[fq: fqs, query: query]}"
                    titleKey="speciesListItem.list.image"
                />

                <g:sortableColumn
                    property="author"
                    params="${[fq: fqs, query: query]}"
                    titleKey="speciesListItem.list.author"
                />

                <g:sortableColumn
                    property="commonName"
                    params="${[fq: fqs, query: query]}"
                    titleKey="speciesListItem.list.commonName"
                />

                <g:each in="${keys}" var="key">
                    <th>
                        ${key}
                    </th>
                </g:each>
            </tr>
        </thead>

        <tbody>
            <g:each var="result" in="${results}" status="i">
                <g:set var="recId" value="${result.id}" />
                <g:set var="bieTitle">
                    <g:message code="general.speciesPage" />
                    <span>
                        ${result.rawScientificName}
                    </span>
                </g:set>

                <tr id="row_${recId}">
                    <td class="action">
                        <center>
                            <a
                                class="viewRecordButton"
                                href="#viewRecord"
                                title="view record"
                                data-id="${recId}"
                            >
                                <i class="fa fa-info-circle"></i>
                            </a>

                            <g:if test="${userCanEditData}">
                                <a
                                    href="#"
                                    title="edit"
                                    data-remote="${createLink(controller: 'editor', action: 'editRecordScreen', id: result.id)}"
                                    data-target="#editRecord_${recId}"
                                    data-toggle="modal"
                                >
                                    <i class="fa fa-pencil"></i>
                                </a>

                                <a
                                    href="#"
                                    title="delete"
                                    data-target="#deleteRecord_${recId}"
                                    data-toggle="modal"
                                >
                                    <i class="fa fa-trash-o"></i>
                                </a>
                            </g:if>
                        </center>
                    </td>

                    <td class="rawScientificName">
                        ${fieldValue(bean: result, field: "rawScientificName")}

                        <g:if test="${result.guid == null}">
                            <br />
                            <strong>
                                <g:message code="speciesListItem.list.unmatched" />
                            </strong>
                            -
                            <g:message code="speciesListItem.list.try" />
                            <a
                                href="http://google.com/search?q=${fieldValue(bean: result, field: 'rawScientificName').trim()}"
                                target="google"
                            >
                                <g:message code="speciesListItem.list.google" />
                            </a>
                            <g:message code="speciesListItem.list.or" />
                            <a
                                href="${grailsApplication.config.biocache.baseURL}/occurrences/search?q=${fieldValue(bean: result, field: 'rawScientificName').trim()}"
                                target="biocache"
                            >
                                <g:message code="speciesListItem.list.occurrences" />
                            </a>
                        </g:if>
                    </td>

                    <td class="matchedName">
                        <g:if test="${result.guid}">
                            <a href="${bieUrl}/species/${result.guid}">
                                ${result.matchedName}
                            </a>
                        </g:if>
                        <g:else>
                            ${result.matchedName}
                        </g:else>
                    </td>

                    <td id="img_${result.guid}">
                        <g:if test="${result.imageUrl}">
                            <a href="${bieUrl}/species/${result.guid}">
                                <img
                                    style="max-width: 400px;"
                                    src="${result.imageUrl}"
                                    class="smallSpeciesImage"
                                />
                            </a>
                        </g:if>
                    </td>

                    <td>
                        ${result.author}
                    </td>

                    <td id="cn_${result.guid}">
                        ${result.commonName}
                    </td>

                    <g:each in="${keys}" var="key">
                        <g:set var="kvp" value="${result.kvpValues.find {it.key == key}}" />
                        <g:set var="val" value="${kvp?.vocabValue?:kvp?.value}" />

                        <td class="kvp ${val?.length() > 35 ? 'scrollWidth':''}">
                            <div>
                                ${val}
                            </div>
                        </td>
                    </g:each>
                </tr>
            </g:each>
        </tbody>
    </table>
</div>
