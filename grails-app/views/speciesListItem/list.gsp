<!doctype html>
<g:set var="bieUrl" value="${grailsApplication.config.bie.baseURL}" />
<g:set var="collectoryUrl" value="${grailsApplication.config.collectory.baseURL}" />
<g:set var="maxDownload" value="${grailsApplication.config.downloadLimit}" />
<g:set var="userCanEditPermissions" value="${
    (speciesList.username == request.getUserPrincipal()?.attributes?.email || request.isUserInRole('ROLE_ADMIN'))
}"/>
<g:set
    var="userCanEditData"
    value="${(
        speciesList.username == request.getUserPrincipal()?.attributes?.email ||
        request.isUserInRole('ROLE_ADMIN') ||
        request.getUserPrincipal()?.attributes?.userid in speciesList.editors
    )}"
/>
<html>
    <head>
        <meta name="layout" content="${grailsApplication.config.skin.layout}" />

        <title>
            <g:message code="general.speciesLists" />
        </title>

        <script type="text/javascript">
            function reloadWithMax(el) {
                var max = $(el).find(":selected").val();
                var params = {
                    fq: [ ${'\"' + (fqs ? fqs.join('\", \"') : '') + '\"'} ],
                    max: max,
                    sort: "${params.sort}",
                    order: "${params.order}",
                    offset: "${params.offset?:0}"
                };
                var paramStr = jQuery.param(params, true);

                window.location.href = window.location.pathname + '?' + paramStr;
            }
        </script>
    </head>

    <body>
        <%-- Download dialog modal --%>
        <div class="inline-block">
            <g:render template="/download" />
        </div>

        <div id="content">
            <header id="page-header" class="page-header">
                <%-- TITLE --%>
                <div class="page-header__title">
                    <h1 class="page-header__title">
                        ${speciesList?.listName}
                    </h1>

                    <%-- TODD: New text.
                    <div class="page-header__subtitle">
                        <div>
                            <g:message code="general.listDescription" />
                        </div>

                        <div>
                            <g:message code="general.deleteDescription" />
                        </div>
                    </div>
                    --%>
                </div>

                <%-- LINKS --%>
                <div class="page-header-links">
                    <a href="${request.contextPath}/public/speciesLists" class="page-header-links__link">
                        <span class="fa fa-arrow-left"></span>
                        <g:message code="general.speciesLists" />
                    </a>

                    <a
                        href="${request.contextPath}/speciesList/occurrences/${params.id}${params.toQueryString()}&type=Search"
                        title="${message(code: 'speciesListItem.list.viewUpTo', args: [maxDownload])}"
                        class="page-header-links__link"
                    >
                        <span class="fa fa-list"></span>
                        <g:message code="speciesListItem.list.viewOccurrence" />
                    </a>

                    <%-- TODO: Uncomment when spatial portal is finished
                    <a href="${request.contextPath}/speciesList/spatialPortal/${params.id}${params.toQueryString()}&type=Search"
                        title="${message(code: 'speciesListItem.list.viewSpatialDecription')}"
                        class="page-header-links__link">

                        <g:message code="speciesListItem.list.viewSpatial" />
                    </a>
                    --%>
                </div>
            </header>

            <g:if test="${flash.message}">
                <div class="row">
                    <div class="message alert alert-info">
                        <b>
                            <g:message code="general.alert" />:
                        </b>
                        ${flash.message}
                    </div>
                </div>
            </g:if>

            <section class="search-section">
                <form class="input-plus">
                    <input type="text" id="queryInput" name="query" class="input-plus__field">
                    <button
                        type="sumbit"
                        class="input-plus__addon erk-button erk-button--dark"
                        onclick="searchByQuery()"
                    >
                        <span class="fa fa-search"></span>
                        <g:message code="general.search" />
                    </button>
                </form>

                <div class="item-search__count-line">
                    <g:message code="speciesListItem.list.taxonNumber" />:
                    <span class="item-search__count">
                        ${totalCount},
                    </span>

                    <g:message code="speciesListItem.list.distinctSpecies" />:
                    <span class="item-search__count">
                        ${distinctCount}
                    </span>

                    <g:if test="${hasUnrecognised && noMatchCount != totalCount}">
                        ,

                        <g:link
                            action="list"
                            id="${params.id}"
                            title="${message(code: 'speciesListItem.list.viewUnrecognised')}"
                            params="${[fq:sl.buildFqList(fqs:fqs, fq:' guid:null'), max:params.max]}"
                        >
                            <g:message code="speciesListItem.list.unknownTaxa" />

                            <span class="item-search__count">
                                ${noMatchCount}
                            </span>
                        </g:link>
                    </g:if>
                </div>

                <g:if test="${query || fqs}">
                    <div class="item-search__filter-line vertical-block">
                        <div class="active-filters">
                            <span class="active-filters__title">
                                <g:message code="speciesListItem.list.filters" />
                            </span>

                            <g:if test="${query}">
                                <span class="active-filters__filter">
                                    <span class="active-filters__label">
                                        <g:message code="general.scientificName" />: ${query}
                                    </span>

                                    <span
                                        class="fa fa-close active-filters__close-button"
                                        onclick="clearQuery()"
                                    >
                                    </span>
                                </span>
                            </g:if>

                            <g:each in="${fqs}" var="fq">
                                <span class="active-filters__filter">
                                    <span class="active-filters__label">
                                        ${fq}
                                    </span>

                                    <span
                                        class="fa fa-close active-filters__close-button"
                                        onclick="removeFq('${fq}')"
                                    >
                                    </span>
                                </span>
                            </g:each>

                            <g:if test="${query && fqs}">
                                <span
                                    class="active-filters__clear-all-button"
                                    onclick="clearAll()"
                                >
                                    <g:message code="public.speciesLists.clearSearch" />
                                </span>
                            </g:if>
                        </div>
                    </div>
                </g:if>
            </section>

            <div class="list-items-header vertical-block">
                <span class="fa fa-info-circle"></span>
                <g:message code="speciesListItem.list.refine" />
            </div>

            <div class="row">
                <div class="col-sm-5 col-md-3" id="facets-column">
                    <div class="card card-body detached-card">
                        <g:if test="${facets.size()>0 || params.fq}">
                            <g:set var="fqs" value="${params.list('fq')}" />

                            <g:each in="${facets}" var="entry">
                                <g:if test="${entry.key == " listProperties"}">
                                    <g:each in="${facets.get(" listProperties")}" var="value">
                                        <g:render
                                            template="facet"
                                            model="${[key:value.getKey(), values:value.getValue(), isProperty:true]}"
                                        />
                                    </g:each>
                                </g:if>
                                <g:else>
                                    <g:render
                                        template="facet"
                                        model="${[key:entry.key, values:entry.value, isProperty:false]}" />
                                </g:else>
                            </g:each>
                        </g:if>
                    </div>
                </div>

                <div class="col-sm-7 col-md-9">
                    <ul class="nav nav-tabs" role="tablist">
                        <li class="nav-item">
                            <a
                                class="nav-link active"
                                data-toggle="tab"
                                href="#list-tab"
                                role="tab"
                            >
                                <g:message code="speciesListItem.list.list" />
                            </a>
                        </li>

                        <li class="nav-item">
                            <a
                                class="nav-link"
                                data-toggle="tab"
                                href="#grid-tab"
                                role="tab"
                            >
                                <g:message code="speciesListItem.list.grid" />
                            </a>
                        </li>
                    </ul>

                    <div class="tab-content">
                        <g:render template="list-controls" />

                        <div id="list-tab" class="tab-pane active" role="tabpanel">
                            <g:render template="list-tab" />
                        </div>

                        <div id="grid-tab" class="tab-pane" role="tabpanel">
                            <g:render template="grid-tab" />
                        </div>

                        <div class="row">
                            <div class="col">
                                <div class="pagination float-left">
                                    <g:if test="${params.fq}">
                                        <g:paginate
                                            total="${totalCount}"
                                            action="list"
                                            omitLast="true"
                                            next="${message(code: 'default.paginate.next')}"
                                            prev="${message(code: 'default.paginate.prev')}"
                                            id="${params.id}"
                                            params="${[query: params.query]}"
                                        />
                                    </g:if>

                                    <g:else>
                                        <g:paginate total="${totalCount}" action="list" id="${params.id}" />
                                    </g:else>
                                </div>
                            </div>
                        </div>
                    </div>

                    <%-- Output the BS modal divs (hidden until called) --%>
                    <%-- ToDo: implement edit form if needed
                    <g:each var="result" in="${results}" status="i">
                        <g:set var="recId" value="${result.id}" />

                        <g:if test="${userCanEditData}">
                            <div class="modal fade" id="editRecord_${recId}">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                                        ×
                                    </button>

                                    <h3>
                                        <g:message code="general.editRecord" />
                                    </h3>
                                </div>

                                <div class="modal-body">
                                    <p>
                                        <img src="${assetPath(src: 'spinner.gif')}" alt="spinner icon" />
                                    </p>
                                </div>

                                <div class="modal-footer">
                                    <button class="erk-button erk-button--light" data-dismiss="modal" aria-hidden="true">
                                        <g:message code="speciesListItem.list.cancel" />
                                    </button>

                                    <button
                                        class="erk-button erk-button--light saveRecord"
                                        data-modal="#editRecord_${recId}"
                                        data-id="${recId}"
                                    >
                                        <g:message code="speciesListItem.list.saveChanges" />
                                    </button>
                                </div>
                            </div>

                            <div class="modal fade" id="deleteRecord_${recId}">
                                <div class="modal-header">
                                    <h3>
                                        <g:message code="speciesListItem.list.confirmDelete" />
                                    </h3>
                                </div>

                                <div class="modal-body">
                                    <p>
                                        <g:message code="speciesListItem.list.deleteDescription" />
                                        <span>
                                            ${result.rawScientificName}
                                        </span>
                                    </p>
                                </div>

                                <div class="modal-footer">
                                    <button class="erk-button erk-button--light" data-dismiss="modal" aria-hidden="true">
                                        <g:message code="speciesListItem.list.cancel" />
                                    </button>

                                    <button
                                        class="erk-button erk-button--light deleteSpecies"
                                        data-modal="#deleteRecord_${recId}"
                                        data-id="${recId}"
                                    >
                                        <g:message code="" />
                                    </button>
                                </div>
                            </div>
                        </g:if>
                    </g:each>
                    --%>
                </div>
            </div>

            <%-- List info modal --%>
            <div id="list-info-modal" class="modal fade">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h3>
                                ${speciesList.listName?:'&nbsp;'}
                            </h3>
                        </div>

                        <div class="modal-body">
                            <g:render template="list-info" />
                        </div>

                        <div class="modal-footer">
                            <button
                                type="button"
                                class="erk-button erk-button--light"
                                data-dismiss="modal"
                            >
                                <g:message code="general.btn.close" />
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script>
            var paramString = window.location.href.split('?')[1] || "";
            var params = paramString.split('&').map(function(param) {
                var parts = param.split('=');

                return {
                    key: parts[0],
                    value: parts[1]
                };
            });

            function reloadWithParams(params) {
                var queryString = params.map(function(param) {
                    return param.key + '=' + param.value;
                }).join('&');

                window.location.href = window.location.pathname + '?' + queryString;
            }

            function searchByQuery() {
                var query = document.getElementById('queryInput').value;

                var newParams = params.filter(function(param) {
                    return params.key !== 'query';
                });

                newParams.push({
                    key: 'query',
                    value: query
                });

                reloadWithParams(newParams);
            }

            function clearQuery() {
                var newParams = params.filter(function(param) {
                    return param.key !== 'query';
                });

                reloadWithParams(newParams);
            }

            function removeFq(fq) {
                var encodedfq = window.encodeURIComponent(fq);
                var newParams = [];

                params.forEach(function(param) {
                    if(param.key === 'fq') {
                        var facets = param.value.split(',').filter(function(facet) {
                            return facet !== encodedfq;
                        });

                        if(facets.length > 1) {
                            newParams.push({
                                key: fq,
                                value: facets.join(',')
                            });
                        }
                    } else {
                        newParams.push(param);
                    }
                });

                reloadWithParams(newParams);
            }

            function clearAll() {
                reloadWithParams([]);
            }

            $(document).ready(function() {
                // make table header cells clickable
                $("table .sortable").each(function(i) {
                    var href = $(this).find("a").attr("href");

                    $(this).click(function() {
                        window.location.href = href;
                    });
                });

                $('a[data-toggle="tab"]').on('shown.bs.tab', function(e) {
                    var target = $(e.target).attr('href');

                    if(window.history) {
                        window.history.replaceState({}, '', target);
                    } else {
                        window.location.hash = target;
                    }

                    $('a.step').each(function(index, link) {
                        var url = link.href.split('#');

                        link.href = url[0] + target;
                    });
                });

                if(window.location.hash) {
                    $('a[href="' + window.location.hash + '"]').tab('show');
                }
            });
        </script>
    </body>
</html>
