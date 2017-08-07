<%-- Template for diplaying a single facet for a species list. --%>

<g:set var="facetId" value="${sl.facetAsId(key:key, prefix:"facet")}" />

<div class="FieldName">
    ${key}
</div>

<div id="${facetId}" class="subnavlist">
    <ul class="erk-ulist">
        <g:set var="i" value="${0}"/>

        <g:while test="${i < 4 && i < values.size()}">
            <g:set var="arr" value="${values.get(i)}"/>

            <g:if test="${isProperty}">
                <li class="erk-ulist--item">
                    <g:link
                        id="${params.id}"
                        action="list"
                        params="${[fq:sl.buildFqList(fqs:fqs, fq:"kvp ${arr[0]}:${arr[1]}"), max:params.max]}"
                    >
                        ${arr[2]?:arr[1]}
                    </g:link>

                    (${arr[3]})
                </li>
            </g:if>
            <g:else>
                <li class="erk-ulist--item">
                    <g:link
                        action="list" id="${params.id}"
                        params="${[fq:sl.buildFqList(fqs:fqs, fq:"${key}:${arr[0]}"), max:params.max]}"
                    >
                        ${arr[0]}
                    </g:link>

                    (${arr[1]})
                </li>
            </g:else>

            <% i++ %>
        </g:while>

        <g:if test="${values.size() > 4}">
            <li class="erk-ulist--item showHide">
                <i class="fa fa-hand-o-right"></i>

                <a
                    id="${sl.facetAsId(key:key, prefix:'multi')}"
                    href="${sl.facetAsId(key:key, prefix:'#div')}"
                    class="multipleFacetsLinkZ"
                    role="button"
                    data-toggle="modal"
                    title="${message(code: 'speciesListItem.facet.seeFull')}"
                >
                    <g:message code="speciesListItem.facet.choose"/>
                </a>
            </li>
        </g:if>
    </ul>

    <!-- modal popup for "choose more" link -->
    <div
        id="${sl.facetAsId(key:key, prefix:'div')}"
        class="modal fade"
        tabindex="-1"
        role="dialog"
        aria-labelledby="multipleFacetsLabel"
        aria-hidden="true"
    >
        <!-- BS modal div -->
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        ×
                    </button>

                    <h3 class="multipleFacetsLabel">
                        <g:message code="speciesListItem.facet.refine"/>
                    </h3>
                </div>

                <div class="modal-body">
                    <table class="table table-bordered table-sm table-striped">
                        <thead>
                            <tr>
                                <th class="indexCol" width="80%">
                                    ${key}
                                </th>
                                <th style="border-right-style: none;text-align: right;">
                                    <g:message code="speciesListItem.facet.count"/>
                                </th>
                            </tr>
                        </thead>

                        <tbody>
                            <g:each in="${values}" var="arr">
                                <tr>
                                    <g:if test="${isProperty}">
                                        <td>
                                            <g:link
                                                id="${params.id}"
                                                action="list"
                                                params="${[fq:sl.buildFqList(fqs:fqs, fq:"kvp ${arr[0]}:${arr[1]}"), max:params.max]}"
                                            >
                                                ${arr[2]?:arr[1]}
                                            </g:link>
                                        </td>

                                        <td style="text-align: right; border-right-style: none;">
                                            ${arr[3]}
                                        </td>
                                    </g:if>

                                    <g:else>
                                        <td>
                                            <g:link
                                                id="${params.id}"
                                                action="list"
                                                params="${[fq:sl.buildFqList(fqs:fqs, fq:"${key}:${arr[0]}"), max:params.max]}"
                                            >
                                                ${arr[0]}
                                            </g:link>
                                        </td>

                                        <td style="text-align: right; border-right-style: none;">
                                            ${arr[1]}
                                        </td>
                                    </g:else>
                                </tr>
                            </g:each>
                        </tbody>
                    </table>
                </div>

                <div class="modal-footer" style="text-align: left;">
                    <button
                        class="erk-button erk-button--light"
                        data-dismiss="modal"
                        aria-hidden="true"
                        style="float:right;"
                    >
                        <g:message code="general.close"/>
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>
