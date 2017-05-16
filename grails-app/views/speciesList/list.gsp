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
        My Species lists | ${grailsApplication.config.skin.orgNameLong}
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
                        My Species lists
                    </h1>

                    <div class="page-header-title__subtitle">
                        <div>
                            Below is a listing of species lists that you have provided. You can use these lists to work with parts of the Atlas.
                        </div>

                        <div>
                            Click on the "delete" button next to a list to remove it from the Atlas.
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

                    %{--
                    <g:link controller="speciesList" action="upload" title="Add Species List" class="page-header-links__link">
                        Upload a list
                    </g:link>
                    --}%
                </div>
            </div>
        </div>
    </header>

    <g:if test="${lists && total > 0}">
        <div class="row">
            <div class="col">
                %{--
                <p>
                    Below is a listing of species lists that you have provided. You can use these lists to work with parts of the Atlas.
                    Click on the "delete" button next to a list to remove it from the Atlas.
                </p>
                --}%

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
    <g:else>
        <div class="row">
            <div class="col">
                <p>
                    You do not have any available species lists.
                </p>
            </div>
        </div>
    </g:else>
</body>
</html>
