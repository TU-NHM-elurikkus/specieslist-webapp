<div class="speciesList table-responsive">
    <table class="table table-sm" id="speciesListTable">
        <thead>
            <tr>
                <g:sortableColumn
                    property="matchedName"
                    params="${[fq: fqs, query: query]}"
                    titleKey="general.scientificName"
                    id="result-matched-name"
                />

                <%--
                    <g:sortableColumn
                        property="rawScientificName"
                        params="${[fq: fqs, query: query]}"
                        titleKey="general.suppliedName"
                        id="result-supplied-name"
                    />
                --%>

                <g:sortableColumn
                    property="imageUrl"
                    params="${[fq: fqs, query: query]}"
                    titleKey="speciesListItem.list.image"
                    id="result-image"
                />

                <g:sortableColumn
                    property="author"
                    params="${[fq: fqs, query: query]}"
                    titleKey="speciesListItem.list.author"
                    id="result-author"
                />

                <g:sortableColumn
                    property="commonName"
                    params="${[fq: fqs, query: query]}"
                    titleKey="speciesListItem.list.commonName"
                    id="result-common-name"
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
                <tr id="row_${recId}">
                    <td class="matchedName">
                        <g:if test="${result.guid}">
                            <a href="${bieUrl}/species/${result.guid}">
                                <span class="fa fa-tag"></span> ${result.matchedName}
                            </a>
                        </g:if>
                        <g:else>
                            ${result.matchedName}
                        </g:else>
                    </td>

                    <%--
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
                    --%>

                    <td id="img_${result.guid}">
                        <a
                            href="${result.imageUrl ?: assetPath(src: 'fa-image.svg')}"
                            data-id="${result.id}"
                            data-toggle="lightbox"
                            title="${message(code: 'gallery.thumb.title')}"
                        >
                            <img
                                class="img-fluid smallSpeciesImage"
                                src="${sl.getImageUrl(
                                    imgUrl: result.imageUrl,
                                    suffix: '__thumb',
                                    defImgUrl: assetPath(src: 'fa-image.svg')
                                )}"
                                alt="${message(code: 'general.thumbnail.alt')}"
                            />
                        </a>
                    </td>

                    <td>
                        ${result.author}
                    </td>

                    <td id="cn_${result.guid}">
                        ${result.commonName}
                    </td>

                    <g:each in="${keys}" var="key">
                        <g:set var="kvp" value="${result.kvpValues.find {it.key == key}}" />
                        <g:set var="val" value="${kvp?.vocabValue ?: kvp?.value}" />

                        <td class="kvp ${val?.length() > 35 ? 'scrollWidth' : ''}">
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
