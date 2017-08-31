<g:each var="result" in="${results}">
    <g:set var="recId" value="${result.id}" />
    <g:set var="bieTitle">
        <g:message code="general.speciesPage" />
        <span>
            ${result.rawScientificName}
        </span>
    </g:set>

    <div class="gallery-thumb">
        <a
            class="cbLink viewRecordButton"
            rel="thumbs"
            href="#viewRecord"
            data-id="${recId}"
        >
            <img
                class="gallery-thumb__img"
                src="${result.imageUrl?:g.createLink(uri:'/assets/infobox_info_icon.png')}"
                alt=""
            />
        </a>

        <g:set var="displayName">
            <span>
                <g:if test="${result.guid == null}">
                    ${fieldValue(bean: result, field: "rawScientificName")}
                </g:if>
                <g:else>
                    ${result.matchedName}
                </g:else>
            </span>
        </g:set>

        <div class="gallery-thumb__footer">
            ${displayName}
        </div>
    </div>
</g:each>
