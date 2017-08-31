<!doctype html>
<html>

    <head>
        <meta name="layout" content="${grailsApplication.config.skin.layout}" />
        <title>
            <g:message code="general.speciesLists" /> | ${grailsApplication.config.skin.orgNameLong}
        </title>
    </head>

    <body class="">
        <div id="content" class="container-fluid">
            <header id="page-header">
                <%-- TITLE --%>
                <div class="row">
                    <div class="col">
                        <div class="page-header-title">

                            <h1 class="page-header-title__title">
                                <g:message code="general.speciesLists" />
                            </h1>

                            <div class="page-header-title__subtitle">
                                <div>
                                    <g:message code="admin.header.description" />
                                </div>
                            </div>

                        </div>
                    </div>
                </div>

                <%-- LINKS --%>
                <div class="row">
                    <div class="col">
                        <div class="page-header-links">
                            <a href="${request.contextPath}/public/speciesLists" class="page-header-links__link">
                                <g:message code="general.speciesLists" />
                            </a>

                            <%--
                            <a title="My Lists" href="${request.contextPath}/speciesList/list" class="page-header-links__link">
                                <g:message code="general.myLists" />
                            </a>
                            --%>

                            <g:link
                                controller="speciesList"
                                action="upload"
                                title="Add Species List"
                                class="page-header-links__link"
                            >
                                <g:message code="upload.heading" />
                            </g:link>

                            <a
                                title="Rematch"
                                href="${request.contextPath}/speciesList/rematch"
                                class="page-header-links__link"
                            >
                                <g:message code="admin.rematchAll" />
                            </a>

                            <g:if test="${lists && total>0}">
                                <a
                                    href="${g.createLink(action: 'updateListsWithUserIds')}"
                                    class="page-header-links__link"
                                >
                                    <g:message code="admin.updateUserDetails" />
                                </a>
                            </g:if>
                        </div>
                    </div>
                </div>
            </header>

            <div class="row">
                <div class="col">
                    <g:if test="${flash.message}">
                        <div class="message alert alert-info">
                            ${flash.message}
                        </div>
                    </g:if>

                    <g:if test="${lists && total>0}">
                        <div class="row">
                            <div class="col-12">
                                <g:render template="/speciesList" />
                            </div>
                        </div>
                    </g:if>
                    <g:else>
                        <p>
                            <g:message code="general.noListsAvailable" />
                        </p>
                    </g:else>
                </div>
            </div>
        </div>
    </body>
</html>
