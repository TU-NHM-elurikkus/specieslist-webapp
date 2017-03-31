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
    <meta name="layout" content="${grailsApplication.config.skin.layout}"/>
    <title>Species lists |${grailsApplication.config.skin.orgNameLong}</title>
    <r:require modules="application"/>
</head>

<body class="">
<div id="content" class="container">
    <header id="page-header">
        <div class="row">
            <div class="col">
                <div id="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item">
                            <a href="${request.contextPath}">
                                Home
                            </a>

                            <span class="divider">
                                <i class="fa fa-arrow-right"></i>
                            </span>
                        </li>

                        <li class="breadcrumb-item">
                            <a class="current" href="${request.contextPath}/admin/speciesLists">
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
                        <a class="btn" title="Add Species List" href="${request.contextPath}/speciesList/upload">Upload a list</a>
                        <a class="btn" title="My Lists" href="${request.contextPath}/speciesList/list">My Lists</a>
                    </span>
                </h1>
            </hgroup>
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

            <p>
                This tool allows you to upload a list of species, and work with that list within the Atlas.
                <br/>
                Click "Upload a list" to upload your own list of taxa.
            </p>

            <g:if test="${lists && total>0}">
                <div class="row">
                    <div class="col-12">
                        <p>
                            Below is a listing of user provided species lists. You can use these lists to work with parts of the Atlas.
                        </p>

                        <form class="listSearchForm" >
                            <div class="input-plus">
                                <input class="input-plus" id="appendedInputButton" name="q" type="text" value="${params.q}" placeholder="Search in list name, description or owner">

                                <button class="btn btn-dark input-plus__addon" type="submit">
                                    Search
                                </button>
                            </div>
                        </form>

                        <form class="listSearchForm" >
                            <g:if test="${params.q}">
                                %{--<input type="hidden" name="q" value=""/>--}%
                                <button class="btn btn-primary" type="submit">
                                    Clear search
                                </button>
                            </g:if>
                        </form>

                        <div class="float-right">
                            <g:render template="/pageSize"/>
                        </div>
                    </div>

                    <div class="col-12">
                        <g:render template="/speciesList"/>
                    </div>
                </div>
            </g:if>
            <g:elseif test="${params.q}">
                <form class="listSearchForm" >
                    <p>
                        No Species Lists found for: <strong>${params.q}</strong>
                    </p>

                    <button class="btn btn-primary" type="submit">Clear search</button>
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
