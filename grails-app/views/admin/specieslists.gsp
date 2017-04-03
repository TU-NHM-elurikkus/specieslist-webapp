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
    <r:require modules="fancybox,application"/>
</head>

<body class="">
<div id="content" class="container">
    <header id="page-header">
        <div class="row">
            <div class="col">
                <div id="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item">
                            <a href="http://www.ala.org.au">
                                Home
                            </a>

                            <span class="divider">
                                <i class="fa fa-arrow-right"></i>
                            </span>
                        </li>

                        <li class="breadcrumb-item">
                            <a class="current" href="${request.contextPath}/public/speciesLists">
                                Species lists
                            </a>
                        </li>
                    </ol>
                </div>
            </div>
        </div>

        <div class="row">
            <hgroup class="col">
                <h1>
                    Species lists

                    <span class="float-right">
                        <a class="erk-button" title="Add Species List" href="${request.contextPath}/speciesList/upload">
                            Upload a list
                        </a>

                        <a class="erk-button" title="My Lists" href="${request.contextPath}/speciesList/list">
                            My Lists
                        </a>

                        <a class="erk-button" title="Rematch" href="${request.contextPath}/speciesList/rematch">
                            Rematch All
                        </a>
                    </span>
                </h1>
            </hgroup>
        </div>
    </header>

    <div class="row">
        <div class="col">
            <g:if test="${flash.message}">
                <div class="message alert alert-info">${flash.message}</div>
            </g:if>

            <g:if test="${lists && total>0}">
                <div class="row">
                    <div class="col-12">
                        <a href="${g.createLink(action: 'updateListsWithUserIds')}" class="erk-button">
                            Update List user details (name & email address)
                        </a>

                        <p>
                            Below is a listing of all species lists that can be administered.
                        </p>
                    </div>

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
