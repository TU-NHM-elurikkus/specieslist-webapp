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
            class="cbLink"
            rel="thumbs"
            href="${result.imageUrl?:g.createLink(uri:'/assets/infobox_info_icon.png')}"
            data-id="${recId}"
            data-toggle="lightbox"
            title="${message(code: 'gallery.thumb.title')}"
        >
            <img
                class="gallery-thumb__img"
                src="${result.imageUrl?:g.createLink(uri:'/assets/infobox_info_icon.png')}"
                alt=""
            />
        </a>

        <div class="gallery-thumb__footer">
            <span>
                <g:if test="${result.guid == null}">
                    ${fieldValue(bean: result, field: "rawScientificName")}
                </g:if>
                <g:else>
                    ${result.matchedName}
                </g:else>
            </span>
        </div>
    </div>
</g:each>
