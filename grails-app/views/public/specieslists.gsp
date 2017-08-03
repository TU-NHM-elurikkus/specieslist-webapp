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
        <g:message code="general.speciesLists" /> | ${grailsApplication.config.skin.orgNameLong}
    </title>
</head>

<body>
    <div id="content" class="container-fluid">
        <header id="page-header" class="page-header">
            <h1 class="page-header__title">
                <g:message code="general.speciesLists" />
            </h1>

            <div class="page-header__subtitle">
                <g:message code="public.speciesLists.description" />
            </div>
        </header>

        <div class="row" id="public-specieslist">
            <div class="col">
                <g:if test="${flash.message}">
                    <div class="message alert alert-info">
                        <button type="button" class="close" onclick="$(this).parent().hide()">
                            ×
                        </button>

                        <b><g:message code="general.alert" />:</b> ${flash.message}
                    </div>
                </g:if>

                <g:if test="${lists && total>0}">
                    <div class="row">
                        <div class="col">
                            <form class="list-search-form" >
                                <div class="input-plus">
                                    <input class="input-plus" id="appendedInputButton" name="q" type="text"
                                    value="${params.q}" placeholder="Search in list name, description or owner" />

                                    <button class="erk-button erk-button--dark input-plus__addon" type="submit">
                                        <g:message code="general.search" />
                                    </button>
                                </div>
                            </form>

                            <form class="list-search-form" >
                                <g:if test="${params.q}">
                                    <button class="erk-button erk-button--light" type="submit">
                                        <g:message code="public.speciesLists.clearSearch" />
                                    </button>
                                </g:if>
                            </form>

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
                <g:elseif test="${params.q}">
                    <form class="list-search-form" >
                        <p>
                            <g:messages code="public.speciesLists.noListsFound" /> <strong>${params.q}</strong>
                        </p>

                        <button class="erk-button erk-button--light" type="submit">
                            <g:message code="public.speciesLists.clearSearch" />
                        </button>
                    </form>
                </g:elseif>
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
