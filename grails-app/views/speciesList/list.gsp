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
    <r:require modules="fancybox,application"/>
    <meta name="layout" content="${grailsApplication.config.skin.layout}"/>
    <title>My Species lists | ${grailsApplication.config.skin.orgNameLong}</title>
    <style type="text/css">
        #speciesList {display: none;}
    </style>
</head>

<body class="yui-skin-sam nav-species">
<script type="text/javascript">
    window.onload=init

    function init() {
        if(document.getElementById("speciesList") != null) {
            document.getElementById("speciesList").style.display = "block";
        }
    }
</script>

<div id="content" class="container">
    <header id="page-header2">
        <div class="row">
            <div id="breadcrumb" class="col-12">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item">
                        <a href="${grailsApplication.config.ala.baseURL}">Home</a>&nbsp;

                        <span class="divider">
                            <i class="fa fa-arrow-right"></i>
                        </span>
                    </li>

                    <li class="breadcrumb-item">
                        <a href="${request.contextPath}/public/speciesLists">Species lists</a>&nbsp;

                        <span class="divider">
                            <i class="fa fa-arrow-right"></i>
                        </span>
                    </li>

                    %{-- XXX --}%
                    <li class="breadcrumb-item">
                        ${request.getUserPrincipal()?.attributes?.firstname} ${request.getUserPrincipal()?.attributes?.lastname}&apos;s Species Lists
                    </li>
                </ol>
            </div>
        </div>

        <div class="row">
            <hgroup class="col">
                <h1>
                    My species lists

                    <span class="float-right">
                        <g:link controller="speciesList" action="upload" class="erk-button" title="Add Species List">
                            Upload a list
                        </g:link>
                    </span>
                </h1>
            </hgroup>
        </div>
    </header>

    <g:if test="${lists && total > 0}">
        <div class="row">
            <div class="col">
                <p>
                    Below is a listing of species lists that you have provided. You can use these lists to work with parts of the Atlas.
                    Click on the "delete" button next to a list to remove it from the Atlas.
                </p>

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
