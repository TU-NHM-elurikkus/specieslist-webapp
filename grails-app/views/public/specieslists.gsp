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
    <r:require modules="application"/>
    <meta name="layout" content="${grailsApplication.config.skin.layout}"/>
    <title>
        Species lists |${grailsApplication.config.skin.orgNameLong}
    </title>
</head>

<body>
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
                            This tool allows you to wrok with user species lists.
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </header>

    <div class="row" id="public-specieslist">
        <div class="col">
            <g:if test="${flash.message}">
                <div class="message alert alert-info">
                    <button type="button" class="close" onclick="$(this).parent().hide()">×</button>
                    <strong>Alert:</strong> ${flash.message}
                </div>
            </g:if>

            <g:if test="${lists && total>0}">
                <div class="row">
                    <div class="col">
                        <form class="list-search-form" >
                            <div class="input-plus">
                                <input class="input-plus" id="appendedInputButton" name="q" type="text" value="${params.q}" placeholder="Search in list name, description or owner">

                                <button class="erk-button erk-button--dark input-plus__addon" type="submit">
                                    Search
                                </button>
                            </div>
                        </form>

                        <form class="list-search-form" >
                            <g:if test="${params.q}">
                                <button class="erk-button erk-button--light" type="submit">
                                    Clear search
                                </button>
                            </g:if>
                        </form>

                        <div class="float-right">
                            <g:render template="/pageSize"/>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col">
                        <g:render template="/speciesList"/>
                    </div>
                </div>
            </g:if>
            <g:elseif test="${params.q}">
                <form class="list-search-form" >
                    <p>
                        No Species Lists found for: <strong>${params.q}</strong>
                    </p>

                    <button class="erk-button erk-button--light" type="submit">Clear search</button>
                </form>
            </g:elseif>
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
