<!doctype html>
<html>
    <head>
        <meta name="layout" content="${grailsApplication.config.skin.layout}"/>
        <title>
            <g:message code="general.speciesLists"/> | ${grailsApplication.config.skin.orgNameLong}
        </title>

        <asset:stylesheet src="filters.css" />
    </head>

    <body>
        <div id="content" class="container-fluid">
            <header id="page-header" class="page-header">
                <h1 class="page-header__title">
                    <g:message code="general.speciesLists"/>
                </h1>

                <div class="page-header__subtitle">
                    <g:message code="public.speciesLists.description"/>
                </div>
            </header>

            <div class="row" id="public-specieslist">
                <div class="col">
                    <g:if test="${flash.message}">
                        <div class="message alert alert-info">
                            <button type="button" class="close" onclick="$(this).parent().hide()">
                                ×
                            </button>

                            <b>
                                <g:message code="general.alert"/>:
                            </b>
                            ${flash.message}
                        </div>
                    </g:if>

                    <g:if test="${lists && total>0}">
                        <div class="row list-search-row">
                            <div class="col-md-9 col-sm-12">
                                <div class="list-search-row__search">
                                    <form class="input-plus list-search-row__search-form">
                                        <input
                                            id="appendedInputButton"
                                            class="input-plus__field"
                                            name="q"
                                            type="text"
                                            value="${params.q}"
                                            placeholder="${message(code: 'general.searchPlaceHolder')}"
                                        />

                                        <button class="erk-button erk-button--dark input-plus__addon" type="submit">
                                            <g:message code="general.search"/>
                                        </button>
                                    </form>
                                </div>

                                <g:if test="${params.q}">
                                    <div class="active-filters vertical-block">
                                        <span class="active-filters__title">
                                            <g:message code="speciesListItem.list.filters" />
                                        </span>

                                        <span class="active-filters__filter">
                                            <span class="active-filters__label">
                                                <g:message code="public.speciesLists.query" />: ${params.q}
                                            </span>

                                            <span
                                                class="fa fa-close active-filters__close-button"
                                                onclick="resetFilters()"
                                            >
                                            </span>
                                        </span>
                                    </div>
                                </g:if>
                            </div>

                            <div class="list-search-row__pagination-controls col-md-3 col-sm-12">
                                <g:render template="/pageSize"/>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col">
                                <g:render template="/speciesList"/>
                            </div>
                        </div>
                    </g:if>
                    <g:elseif test="${params.q}">
                        <form class="list-search-form">
                            <p>
                                <g:messages code="public.speciesLists.noListsFound"/>
                                <strong>
                                    ${params.q}
                                </strong>
                            </p>

                            <button class="erk-button erk-button--light" type="submit">
                                <g:message code="public.speciesLists.clearSearch"/>
                            </button>
                        </form>
                    </g:elseif>
                    <g:else>
                        <p>
                            <g:message code="general.noListsAvailable"/>
                        </p>
                    </g:else>
                </div>
            </div>
        </div>

        <script>
            function resetFilters() {
                window.location.search = "";
            }
        </script>
    </body>
</html>
