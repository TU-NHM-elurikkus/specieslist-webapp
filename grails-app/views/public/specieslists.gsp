<!doctype html>
<html>
    <head>
        <meta name="layout" content="generic" />

        <title>
            <g:message code="general.speciesLists"/>
        </title>
    </head>

    <body>
        <div id="content">
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

                    <g:if test="${lists && total > 0}">
                        <div class="search-section">
                            <form class="input-plus">
                                <input
                                    id="appendedInputButton"
                                    class="input-plus__field"
                                    name="q"
                                    type="text"
                                    value="${params.q}"
                                    placeholder="${message(code: 'public.speciesLists.btn.search.placeholder')}"
                                />

                                <button class="erk-button erk-button--dark input-plus__addon">
                                    <span class="fa fa-search"></span>
                                    <g:message code="general.search"/>
                                </button>
                            </form>

                            <g:if test="${params.q}">
                                <p class="active-filters">
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
                                </p>
                            </g:if>
                        </div>

                        <g:render template="/speciesList"/>
                    </g:if>
                    <g:elseif test="${params.q}">
                        <p>
                            <g:message code="public.speciesLists.noListsFound"/>
                            <strong>
                                ${params.q}
                            </strong>
                        </p>

                        <a href="${request.contextPath}/public/speciesLists">
                            <span class="fa fa-arrow-left"></span>
                            <g:message code="public.speciesLists.backToSearch" />
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
