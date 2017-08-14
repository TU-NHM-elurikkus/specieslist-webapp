<%--
  - Copyright (C) 2014 Atlas of Living Australia
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
--%>

<!doctype html>
<g:set var="bieUrl" value="${grailsApplication.config.bie.baseURL}"/>
<g:set var="collectoryUrl" value="${grailsApplication.config.collectory.baseURL}"/>
<g:set var="maxDownload" value="${grailsApplication.config.downloadLimit}"/>
<g:set var="userCanEditPermissions" value="${
    (speciesList.username == request.getUserPrincipal()?.attributes?.email || request.isUserInRole('ROLE_ADMIN'))
}"/>
<g:set
    var="userCanEditData"
    value="${
    (   speciesList.username == request.getUserPrincipal()?.attributes?.email ||
        request.isUserInRole('ROLE_ADMIN') ||
        request.getUserPrincipal()?.attributes?.userid in speciesList.editors
    )
}"/>
<html>
    <head>
        <r:require modules="application, amplify"/>
        <meta name="layout" content="${grailsApplication.config.skin.layout}"/>
        <script language="JavaScript" type="text/javascript" src="${resource(dir:'js',file:'facets.js')}"></script>
        <script language="JavaScript" type="text/javascript" src="${resource(dir:'js',file:'getQueryParam.js')}"></script>
        <script language="JavaScript" type="text/javascript" src="${resource(dir:'js',file:'jquery-ui-1.8.17.custom.min.js')}"></script>
        <script language="JavaScript" type="text/javascript" src="${resource(dir:'js',file:'jquery.doubleScroll.js')}"></script>
        <title>
            <g:message code="general.speciesListItems"/> | ${grailsApplication.config.skin.orgNameLong}
        </title>
        <script type="text/javascript">
            $(document).ready(function() {
                // in mobile view toggle display of facets
                $('#toggleFacetDisplay').click(function() {
                    $(this).find('i').toggleClass('icon-chevron-right icon-chevron-down');
                    if($('#accordion').is(':visible')) {
                        $('#accordion').removeClass('overrideHide');
                    } else {
                        $('#accordion').addClass('overrideHide');
                    }
                });

                // Add scroll bar to top and bottom of table $('.fwtable').doubleScroll(); Tooltip for link title
                $('#content a').not('.thumbImage').tooltip({placement: "bottom", html: true, delay: 200, container: "body"});

                // submit edit record changes via POST
                $("button.saveRecord").click(function() {
                    var id = $(this).data("id");
                    var modal = $(this).data("modal");
                    var thisFormData = $("form#editForm_" + id).serializeArray();

                    if(!$("form#editForm_" + id).find("#rawScientificName").val()) {
                        alert("Required field: supplied name cannot be blank");

                        return false;
                    }

                    $.post("${createLink(controller: " editor ", action: 'editRecord')}", thisFormData, function(data, textStatus, jqXHR) {
                        //console.log("data", data, "textStatus", textStatus,"jqXHR", jqXHR);
                        $(modal).modal('hide');
                        alert(jqXHR.responseText);
                        window.location.reload(true);
                    }).error(function(jqXHR, textStatus, error) {
                        alert("An error occurred: " + error + " - " + jqXHR.responseText);
                        $(modal).modal('hide');
                    });
                });

                // create record via POST
                $("button#saveNewRecord").click(function() {
                    var id = $(this).data("id");
                    var modal = $(this).data("modal");
                    var thisFormData = $("form#editForm_").serializeArray();

                    if(!$("form#editForm_").find("#rawScientificName").val()) {
                        alert("Required field: supplied name cannot be blank");
                        return false;
                    }
                    //thisFormData.push({id: id}); console.log("thisFormData", id, thisFormData)
                    $.post("${createLink(controller: " editor ", action: 'createRecord')}", thisFormData, function(data, textStatus, jqXHR) {
                        //console.log("data", data, "textStatus", textStatus,"jqXHR", jqXHR);
                        $(modal).modal('hide');
                        alert(jqXHR.responseText);
                        window.location.reload(true);
                    }).error(function(jqXHR, textStatus, error) {
                        alert("An error occurred: " + error + " - " + jqXHR.responseText);
                        $(modal).modal('hide');
                    });
                });

                // submit delete record via GET
                $("button.deleteSpecies").click(function() {
                    var id = $(this).data("id");
                    var modal = $(this).data("modal");

                    $.get("${createLink(controller: " editor ", action: 'deleteRecord')}", {
                        id: id
                    }, function(data, textStatus, jqXHR) {
                        $(modal).modal('hide');
                        //console.log("data", data, "textStatus", textStatus,"jqXHR", jqXHR);
                        alert(jqXHR.responseText + " - reloading page...");
                        window.location.reload(true);
                        //$('#modal').modal('hide');
                    }).error(function(jqXHR, textStatus, error) {
                        alert("An error occurred: " + error + " - " + jqXHR.responseText);
                        $(modal).modal('hide');
                    });
                });

                //console.log("owner = ${speciesList.username}"); console.log("logged in user = ${request.getUserPrincipal()?.attributes?.email}"); Toggle display of list meta data editing
                $("#edit-meta-button").click(function(el) {
                    el.preventDefault();
                    toggleEditMeta(!$("#edit-meta-div").is(':visible'));
                });

                // submit edit meta data
                $("#edit-meta-submit").click(function(el) {
                    el.preventDefault();
                    var $form = $(this).parents("form");
                    var thisFormData = $($form).serializeArray();
                    // serializeArray ignores unchecked checkboxes so explicitly send data for these
                    thisFormData = thisFormData.concat($($form).find('input[type=checkbox]:not(:checked)').map(function() {
                        return {"name": this.name, "value": false}
                    }).get());

                    //console.log("thisFormData", thisFormData);

                    $.post("${createLink(controller: " editor ", action: 'editSpeciesList')}", thisFormData, function(data, textStatus, jqXHR) {
                        //console.log("data", data, "textStatus", textStatus,"jqXHR", jqXHR);
                        alert(jqXHR.responseText);
                        window.location.reload(true);
                    }).error(function(jqXHR, textStatus, error) {
                        alert("An error occurred: " + error + " - " + jqXHR.responseText);
                        //$(modal).modal('hide');
                    });
                });

                // catch click ion view record button (on each row) extract values from main table and display in table inside modal popup
                $("a.viewRecordButton").click(function(el) {
                    el.preventDefault();
                    var recordId = $(this).data("id");
                    viewRecordForId(recordId);
                });
            }); // end document ready

            function getAndViewRecordId(hash) {
                var prefix = "row_";
                var h = decodeURIComponent(hash.substring(1)).replace("+", " ");
                var d = $("tr[id^=" + prefix + "] > td.matchedName");
                var e = $("tr[id^=" + prefix + "] > td.rawScientificName");
                var data = d.add(e);

                $(data).each(function(i, el) {
                    // Handle case insensitively: http://stackoverflow.com/a/2140644/2495717
                    var hashVal = h.toLocaleUpperCase();
                    var cell = $(el).text().trim().toLocaleUpperCase();

                    if(hashVal === cell) {
                        var id = $(el).parent().attr("id").substring(prefix.length);
                        viewRecordForId(id);
                        return false;
                    }
                });
            }

            function toggleEditMeta(showHide) {
                $("#edit-meta-div").slideToggle(showHide);
                //$("#edit-meta-button").hide();
                $("#show-meta-dl").slideToggle(!showHide);
            }

            function viewRecordForId(recordId) {
                // read header values from the table
                var headerRow = $("table#speciesListTable > thead th").not(".action");
                var headers = [];

                $(headerRow).each(function(i, el) {
                    headers.push($(this).text());
                });

                // read species row values from the table
                var valueTds = $("tr#row_" + recordId + " > td").not(".action");
                var values = [];

                $(valueTds).each(function(i, el) {
                    var val = $(this).html();
                    if($.type(val) === "string") {
                        val = $.trim(val);
                    }
                    values.push(val);
                });

                //console.log("values", values.length, "headers", headers.length); console.log("values & headers", headers, values);
                $("#viewRecord p.spinner").hide();
                $("#viewRecord tbody").html(""); // clear values
                $.each(headers, function(i, el) {
                    var row = "<tr><td>" + el + "</td><td>" + values[i] + "</td></tr>";

                    $("#viewRecord tbody").append(row);
                });
                $("#viewRecord table").show();
                $('#viewRecord').modal("show");
            }

            function downloadOccurrences(o) {
                if(validateForm()) {
                    this.cancel();
                    //downloadURL = $("#email").val();
                    downloadURL = "${request.contextPath}/speciesList/occurrences/${params.id}${params.toQueryString()}&type=Download&email=" + $("#email").val() + "&reasonTypeId=" + $("#reasonTypeId").val() + "&file=" + $("#filename").val();
                    window.location = downloadURL //"${request.contextPath}/speciesList/occurrences/${params.id}?type=Download&email=$('#email').val()&reasonTypeId=$(#reasonTypeId).val()&file=$('#filename').val()"
                }
            }

            function downloadFieldGuide(o) {
                if(validateForm()) {
                    this.cancel();
                    //alert(${params.toQueryString()})
                    window.location = "${request.contextPath}/speciesList/fieldGuide/${params.id}${params.toQueryString()}"
                }

            }

            function downloadList(o) {
                if(validateForm()) {
                    this.cancel();
                    window.location = "${request.contextPath}/speciesListItem/downloadList/${params.id}${params.toQueryString()}&file=" + $("#filename").val()
                }
            }

            function validateForm() {
                var isValid = false;
                var reasonId = $("#reasonTypeId option:selected").val();

                if(reasonId) {
                    isValid = true;
                } else {
                    $("#reasonTypeId").focus();
                    $("label[for='reasonTypeId']").css("color", "red");
                    alert("Please select a \"download reason\" from the drop-down list");
                }

                return isValid;
            }

            function reloadWithMax(el) {
                var max = $(el).find(":selected").val();
                var params = {
                    fq: [ ${'\"' + (fqs ? fqs.join('\", \"') : '') + '\"'} ],
                    max: max,
                    sort: "${params.sort}",
                    order: "${params.order}",
                    offset: "${params.offset?:0}"
                };
                var paramStr = jQuery.param(params, true);

                window.location.href = window.location.pathname + '?' + paramStr;
            }
        </script>
    </head>

    <body>
        <%-- Download dialog modal --%>
        <div class="inline-block">
            <g:render template="/download"/>
        </div>

        <div id="content" class="container-fluid">
            <header id="page-header" class="page-header">
                <%-- TITLE --%>
                <div class="page-header__title">
                    <h1 class="page-header__title">
                        <g:message code="speciesListItem.list.speciesList"/>:
                        <a href="${collectoryUrl}/lists/speciesListItem/list/${params.id}">
                            ${speciesList?.listName}
                        </a>

                        <%--
                        <a href="${collectoryUrl}/public/show/${params.id}" title="view Date Resource page">
                            ${speciesList?.listName}
                        </a>
                        --%>
                    </h1>

                    <%-- TODD: New text.
                    <div class="page-header__subtitle">
                        <div>
                            <g:message code="general.listDescription"/>
                        </div>

                        <div>
                            <g:message code="general.deleteDescription"/>
                        </div>
                    </div>
                    --%>
                </div>

                <%-- LINKS --%>
                <div class="page-header-links">
                    <a href="${request.contextPath}/public/speciesLists" class="page-header-links__link">
                        <g:message code="general.speciesLists"/>
                    </a>

                    <a href="${request.contextPath}/speciesList/occurrences/${params.id}${params.toQueryString()}&type=Search"
                        title="${message(code: 'speciesListItem.list.viewUpTo', args: [maxDownload])}" class="page-header-links__link">
                        <g:message code="speciesListItem.list.viewOccurrence"/>
                    </a>

                    <a href="${request.contextPath}/speciesList/spatialPortal/${params.id}${params.toQueryString()}&type=Search"
                        title="${message(code: 'speciesListItem.list.viewSpatialDecription')}"
                        class="page-header-links__link">

                        <g:message code="speciesListItem.list.viewSpatial"/>
                    </a>

                    <div class="action-button-block">
                        <button
                            type="button"
                            class="erk-button erk-button--light"
                            data-toggle="modal"
                            data-target="#list-info-modal"
                        >
                            <span class="fa fa-info-circle"></span>
                            <g:message code="speciesListItem.list.listInfo"/>
                        </button>

                        <button type="button" class="erk-button erk-button--light"
                            title="${message(code: 'speciesListItem.list.viewDownload')}" data-toggle="modal"
                            data-target="#download-dialog">

                            <span class="fa fa-download"></span>
                            <g:message code="speciesListItem.list.download"/>
                        </button>

                        <g:if test="${userCanEditPermissions}">
                            <button type="button" data-remote="${createLink(controller: 'editor', action: 'editPermissions', id: params.id)}" data-target="#modal" data-toggle="modal" class="erk-button erk-button--light">
                                <span class="fa fa-user-o"></span>
                                <g:message code="speciesListItem.list.editPerm"/>
                            </button>
                        </g:if>

                        <g:if test="${userCanEditData}">
                            <a href="#" data-remote="${createLink(controller: 'editor', action: 'addRecordScreen', id: params.id)}" data-target="#addRecord" data-toggle="modal">
                                <span class="fa fa-plus"></span>
                                <g:message code="speciesListItem.list.add"/>
                            </a>
                        </g:if>
                    </div>
                </div>
            </header>

            <g:if test="${flash.message}">
                <div class="row">
                    <div class="message alert alert-info">
                        <b>
                            <g:message code="general.alert"/>:
                        </b>
                        ${flash.message}
                    </div>
                </div>
            </g:if>

            <div class="row">
                <div class="col">
                    <div class="item-search">
                        <div class="input-plus">
                            <input type="text" id="queryInput" name="query" class="input-plus__field">

                            <button
                                type="button"
                                class="input-plus__addon erk-button erk-button--dark"
                                onclick="searchByQuery()"
                            >
                                <g:message code="general.search" />
                            </button>
                        </div>

                        <div class="item-search__filter-line">
                            <g:if test="${query || fqs}">
                                <label class="item-search__filters-label">
                                    <g:message code="speciesListItem.list.filters" />
                                </label>

                                <g:if test="${query}">
                                    <button
                                        type="button"
                                        class="erk-button erk-button--light erk-button--inline"
                                        onclick="clearQuery()"
                                    >
                                        <g:message code="general.scientificName" />: ${query}
                                    </button>
                                </g:if>

                                <g:each in="${fqs}" var="fq">
                                    <button
                                        type="button"
                                        class="erk-button erk-button--light erk-button--inline"
                                        onclick="removeFq('${fq}')"
                                    >
                                        ${fq}
                                    </button>
                                </g:each>
                            </g:if>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-3" id="facets-column">
                    <div class="card card-block">
                        <div class="boxedZ attachedZ">
                            <div class="meta">
                                <ul class="erk-ulist">
                                    <li class="erk-ulist--item">
                                        <g:message code="speciesListItem.list.taxonNumber"/>
                                        <span class="count">
                                            ${totalCount}
                                        </span>
                                    </li>

                                    <li class="erk-ulist--item">
                                        <g:message code="speciesListItem.list.distinctSpecies"/>
                                        <span class="count">
                                            ${distinctCount}
                                        </span>
                                    </li>

                                    <g:if test="${hasUnrecognised && noMatchCount!=totalCount}">
                                        <li class="erk-ulist--item">
                                            <g:link
                                                action="list"
                                                id="${params.id}"
                                                title="${message(code: 'speciesListItem.list.viewUnrecognised')}"
                                                params="${[fq:sl.buildFqList(fqs:fqs, fq:' guid:null'), max:params.max]}"
                                            >
                                                <g:message code="speciesListItem.list.unknownTaxa"/>
                                            </g:link>

                                            <span class="count">
                                                ${noMatchCount}
                                            </span>
                                        </li>
                                    </g:if>

                                    <%--
                                    <li class="erk-ulist--item">
                                        <g:link controller="speciesList" action="list" class="wrk-button" title="My Lists">
                                            <g:message code="general.myLists"/>
                                        </g:link>
                                    </li>
                                    --%>
                                </ul>
                            </div>

                            <div>
                                <g:if test="${facets.size()>0 || params.fq}">
                                    <h4>
                                        <g:message code="speciesListItem.list.refine"/>
                                    </h4>

                                    <div id="accordion">
                                        <g:set var="fqs" value="${params.list('fq')}"/>
                                        <g:if test="${fqs.size()>0&& fqs.get(0).length()>0}">
                                            <div id="currentFilter">
                                                <div class="FieldName">
                                                    <g:message code="speciesListItem.list.filters"/>
                                                </div>

                                                <div id="currentFilters" class="subnavlist">
                                                    <ul class="erk-ulist">
                                                        <g:each in="${fqs}" var="fq">
                                                            <g:if test="${fq.length() >0}">
                                                                <li class="erk-ulist--item">
                                                                    <g:link
                                                                        action="list"
                                                                        id="${params.id}"
                                                                        params="${[fq:sl.excludedFqList(fqs:fqs, fq:fq), max:params.max]}"
                                                                        class="removeLink"
                                                                        title="Uncheck (remove filter)"
                                                                    >
                                                                        <span class="fa fa-check"></span>
                                                                    </g:link>
                                                                    ${fq.replaceFirst("kvp ","")}
                                                                </li>
                                                            </g:if>
                                                        </g:each>
                                                    </ul>
                                                </div>
                                            </div>
                                        </g:if>

                                        <g:each in="${facets}" var="entry">
                                            <g:if test="${entry.key == " listProperties"}">
                                                <g:each in="${facets.get(" listProperties")}" var="value">
                                                    <g:render
                                                        template="facet"
                                                        model="${[key:value.getKey(), values:value.getValue(), isProperty:true]}"
                                                    />
                                                </g:each>
                                            </g:if>
                                            <g:else>
                                                <g:render
                                                    template="facet"
                                                    model="${[key:entry.key, values:entry.value, isProperty:false]}"/>
                                            </g:else>
                                        </g:each>
                                    </div>
                                </g:if>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-md-9">
                    <ul class="nav nav-tabs" role="tablist">
                        <li class="nav-item">
                            <a
                                class="nav-link active"
                                data-toggle="tab"
                                href="#list-tab"
                                role="tab"
                                title="${message(code: 'speciesListItem.list.viewList')}"
                            >
                                <span class="fa fa-th-list"></span>
                                <g:message code="speciesListItem.list.list"/>
                            </a>
                        </li>

                        <li class="nav-item">
                            <a
                                class="nav-link"
                                data-toggle="tab"
                                href="#grid-tab"
                                role="tab"
                                title="${message(code: 'speciesListItem.list.viewThumb')}"
                            >
                                <span class="fa fa-th"></span>
                                <g:message code="speciesListItem.list.grid"/>
                            </a>
                        </li>
                    </ul>

                    <div class="tab-content">
                        <div class="tab-pane active" id="list-tab" role="tabpanel">
                            <div class="float-right">
                                <g:message code="general.pageItems"/>:
                                <select class="input-mini" onchange="reloadWithMax(this)">
                                    <g:each in="${[10,25,50,100]}" var="max">
                                        <option ${(params.max == max)?'selected="selected"' :'' }>
                                            ${max}
                                        </option>
                                    </g:each>
                                </select>
                            </div>

                            <div class="speciesList table-responsive">
                                <table class="table table-sm table-bordered table-striped" id="speciesListTable">
                                    <thead>
                                        <tr>
                                            <th class="action">
                                                <g:message code="general.action"/>
                                            </th>
                                            <g:sortableColumn
                                                property="rawScientificName"
                                                params="${[fq: fqs]}"
                                                titleKey="general.suppliedName"
                                            />
                                            <g:sortableColumn
                                                property="matchedName"
                                                params="${[fq: fqs]}"
                                                titleKey="general.scientificName"
                                            />
                                            <th>
                                                <g:message code="speciesListItem.list.image"/>
                                            </th>
                                            <g:sortableColumn
                                                property="author"
                                                params="${[fq: fqs]}"
                                                titleKey="speciesListItem.list.author"
                                            />
                                            <g:sortableColumn
                                                property="commonName"
                                                params="${[fq: fqs]}"
                                                titleKey="speciesListItem.list.commonName"
                                            />
                                            <g:each in="${keys}" var="key">
                                                <th>
                                                    ${key}
                                                </th>
                                            </g:each>
                                        </tr>
                                    </thead>

                                    <tbody>
                                        <g:each var="result" in="${results}" status="i">
                                            <g:set var="recId" value="${result.id}"/>
                                            <g:set var="bieTitle">
                                                <g:message code="general.speciesPage"/>
                                                <span>
                                                    ${result.rawScientificName}
                                                </span>
                                            </g:set>

                                            <tr class="${(i % 2) == 0 ? 'odd' : 'even'}" id="row_${recId}">
                                                <td class="action">
                                                    <center>
                                                        <a
                                                            class="viewRecordButton"
                                                            href="#viewRecord"
                                                            title="view record"
                                                            data-id="${recId}"
                                                        >
                                                            <span class="fa fa-info-circle"></span>
                                                        </a>

                                                        <g:if test="${userCanEditData}">
                                                            <a
                                                                href="#"
                                                                title="edit"
                                                                data-remote="${createLink(controller: 'editor', action: 'editRecordScreen', id: result.id)}"
                                                                data-target="#editRecord_${recId}"
                                                                data-toggle="modal"
                                                            >
                                                                <span class="fa fa-pencil"></span>
                                                            </a>

                                                            <a
                                                                href="#"
                                                                title="delete"
                                                                data-target="#deleteRecord_${recId}"
                                                                data-toggle="modal"
                                                            >
                                                                <span class="fa fa-trash-o"></span>
                                                            </a>
                                                        </g:if>
                                                    </center>
                                                </td>

                                                <td class="rawScientificName">
                                                    ${fieldValue(bean: result, field: "rawScientificName")}

                                                    <g:if test="${result.guid == null}">
                                                        <br/>
                                                        <strong>
                                                            <g:message code="speciesListItem.list.unmatched"/>
                                                        </strong>
                                                        -
                                                        <g:message code="speciesListItem.list.try"/>
                                                        <a
                                                            href="http://google.com/search?q=${fieldValue(bean: result, field: 'rawScientificName').trim()}"
                                                            target="google"
                                                        >
                                                            <g:message code="speciesListItem.list.google"/>
                                                        </a>
                                                        <g:message code="speciesListItem.list.or"/>
                                                        <a
                                                            href="${grailsApplication.config.biocache.baseURL}/occurrences/search?q=${fieldValue(bean: result, field: 'rawScientificName').trim()}"
                                                            target="biocache"
                                                        >
                                                            <g:message code="speciesListItem.list.occurrences"/>
                                                        </a>
                                                    </g:if>
                                                </td>

                                                <td class="matchedName">
                                                    <g:if test="${result.guid}">
                                                        <a href="${bieUrl}/species/${result.guid}" title="${bieTitle}">
                                                            ${result.matchedName}
                                                        </a>
                                                    </g:if>
                                                    <g:else>
                                                        ${result.matchedName}
                                                    </g:else>
                                                </td>

                                                <td id="img_${result.guid}">
                                                    <g:if test="${result.imageUrl}">
                                                        <a href="${bieUrl}/species/${result.guid}" title="${bieTitle}">
                                                            <img
                                                                style="max-width: 400px;"
                                                                src="${result.imageUrl}"
                                                                class="smallSpeciesImage"
                                                            />
                                                        </a>
                                                    </g:if>
                                                </td>

                                                <td>
                                                    ${result.author}
                                                </td>

                                                <td id="cn_${result.guid}">
                                                    ${result.commonName}
                                                </td>

                                                <g:each in="${keys}" var="key">
                                                    <g:set var="kvp" value="${result.kvpValues.find {it.key == key}}"/>
                                                    <g:set var="val" value="${kvp?.vocabValue?:kvp?.value}"/>

                                                    <td class="kvp ${val?.length() > 35 ? 'scrollWidth':''}">
                                                        <div>
                                                            ${val}
                                                        </div>
                                                    </td>
                                                </g:each>
                                            </tr>
                                        </g:each>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <div class="tab-pane" id="grid-tab" role="tabpanel">
                            <g:each var="result" in="${results}" status="i">
                                <g:set var="recId" value="${result.id}"/>
                                <g:set var="bieTitle">
                                    <g:message code="general.speciesPage"/>
                                    <span>
                                        ${result.rawScientificName}
                                    </span>
                                </g:set>

                                <div class="imgCon">
                                    <a
                                        class="thumbImage viewRecordButton"
                                        rel="thumbs"
                                        title="click to view details"
                                        href="#viewRecord"
                                        data-id="${recId}"
                                    >
                                        <img
                                            src="${result.imageUrl?:g.createLink(uri:'/images/infobox_info_icon.png')}"
                                            style="opacity:0.5"
                                            alt="thumbnail species image"
                                        />
                                    </a>

                                    <g:if test="${true}">
                                        <g:set var="displayName">
                                            <span>
                                                <g:if test="${result.guid == null}">
                                                    ${fieldValue(bean: result, field: "rawScientificName")}
                                                </g:if>
                                                <g:else>
                                                    ${result.matchedName}
                                                </g:else>
                                            </span>
                                        </g:set>

                                        <div class="meta brief">
                                            ${displayName}
                                        </div>

                                        <div class="meta detail">
                                            ${displayName}

                                            <g:if test="${result.author}">
                                                &nbsp;${result.author}
                                            </g:if>

                                            <g:if test="${result.commonName}">
                                                <br/>
                                                ${result.commonName}
                                            </g:if>

                                            <div class="float-right" style="display:inline-block; padding: 5px;">
                                                <a
                                                    href="#viewRecord"
                                                    class="viewRecordButton"
                                                    title="view record"
                                                    data-id="${recId}"
                                                >
                                                    <span class="fa fa-info-circle"></span>
                                                </a>
                                                &nbsp;

                                                <g:if test="${userCanEditData}">
                                                    <a
                                                        href="#"
                                                        title="edit"
                                                        data-remote="${createLink(controller: 'editor', action: 'editRecordScreen', id: result.id)}"
                                                        data-target="#editRecord_${recId}"
                                                        data-toggle="modal"
                                                    >
                                                        <span class="fa fa-pencil"></span>
                                                    </a>
                                                    &nbsp;

                                                    <a
                                                        href="#"
                                                        title="delete"
                                                        data-target="#deleteRecord_${recId}"
                                                        data-toggle="modal"
                                                    >
                                                        <span class="fa fa-trash-o"></span>
                                                    </a>&nbsp;
                                                </g:if>
                                            </div>
                                        </div>
                                    </g:if>
                                </div>
                            </g:each>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col">
                            <div class="pagination float-left">
                                <g:if test="${params.fq}">
                                    <g:paginate
                                        total="${totalCount}"
                                        action="list"
                                        id="${params.id}"
                                        params="${[fq: params.fq]}"
                                    />
                                </g:if>

                                <g:else>
                                    <g:paginate total="${totalCount}" action="list" id="${params.id}"/>
                                </g:else>
                            </div>
                        </div>
                    </div>

                    <%-- Output the BS modal divs (hidden until called) --%>
                    <g:each var="result" in="${results}" status="i">
                        <g:set var="recId" value="${result.id}"/>

                        <div class="modal fade" id="viewRecord">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <button
                                            type="button"
                                            class="close"
                                            onclick="$('#viewRecord .modal-body').scrollTop(0);"
                                            data-dismiss="modal"
                                            aria-hidden="true"
                                        >
                                            ×
                                        </button>

                                        <h3>
                                            <g:message code="speciesListItem.list.viewRecord"/>
                                        </h3>
                                    </div>

                                    <div class="modal-body">
                                        <p class="spinner">
                                            <img src="${resource(dir:'images',file:'spinner.gif')}" alt="spinner icon"/>
                                        </p>

                                        <%-- TODO: .hide class. --%>
                                        <table class="table table-sm table-bordered table-striped hide">
                                            <thead>
                                                <th>
                                                    <g:message code="general.field"/>
                                                </th>

                                                <th>
                                                    <g:message code="general.value"/>
                                                </th>
                                            </thead>

                                            <tbody></tbody>
                                        </table>
                                    </div>

                                    <%-- TODO: .hide class. --%>
                                    <%--
                                    <div class="modal-footer">
                                        <button class="erk-button erk-button--light hide" data-id="${recId}">
                                            <g:message code="speciesListItem.list.previous"/>
                                        </button>
                                        <button class="erk-button erk-button--light hide" data-id="${recId}">
                                            <g:message code="speciesListItem.list.next"/>
                                        </button>
                                        <button class="erk-button erk-button--light" onclick="$('#viewRecord .modal-body').scrollTop(0);" data-dismiss="modal" aria-hidden="true">
                                            <g:message code="general.close"/>
                                        </button>
                                    </div>
                                    --%>
                                </div>
                            </div>
                        </div>

                        <g:if test="${userCanEditData}">
                            <div class="modal fade" id="editRecord_${recId}">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                                        ×
                                    </button>

                                    <h3>
                                        <g:message code="general.editRecord"/>
                                    </h3>
                                </div>

                                <div class="modal-body">
                                    <p>
                                        <img src="${resource(dir:'images',file:'spinner.gif')}" alt="spinner icon"/>
                                    </p>
                                </div>

                                <div class="modal-footer">
                                    <button class="erk-button erk-button--light" data-dismiss="modal" aria-hidden="true">
                                        <g:message code="speciesListItem.list.cancel"/>
                                    </button>

                                    <button
                                        class="erk-button erk-button--light saveRecord"
                                        data-modal="#editRecord_${recId}"
                                        data-id="${recId}"
                                    >
                                        <g:message code="speciesListItem.list.saveChanges"/>
                                    </button>
                                </div>
                            </div>

                            <div class="modal fade" id="deleteRecord_${recId}">
                                <div class="modal-header">
                                    <h3>
                                        <g:message code="speciesListItem.list.confirmDelete"/>
                                    </h3>
                                </div>

                                <div class="modal-body">
                                    <p>
                                        <g:message code="speciesListItem.list.deleteDescription"/>
                                        <span>
                                            ${result.rawScientificName}
                                        </span>
                                    </p>
                                </div>

                                <div class="modal-footer">
                                    <button class="erk-button erk-button--light" data-dismiss="modal" aria-hidden="true">
                                        <g:message code="speciesListItem.list.cancel"/>
                                    </button>

                                    <button
                                        class="erk-button erk-button--light deleteSpecies"
                                        data-modal="#deleteRecord_${recId}"
                                        data-id="${recId}"
                                    >
                                        <g:message code=""/>
                                    </button>
                                </div>
                            </div>
                        </g:if>
                    </g:each>
                </div>
            </div>

            <!-- List info modal -->
            <div id="list-info-modal" class="modal fade">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal">
                                &times;
                            </button>
                        </div>

                        <div class="modal-body">
                            <g:if test="${userCanEditPermissions}">
                                <a href="#" class="erk-button erk-button--light" id="edit-meta-button">
                                    <span class="fa fa-pencil"></span>
                                    <g:message code="speciesListItem.list.edit"/>
                                </a>
                            </g:if>

                            <dl class="row" id="show-meta-dl">
                                <dt class="col-sm-6 col-md-6">
                                    ${message(code: 'general.listName')}
                                </dt>
                                <dd class="col-sm-6 col-md-6">
                                    ${speciesList.listName?:'&nbsp;'}
                                </dd>

                                <dt class="col-sm-6 col-md-6">
                                    ${message(code: 'general.owner')}
                                </dt>
                                <dd class="col-sm-6 col-md-6">
                                    ${speciesList.fullName?:speciesList.username?:'&nbsp;'}
                                </dd>

                                <dt class="col-sm-6 col-md-6">
                                    ${message(code: 'general.listType')}
                                </dt>
                                <dd class="col-sm-6 col-md-6">
                                    ${speciesList.listType?.displayValue}
                                </dd>

                                <g:if test="${speciesList.description}">
                                    <dt class="col-sm-6 col-md-6">
                                        ${message(code: 'general.description')}
                                    </dt>
                                    <dd class="col-sm-6 col-md-6">
                                        ${speciesList.description}
                                    </dd>
                                </g:if>

                                <g:if test="${speciesList.url}">
                                    <dt class="col-sm-6 col-md-6">
                                        ${message(code: 'general.url')}
                                    </dt>
                                    <dd class="col-sm-6 col-md-6">
                                        <a href="${speciesList.url}" target="_blank">
                                            ${speciesList.url}
                                        </a>
                                    </dd>
                                </g:if>

                                <g:if test="${speciesList.wkt}">
                                    <dt class="col-sm-6 col-md-6">
                                        ${message(code: 'speciesListItem.list.wkt')}
                                    </dt>
                                    <dd class="col-sm-6 col-md-6">
                                        ${speciesList.wkt}
                                    </dd>
                                </g:if>

                                <dt class="col-sm-6 col-md-6">
                                    ${message(code: 'general.dateCreated')}
                                </dt>
                                <dd class="col-sm-6 col-md-6">
                                    <g:formatDate format="yyyy-MM-dd" date="${speciesList.dateCreated?:0}"/><!-- ${speciesList.lastUpdated} -->
                                </dd>

                                <dt class="col-sm-6 col-md-6">
                                    ${message(code: 'speciesListItem.list.isPrivate')}
                                </dt>
                                <dd class="col-sm-6 col-md-6">
                                    <g:formatBoolean boolean="${speciesList.isPrivate?:false}" true="Yes" false="No"/>
                                </dd>

                                <dt class="col-sm-6 col-md-6">
                                    ${message(code: 'general.isBIE')}
                                </dt>
                                <dd class="col-sm-6 col-md-6">
                                    <g:formatBoolean boolean="${speciesList.isBIE?:false}" true="Yes" false="No"/>
                                </dd>

                                <dt class="col-sm-6 col-md-6">
                                    ${message(code: 'general.isAuthoritative')}
                                </dt>
                                <dd class="col-sm-6 col-md-6">
                                    <g:formatBoolean boolean="${speciesList.isAuthoritative?:false}" true="Yes" false="No"/>
                                </dd>

                                <dt class="col-sm-6 col-md-6">
                                    ${message(code: 'general.isInvasive')}
                                </dt>
                                <dd class="col-sm-6 col-md-6">
                                    <g:formatBoolean boolean="${speciesList.isInvasive?:false}" true="Yes" false="No"/>
                                </dd>

                                <dt class="col-sm-6 col-md-6">
                                    ${message(code: 'general.isThreatened')}
                                </dt>
                                <dd class="col-sm-6 col-md-6">
                                    <g:formatBoolean boolean="${speciesList.isThreatened?:false}" true="Yes" false="No"/>
                                </dd>

                                <dt class="col-sm-6 col-md-6">
                                    ${message(code: 'general.isSDS')}
                                </dt>
                                <dd class="col-sm-6 col-md-6">
                                    <g:formatBoolean boolean="${speciesList.isSDS?:false}" true="Yes" false="No"/>
                                </dd>

                                <dt class="col-sm-6 col-md-6">
                                    ${message(code: 'general.region')}
                                </dt>
                                <dd class="col-sm-6 col-md-6">
                                    ${speciesList.region?:'Not provided'}
                                </dd>

                                <g:if test="${speciesList.isSDS}">
                                    <g:if test="${speciesList.authority}">
                                        <dt class="col-sm-6 col-md-6">
                                            ${message(code: 'speciesListItem.list.authority')}
                                        </dt>
                                        <dd class="col-sm-6 col-md-6">
                                            ${speciesList.authority}
                                        </dd>
                                    </g:if>

                                    <g:if test="${speciesList.category}">
                                        <dt class="col-sm-6 col-md-6">
                                            ${message(code: 'speciesListItem.list.category')}
                                        </dt>
                                        <dd class="col-sm-6 col-md-6">
                                            ${speciesList.category}
                                        </dd>
                                    </g:if>

                                    <g:if test="${speciesList.generalisation}">
                                        <dt class="col-sm-6 col-md-6">
                                            ${message(code: 'speciesListItem.list.generalisation')}
                                        </dt>
                                        <dd class="col-sm-6 col-md-6">
                                            ${speciesList.generalisation}
                                        </dd>
                                    </g:if>

                                    <g:if test="${speciesList.sdsType}">
                                        <dt class="col-sm-6 col-md-6">
                                            ${message(code: 'general.sdsType')}
                                        </dt>
                                        <dd class="col-sm-6 col-md-6">
                                            ${speciesList.sdsType}
                                        </dd>
                                    </g:if>
                                </g:if>

                                <g:if test="${speciesList.editors}">
                                    <dt class="col-sm-6 col-md-6">
                                        ${message(code: 'speciesListItem.list.editors')}
                                    </dt>
                                    <dd class="col-sm-6 col-md-6">
                                        ${speciesList.editors.collect{ sl.getFullNameForUserId(userId: it) }?.join(", ")}
                                    </dd>
                                </g:if>

                                <%-- The link is broken
                                <dt class="col-sm-6 col-md-6">
                                    ${message(code: 'speciesListItem.list.metadata')}
                                </dt>
                                <dd class="col-sm-6 col-md-6">
                                    <a href="${grailsApplication.config.collectory.baseURL}/public/show/${speciesList.dataResourceUid}">
                                        ${grailsApplication.config.collectory.baseURL}/public/show/${speciesList.dataResourceUid}
                                    </a>
                                </dd>
                                --%>
                            </dl>

                            <g:if test="${userCanEditPermissions}">
                                <div style="display: none;" id="edit-meta-div">
                                    <form class="form-horizontal" id="edit-meta-form">
                                        <input type="hidden" name="id" value="${speciesList.id}"/>

                                        <div class="control-group">
                                            <label class="control-label" for="listName">
                                                ${message(code: 'general.listName')}
                                            </label>
                                            <div class="controls">
                                                <input
                                                    type="text"
                                                    name="listName"
                                                    id="listName"
                                                    class="input-xlarge"
                                                    value="${speciesList.listName}"
                                                    />
                                            </div>
                                        </div>

                                        <div class="control-group">
                                            <label class="control-label" for="owner">
                                                ${message(code: 'general.owner')}
                                            </label>
                                            <div class="controls">
                                                <select name="owner" id="owner" class="input-xlarge">
                                                    <g:each in="${users}" var="userId">
                                                        <option
                                                            value="${userId}"
                                                            ${(speciesList.username == userId) ? 'selected="selected"' :'' }
                                                            >
                                                            <sl:getFullNameForUserId userId="${userId}"/>
                                                        </option>
                                                    </g:each>
                                                </select>
                                            </div>
                                        </div>

                                        <div class="control-group">
                                            <label class="control-label" for="listType">
                                                ${message(code: 'general.listType')}
                                            </label>
                                            <div class="controls">
                                                <select name="listType" id="listType" class="input-xlarge">
                                                    <g:each in="${au.org.ala.specieslist.ListType.values()}" var="type">
                                                        <option
                                                            value="${type.name()}"
                                                            ${(speciesList.listType == type) ? 'selected="selected"' :'' }
                                                            >
                                                            ${type.displayValue}
                                                        </option>
                                                    </g:each>
                                                </select>
                                            </div>
                                        </div>

                                        <div class="control-group">
                                            <label class="control-label" for="description">
                                                ${message(code: 'general.description')}
                                            </label>
                                            <div class="controls">
                                                <textarea rows="3" name="description" id="description" class="input-block-level">
                                                    ${speciesList.description}
                                                </textarea>
                                            </div>
                                        </div>

                                        <div class="control-group">
                                            <label class="control-label" for="url">
                                                ${message(code: 'general.url')}
                                            </label>
                                            <div class="controls">
                                                <input type="url" name="url" id="url" class="input-xlarge" value="${speciesList.url}"/>
                                            </div>
                                        </div>

                                        <div class="control-group">
                                            <label class="control-label" for="description">
                                                ${message(code: 'speciesListItem.list.wkt')}
                                            </label>
                                            <div class="controls">
                                                <textarea rows="3" name="wkt" id="wkt" class="input-block-level">
                                                    ${speciesList.wkt}
                                                </textarea>
                                            </div>
                                        </div>

                                        <div class="control-group">
                                            <label class="control-label" for="dateCreated">
                                                ${message(code: 'general.dateCreated')}
                                            </label>
                                            <div class="controls">
                                                <input
                                                    type="date"
                                                    name="dateCreated"
                                                    id="dateCreated"
                                                    data-date-format="yyyy-mm-dd"
                                                    class="input-xlarge"
                                                    value="<g:formatDate format='yyyy-MM-dd' date='${speciesList.dateCreated?:0}'/>"
                                                    />
                                                <%--<g:datePicker name="dateCreated" value="${speciesList.dateCreated}" precision="day" relativeYears="[-2..7]" class="input-small"/>--%>
                                            </div>
                                        </div>

                                        <div class="control-group">
                                            <label class="control-label" for="isPrivate">
                                                ${message(code: 'speciesListItem.list.isPrivate')}
                                            </label>
                                            <div class="controls">
                                                <input
                                                    type="checkbox"
                                                    id="isPrivate"
                                                    name="isPrivate"
                                                    class="input-xlarge"
                                                    value="true"
                                                    data-value="${speciesList.isPrivate}"
                                                    ${(speciesList.isPrivate == true) ? 'checked="checked"' :''}
                                                    />
                                            </div>
                                        </div>

                                        <g:if test="${request.isUserInRole(" ROLE_ADMIN")}">
                                            <div class="control-group">
                                                <label class="control-label" for="isBIE">
                                                    ${message(code: 'general.isBIE')}
                                                </label>
                                                <div class="controls">
                                                    <input
                                                        type="checkbox"
                                                        id="isBIE"
                                                        name="isBIE"
                                                        class="input-xlarge"
                                                        value="true"
                                                        data-value="${speciesList.isBIE}"
                                                        ${(speciesList.isBIE == true) ? 'checked="checked"' :''}
                                                        />
                                                </div>
                                            </div>

                                            <div class="control-group">
                                                <label class="control-label" for="isAuthoritative">
                                                    ${message(code:'general.isAuthoritative')}
                                                </label>
                                                <div class="controls">
                                                    <input
                                                        type="checkbox"
                                                        id="isAuthoritative"
                                                        name="isAuthoritative"
                                                        class="input-xlarge"
                                                        value="true"
                                                        data-value="${speciesList.isAuthoritative}"
                                                        ${(speciesList.isAuthoritative == true) ? 'checked="checked"' :''}
                                                        />
                                                </div>
                                            </div>

                                            <div class="control-group">
                                                <label class="control-label" for="isInvasive">
                                                    ${message(code:'general.isInvasive')}
                                                </label>
                                                <div class="controls">
                                                    <input
                                                        type="checkbox"
                                                        id="isInvasive"
                                                        name="isInvasive"
                                                        class="input-xlarge"
                                                        value="true"
                                                        data-value="${speciesList.isInvasive}"
                                                        ${(speciesList.isInvasive == true) ? 'checked="checked"' :''}
                                                        />
                                                </div>
                                            </div>

                                            <div class="control-group">
                                                <label class="control-label" for="isThreatened">
                                                    ${message(code:'general.isThreatened')}
                                                </label>
                                                <div class="controls">
                                                    <input
                                                        type="checkbox"
                                                        id="isThreatened"
                                                        name="isThreatened"
                                                        class="input-xlarge"
                                                        value="true"
                                                        data-value="${speciesList.isThreatened}"
                                                        ${(speciesList.isThreatened == true) ? 'checked="checked"' :''}
                                                        />
                                                </div>
                                            </div>

                                            <div class="control-group">
                                                <label class="control-label" for="isSDS">
                                                    ${message(code: 'general.isSDS')}
                                                </label>
                                                <div class="controls">
                                                    <input
                                                        type="checkbox"
                                                        id="isSDS"
                                                        name="isSDS"
                                                        class="input-xlarge"
                                                        value="true"
                                                        data-value="${speciesList.isSDS}"
                                                        ${(speciesList.isSDS == true) ? 'checked="checked"' :''}
                                                        />
                                                </div>
                                            </div>

                                            <div class="control-group">
                                                <label class="control-label" for="region">
                                                    ${message(code: 'general.region')}
                                                </label>
                                                <div class="controls">
                                                    <input
                                                        type="text"
                                                        name="region"
                                                        id="region"
                                                        class="input-xlarge"
                                                        value="${speciesList.region}"
                                                        />
                                                </div>
                                            </div>

                                            <g:if test="${speciesList.isSDS}">
                                                <div class="control-group">
                                                    <label class="control-label" for="authority">
                                                        ${message(code: 'speciesListItem.list.authority')}
                                                    </label>
                                                    <div class="controls">
                                                        <input
                                                            type="text"
                                                            name="authority"
                                                            id="authority"
                                                            class="input-xlarge"
                                                            value="${speciesList.authority}"
                                                            />
                                                    </div>
                                                </div>

                                                <div class="control-group">
                                                    <label class="control-label" for="category">
                                                        ${message(code: 'speciesListItem.list.category')}
                                                    </label>
                                                    <div class="controls">
                                                        <input
                                                            type="text"
                                                            name="category"
                                                            id="category"
                                                            class="input-xlarge"
                                                            value="${speciesList.category}"
                                                            />
                                                    </div>
                                                </div>

                                                <div class="control-group">
                                                    <label class="control-label" for="generalisation">
                                                        ${message(code: 'speciesListItem.list.generalisation')}
                                                    </label>
                                                    <div class="controls">
                                                        <input
                                                            type="text"
                                                            name="generalisation"
                                                            id="generalisation"
                                                            class="input-xlarge"
                                                            value="${speciesList.generalisation}"
                                                            />
                                                    </div>
                                                </div>

                                                <div class="control-group">
                                                    <label class="control-label" for="sdsType">
                                                        ${message(code: 'general.sdsType')}
                                                    </label>
                                                    <div class="controls">
                                                        <input
                                                            type="text"
                                                            name="sdsType"
                                                            id="sdsType"
                                                            class="input-xlarge"
                                                            value="${speciesList.sdsType}"
                                                            />
                                                    </div>
                                                </div>
                                            </g:if>
                                        </g:if>

                                        <div class="control-group">
                                            <div class="controls">
                                                <button type="submit" id="edit-meta-submit" class="erk-button erk-button--light">
                                                    <g:message code="speciesListItem.list.save"/>
                                                </button>
                                                <button class="erk-button erk-button--light" onclick="toggleEditMeta(false);return false;">
                                                    <g:message code="speciesListItem.list.cancel"/>
                                                </button>
                                            </div>
                                        </div>
                                    </form>
                                </div>
                            </g:if>
                        </div>

                        <div class="modal-footer">
                            <button
                                type="button"
                                class="erk-button erk-button--light"
                                data-dismiss="modal"
                            >
                                <g:message code="general.close" />
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script>
            var paramString = window.location.href.split('?')[1] || "";
            var params = paramString.split('&').map(function(param) {
                var parts = param.split('=');

                return {
                    key: parts[0],
                    value: parts[1]
                };
            });

            function reloadWithParams(params) {
                var queryString = params.map(function(param) {
                    return param.key + '=' + param.value;
                }).join('&');

                window.location.href = window.location.pathname + '?' + queryString;
            }

            function searchByQuery() {
                var query = document.getElementById('queryInput').value;

                var newParams = params.filter(function(param) {
                    return params.key !== 'query';
                });

                newParams.push({
                    key: 'query',
                    value: query
                });

                reloadWithParams(newParams);
            }

            function clearQuery() {
                var newParams = params.filter(function(param) {
                    return param.key !== 'query';
                });

                reloadWithParams(newParams);
            }

            function removeFq(fq) {
                var encodedfq = window.encodeURIComponent(fq);
                var newParams = [];

                params.forEach(function(param) {
                    if(param.key === 'fq') {
                        var facets = param.value.split(',').filter(function(facet) {
                            return facet !== encodedfq;
                        });

                        if(facets.length > 1) {
                            newParams.push({
                                key: fq,
                                value: facets.join(',')
                            });
                        }
                    } else {
                        newParams.push(param);
                    }
                });

                reloadWithParams(newParams);
            }

            $(document).ready(function() {
                // make table header cells clickable
                $("table .sortable").each(function(i) {
                    var href = $(this).find("a").attr("href");
                    $(this).click(function() {
                        window.location.href = href;
                    });
                });
            });
        </script>
    </body>
</html>
