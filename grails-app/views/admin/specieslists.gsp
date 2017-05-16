<%--
  User: Natasha Carter
  Date: 14/03/13
  Time: 10:18 AM
  Provide access to all the editable information at a species list level
--%>

<!doctype html>
<html>
<head>
    <meta name="layout" content="${grailsApplication.config.skin.layout}"/>
    <title>Species lists | ${grailsApplication.config.skin.orgNameLong}</title>
    <r:require modules="application"/>
</head>

<body class="">
<div id="content" class="container-fluid">
    <header id="page-header">
        %{-- TITLE --}%
        <div class="row">
            <div class="col">
                <div class="page-header-title">
                    <h1 class="page-header-title__title">
                        Species lists
                    </h1>

                    <div class="page-header-title__subtitle">
                        <div>
                            Below is a listing of all species lists that can be administered.
                        </div>
                    </div>
                </div>
            </div>
        </div>

        %{-- LINKS --}%
        <div class="row">
            <div class="col">
                <div class="page-header-links">
                    <a href="${request.contextPath}/public/speciesLists" class="page-header-links__link">
                        Species lists
                    </a>

                    %{--
                    <a title="My Lists" href="${request.contextPath}/speciesList/list" class="page-header-links__link">
                        My Lists
                    </a>
                    --}%

                    <g:link controller="speciesList" action="upload" title="Add Species List" class="page-header-links__link">
                        Upload a list
                    </g:link>

                    <a title="Rematch" href="${request.contextPath}/speciesList/rematch" class="page-header-links__link">
                        Rematch All
                    </a>

                    <g:if test="${lists && total>0}">
                        <a href="${g.createLink(action: 'updateListsWithUserIds')}" class="page-header-links__link">
                            Update List user details (name & email address)
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
                        <g:render template="/speciesList"/>
                    </div>
                </div>
            </g:if>
            <g:else>
                <p>
                    There are no Species Lists available
                </p>
            </g:else>
        </div>
    </div>
</div>
</body>
</html>
