%{--
  - Copyright (C) 2012 Atlas of Living Australia
  - All Rights Reserved.
  -
  - The contents of this file are subject to the Mozilla Public
  - License Version 1.1 (the "License"); you may not use this file
  - except in compliance with the License. You may obtain a copy of
  - the License at http://www.mozilla.org/MPL/
  -
  - Software distributed under the License is distributed on an "AS
  - IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
  - implied. See the License for the specific language governing
  - rights and limitations under the License.
  --}%
<!doctype html>
<html>
<head>
    <r:require modules="application" />
    <meta name="layout" content="${grailsApplication.config.skin.layout}" />
    <title>
        <g:message code="speciesList.list.title" /> | ${grailsApplication.config.skin.orgNameLong}
    </title>
</head>

<body>
<div id="content" class="container-fluid">
    <header id="page-header" class="page-header">
        %{-- TITLE --}%
        <div class="page-header__title">
            <h1 class="page-header__title">
                <g:message code="speciesList.list.title" />
            </h1>

            <div class="page-header__subtitle">
                <div>
                    <g:message code="general.listDescription" />
                </div>

                <div>
                    <g:message code="general.deleteDescription" />
                </div>
            </div>
        </div>

        %{-- LINKS --}%
        <div class="page-header-links">
            <a href="${request.contextPath}/public/speciesLists" class="page-header-links__link">
                <g:message code="general.speciesLists" />
            </a>

            %{-- Not sure what will become of this page but we are not going to the following links here right now. --}%

            %{--
            <a title="My Lists" href="${request.contextPath}/speciesList/list" class="page-header-links__link">
                <g:message code="general.myLists" />
            </a>
            --}%

            %{--
            <g:link controller="speciesList" action="upload" title="Add Species List" class="page-header-links__link">
                <g:message code="general.uploadList" />
            </g:link>
            --}%
        </div>
    </header>

    <g:if test="${lists && total > 0}">
        <div class="row">
            <div class="col">
                %{--
                <p>
                    <g:message code="general.listDescription" />
                    <g:message code="general.deleteDescription" />
                </p>
                --}%

                <div class="float-right">
                    <g:render template="/pageSize" />
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col">
                <g:render template="/speciesList" />
            </div>
        </div>
    </g:if>
    <g:else>
        <div class="row">
            <div class="col">
                <p>
                    <g:message code="speciesList.list.noAvailable" />
                </p>
            </div>
        </div>
    </g:else>
</body>
</html>
