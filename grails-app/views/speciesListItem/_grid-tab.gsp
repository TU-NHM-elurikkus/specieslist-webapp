<g:each var="result" in="${results}">
    <g:set var="recId" value="${result.id}" />
    <div class="gallery-thumb">
        <a
            href="${result.imageUrl ?: assetPath(src: 'fa-image.svg')}"
            title="${message(code: 'gallery.thumb.title')}"
            data-id="${recId}"
            data-toggle="lightbox"
            data-gallery="grid-gallery"
        >
            <img
                class="gallery-thumb__img"
                src="${sl.getImageUrl(
                    imgUrl: result.imageUrl,
                    suffix: '__small',
                    defImgUrl: assetPath(src: 'fa-image.svg')
                )}"
                alt="${message(code: 'general.thumbnail.alt')}"
            />
        </a>

        <div class="gallery-thumb__footer">
            <span>
                <g:if test="${result.guid == null}">
                    ${fieldValue(bean: result, field: "rawScientificName")}
                </g:if>
                <g:else>
                    ${result.matchedName}; ${result.commonName}
                </g:else>
            </span>
        </div>
    </div>
</g:each>
