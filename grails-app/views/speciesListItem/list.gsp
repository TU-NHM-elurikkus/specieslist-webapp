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
<g:set var="bieUrl" value="${grailsApplication.config.bie.baseURL}" />
<g:set var="collectoryUrl" value="${grailsApplication.config.collectory.baseURL}" />
<g:set var="maxDownload" value="${grailsApplication.config.downloadLimit}" />
<g:set var="userCanEditPermissions" value="${
    (speciesList.username == request.getUserPrincipal()?.attributes?.email || request.isUserInRole("ROLE_ADMIN"))
}" />
<g:set var="userCanEditData" value="${
    (   speciesList.username == request.getUserPrincipal()?.attributes?.email ||
        request.isUserInRole("ROLE_ADMIN") ||
        request.getUserPrincipal()?.attributes?.userid in speciesList.editors
    )
}" />
<html>
<head>
    <r:require modules="application, amplify" />
    <meta name="layout" content="${grailsApplication.config.skin.layout}" />
    <script language="JavaScript" type="text/javascript" src="${resource(dir:'js',file:'facets.js')}"></script>
    <script language="JavaScript" type="text/javascript" src="${resource(dir:'js',file:'getQueryParam.js')}"></script>
    <script language="JavaScript" type="text/javascript" src="${resource(dir:'js',file:'jquery-ui-1.8.17.custom.min.js')}"></script>
    <script language="JavaScript" type="text/javascript" src="${resource(dir:'js',file:'jquery.doubleScroll.js')}"></script>
    <title>Species list items | ${grailsApplication.config.skin.orgNameLong}</title>
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

            // Add scroll bar to top and bottom of table
            // $('.fwtable').doubleScroll();

            // Tooltip for link title
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

                $.post("${createLink(controller: "editor", action: 'editRecord')}", thisFormData, function(data, textStatus, jqXHR) {
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
                //thisFormData.push({id: id});
                //console.log("thisFormData", id, thisFormData)
                $.post("${createLink(controller: "editor", action: 'createRecord')}", thisFormData, function(data, textStatus, jqXHR) {
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

                $.get("${createLink(controller: "editor", action: 'deleteRecord')}", {id: id}, function(data, textStatus, jqXHR) {
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

            //console.log("owner = ${speciesList.username}");
            //console.log("logged in user = ${request.getUserPrincipal()?.attributes?.email}");

            // Toggle display of list meta data editing
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
                thisFormData = thisFormData.concat(
                    $($form).find('input[type=checkbox]:not(:checked)').map(
                        function() {
                            return {"name": this.name, "value": false}
                        }
                    ).get()
                );

                //console.log("thisFormData", thisFormData);

                $.post("${createLink(controller: "editor", action: 'editSpeciesList')}", thisFormData, function(data, textStatus, jqXHR) {
                    //console.log("data", data, "textStatus", textStatus,"jqXHR", jqXHR);
                    alert(jqXHR.responseText);
                    window.location.reload(true);
                }).error(function(jqXHR, textStatus, error) {
                    alert("An error occurred: " + error + " - " + jqXHR.responseText);
                    //$(modal).modal('hide');
                });
            });

            // toggle display of list info box
            $("#toggleListInfo").click(function(el) {
                el.preventDefault();
                $("#list-meta-data").slideToggle(!$("#list-meta-data").is(':visible'))
            });

            // catch click ion view record button (on each row)
            // extract values from main table and display in table inside modal popup
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

        %{-- XXX --}%
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

            //console.log("values", values.length, "headers", headers.length);
            //console.log("values & headers", headers, values);
            $("#viewRecord p.spinner").hide();
            $("#viewRecord tbody").html(""); // clear values
            $.each(headers, function(i, el) {
                var row = "<tr><td>"+el+"</td><td>"+values[i]+"</td></tr>";

                $("#viewRecord tbody").append(row);
            });
            $("#viewRecord table").show();
            $('#viewRecord').modal("show");
        }

        function downloadOccurrences(o) {
            if(validateForm()) {
                this.cancel();
                //downloadURL = $("#email").val();
                downloadURL = "${request.contextPath}/speciesList/occurrences/${params.id}${params.toQueryString()}&type=Download&email="+$("#email").val()+"&reasonTypeId="+$("#reasonTypeId").val()+"&file="+$("#filename").val();
                window.location =  downloadURL//"${request.contextPath}/speciesList/occurrences/${params.id}?type=Download&email=$('#email').val()&reasonTypeId=$(#reasonTypeId).val()&file=$('#filename').val()"
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
                 window.location = "${request.contextPath}/speciesListItem/downloadList/${params.id}${params.toQueryString()}&file="+$("#filename").val()
             }
        }

        function validateForm() {
            var isValid = false;
            var reasonId = $("#reasonTypeId option:selected").val();

            if(reasonId) {
                isValid = true;
            } else {
                $("#reasonTypeId").focus();
                $("label[for='reasonTypeId']").css("color","red");
                alert("Please select a \"download reason\" from the drop-down list");
            }

            return isValid;
        }

        function reloadWithMax(el) {
            var max = $(el).find(":selected").val();
            var params = {
                fq: [ ${"\"" + (fqs ? fqs.join("\", \"") : "") + "\""} ],
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
%{-- Download dialog modal --}%
<div class="inline-block">
    <g:render template="/download"/>
</div>

<div id="content" class="container-fluid">
    <header id="page-header" class="page-header">
        %{-- TITLE --}%
        <div class="page-header__title">
            <h1 class="page-header__title">
                Species List:
                <a href="${collectoryUrl}/lists/speciesListItem/list/${params.id}">
                    ${speciesList?.listName}
                </a>

                %{--
                <a href="${collectoryUrl}/public/show/${params.id}" title="view Date Resource page">
                    ${speciesList?.listName}
                </a>
                --}%
            </h1>

            %{-- TODD: New text.
            <div class="page-header__subtitle">
                <div>
                    Below is a listing of species lists that you have provided. You can use these lists to work with parts of the Atlas.
                </div>

                <div>
                    Click on the "delete" button next to a list to remove it from the Atlas.
                </div>
            </div>
            --}%
        </div>

        %{-- LINKS --}%
        <div class="page-header-links">
            <a href="${request.contextPath}/public/speciesLists" class="page-header-links__link">
                Species lists
            </a>

            <a
                href="${request.contextPath}/speciesList/occurrences/${params.id}${params.toQueryString()}&type=Search"
                title="View occurrences for up to ${maxDownload} species on the list"
                class="page-header-links__link"
            >
                View occurrence records
            </a>

            <a
                href="${request.contextPath}/speciesList/spatialPortal/${params.id}${params.toQueryString()}&type=Search"
                title="View the spatial portal."
                class="page-header-links__link"
            >
                View in spatial portal
            </a>

            <div class="action-button-block">
                <button id="toggleListInfo" class="erk-button erk-button--light">
                    <span class="fa fa-info-circle">
                    </span>
                    List info
                </button>

                <button
                    type="button"
                    class="erk-button erk-button--light"
                    title="View the download options for this species list."
                    data-toggle="modal"
                    data-target="#download-dialog"
                >
                   <span class="fa fa-download">
                   </span>
                   Download
                </button>

                <g:if test="${userCanEditPermissions}">
                    <button
                        type="button"
                        data-remote="${createLink(controller: 'editor', action: 'editPermissions', id: params.id)}"
                        data-target="#modal"
                        data-toggle="modal"
                        class="erk-button erk-button--light"
                    >
                        <span class="fa fa-user-o">
                        </span>
                        Edit permissions
                    </button>
                </g:if>

                <g:if test="${userCanEditData}">
                    <a
                        href="#"
                        data-remote="${createLink(controller: 'editor', action: 'addRecordScreen', id: params.id)}"
                        data-target="#addRecord"
                        data-toggle="modal"
                    >
                        <span class="fa fa-plus">
                        </span>
                        Add species
                    </a>
                </g:if>
            </div>
        </div>
    </header>

    <div style="display: none;" class="alert alert-info" id="list-meta-data">
        <button type="button" class="close" onclick="$(this).parent().slideUp()">&times;</button>

        <g:if test="${userCanEditPermissions}">
            <a href="#" class="erk-button erk-button--light" id="edit-meta-button">
                <span class="fa fa-pencil"></span> Edit
            </a>
        </g:if>

        <dl class="row" id="show-meta-dl">
            <dt class="col-sm-6 col-md-3">${message(code: 'speciesList.listName.label', default: 'List name')}</dt>
            <dd class="col-sm-6 col-md-9">${speciesList.listName?:'&nbsp;'}</dd>
            <dt class="col-sm-6 col-md-3">${message(code: 'speciesList.username.label', default: 'Owner')}</dt>
            <dd class="col-sm-6 col-md-9">${speciesList.fullName?:speciesList.username?:'&nbsp;'}</dd>
            <dt class="col-sm-6 col-md-3">${message(code: 'speciesList.listType.label', default: 'List type')}</dt>
            <dd class="col-sm-6 col-md-9">${speciesList.listType?.displayValue}</dd>

            <g:if test="${speciesList.description}">
                <dt class="col-sm-6 col-md-3">${message(code: 'speciesList.description.label', default: 'Description')}</dt>
                <dd class="col-sm-6 col-md-9">${speciesList.description}</dd>
            </g:if>

            <g:if test="${speciesList.url}">
                <dt class="col-sm-6 col-md-3">${message(code: 'speciesList.url.label', default: 'URL')}</dt>
                <dd class="col-sm-6 col-md-9"><a href="${speciesList.url}" target="_blank">${speciesList.url}</a></dd>
            </g:if>

            <g:if test="${speciesList.wkt}">
                <dt class="col-sm-6 col-md-3">${message(code: 'speciesList.wkt.label', default: 'WKT vector')}</dt>
                <dd class="col-sm-6 col-md-9">${speciesList.wkt}</dd>
            </g:if>

            <dt class="col-sm-6 col-md-3">${message(code: 'speciesList.dateCreated.label', default: 'Date submitted')}</dt>
            <dd class="col-sm-6 col-md-9"><g:formatDate format="yyyy-MM-dd" date="${speciesList.dateCreated?:0}" /><!-- ${speciesList.lastUpdated} --></dd>
            <dt class="col-sm-6 col-md-3">${message(code: 'speciesList.isPrivate.label', default: 'Is private')}</dt>
            <dd class="col-sm-6 col-md-9"><g:formatBoolean boolean="${speciesList.isPrivate?:false}" true="Yes" false="No" /></dd>
            <dt class="col-sm-6 col-md-3">${message(code: 'speciesList.isBIE.label', default: 'Included in BIE')}</dt>
            <dd class="col-sm-6 col-md-9"><g:formatBoolean boolean="${speciesList.isBIE?:false}" true="Yes" false="No" /></dd>
            <dt class="col-sm-6 col-md-3">${message(code: 'speciesList.isAuthoritative.label', default: 'Authoritative')}</dt>
            <dd class="col-sm-6 col-md-9"><g:formatBoolean boolean="${speciesList.isAuthoritative?:false}" true="Yes" false="No" /></dd>
            <dt class="col-sm-6 col-md-3">${message(code: 'speciesList.isInvasive.label', default: 'Invasive')}</dt>
            <dd class="col-sm-6 col-md-9"><g:formatBoolean boolean="${speciesList.isInvasive?:false}" true="Yes" false="No" /></dd>
            <dt class="col-sm-6 col-md-3">${message(code: 'speciesList.isThreatened.label', default: 'Threatened')}</dt>
            <dd class="col-sm-6 col-md-9"><g:formatBoolean boolean="${speciesList.isThreatened?:false}" true="Yes" false="No" /></dd>
            <dt class="col-sm-6 col-md-3">${message(code: 'speciesList.isSDS.label', default: 'Part of the SDS')}</dt>
            <dd class="col-sm-6 col-md-9"><g:formatBoolean boolean="${speciesList.isSDS?:false}" true="Yes" false="No" /></dd>
            <dt class="col-sm-6 col-md-3">${message(code: 'speciesList.region.label', default: 'Region')}</dt>
            <dd class="col-sm-6 col-md-9">${speciesList.region?:'Not provided'}</dd>

            <g:if test="${speciesList.isSDS}">
                <g:if test="${speciesList.authority}">
                    <dt class="col-sm-6 col-md-3">${message(code: 'speciesList.authority.label', default: 'SDS Authority')}</dt>
                    <dd class="col-sm-6 col-md-9">${speciesList.authority}</dd>
                </g:if>

                <g:if test="${speciesList.category}">
                    <dt class="col-sm-6 col-md-3">${message(code: 'speciesList.category.label', default: 'SDS Category')}</dt>
                    <dd class="col-sm-6 col-md-9">${speciesList.category}</dd>
                </g:if>

                <g:if test="${speciesList.generalisation}">
                    <dt class="col-sm-6 col-md-3">${message(code: 'speciesList.generalisation.label', default: 'SDS Coordinate Generalisation')}</dt>
                    <dd class="col-sm-6 col-md-9">${speciesList.generalisation}</dd>
                </g:if>

                <g:if test="${speciesList.sdsType}">
                    <dt class="col-sm-6 col-md-3">${message(code: 'speciesList.sdsType.label', default: 'SDS Type')}</dt>
                    <dd class="col-sm-6 col-md-9">${speciesList.sdsType}</dd>
                </g:if>
            </g:if>

            <g:if test="${speciesList.editors}">
                <dt class="col-sm-6 col-md-3">${message(code: 'speciesList.editors.label', default: 'List editors')}</dt>
                <dd class="col-sm-6 col-md-9">${speciesList.editors.collect{ sl.getFullNameForUserId(userId: it) }?.join(", ")}</dd>
            </g:if>

            %{-- The link is broken
            <dt class="col-sm-6 col-md-3">${message(code: 'speciesList.metadata.label', default: 'Metadata link')}</dt>
            <dd class="col-sm-6 col-md-9"><a href="${grailsApplication.config.collectory.baseURL}/public/show/${speciesList.dataResourceUid}">${grailsApplication.config.collectory.baseURL}/public/show/${speciesList.dataResourceUid}</a></dd>
            --}%
        </dl>

        <g:if test="${userCanEditPermissions}">
            <div style="display: none;" id="edit-meta-div">
                <form class="form-horizontal" id="edit-meta-form">
                    <input type="hidden" name="id" value="${speciesList.id}" />

                    <div class="control-group">
                        <label class="control-label" for="listName">${message(code: 'speciesList.listName.label', default: 'List name')}</label>
                        <div class="controls">
                            <input type="text" name="listName" id="listName" class="input-xlarge" value="${speciesList.listName}" />
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label" for="owner">${message(code: 'speciesList.username.label', default: 'Owner')}</label>
                        <div class="controls">
                            <select name="owner" id="owner" class="input-xlarge">
                                <g:each in="${users}" var="userId"><option value="${userId}" ${(speciesList.username == userId) ? 'selected="selected"':''}><sl:getFullNameForUserId userId="${userId}" /></option></g:each>
                            </select>
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label" for="listType">${message(code: 'speciesList.listType.label', default: 'List type')}</label>
                        <div class="controls">
                            <select name="listType" id="listType" class="input-xlarge">
                                <g:each in="${au.org.ala.specieslist.ListType.values()}" var="type"><option value="${type.name()}" ${(speciesList.listType == type) ? 'selected="selected"':''}>${type.displayValue}</option></g:each>
                            </select>
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label" for="description">${message(code: 'speciesList.description.label', default: 'Description')}</label>
                        <div class="controls">
                            <textarea rows="3" name="description" id="description" class="input-block-level">${speciesList.description}</textarea>
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label" for="url">${message(code: 'speciesList.url.label', default: 'URL')}</label>
                        <div class="controls">
                            <input type="url" name="url" id="url" class="input-xlarge" value="${speciesList.url}" />
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label" for="description">${message(code: 'speciesList.wkt.label', default: 'WKT vector')}</label>
                        <div class="controls">
                            <textarea rows="3" name="wkt" id="wkt" class="input-block-level">${speciesList.wkt}</textarea>
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label" for="dateCreated">${message(code: 'speciesList.dateCreated.label', default: 'Date submitted')}</label>
                        <div class="controls">
                            <input type="date" name="dateCreated" id="dateCreated" data-date-format="yyyy-mm-dd" class="input-xlarge" value="<g:formatDate format="yyyy-MM-dd" date="${speciesList.dateCreated?:0}" />" />
                            %{--<g:datePicker name="dateCreated" value="${speciesList.dateCreated}" precision="day" relativeYears="[-2..7]" class="input-small" />--}%
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label" for="isPrivate">${message(code: 'speciesList.isPrivate.label', default: 'Is private')}</label>
                        <div class="controls">
                            <input type="checkbox" id="isPrivate" name="isPrivate" class="input-xlarge" value="true" data-value="${speciesList.isPrivate}" ${(speciesList.isPrivate == true) ? 'checked="checked"':''} />
                        </div>
                    </div>

                    <g:if test="${request.isUserInRole("ROLE_ADMIN")}">
                        <div class="control-group">
                            <label class="control-label" for="isBIE">${message(code: 'speciesList.isBIE.label', default: 'Included in BIE')}</label>
                            <div class="controls">
                                <input type="checkbox" id="isBIE" name="isBIE" class="input-xlarge" value="true" data-value="${speciesList.isBIE}" ${(speciesList.isBIE == true) ? 'checked="checked"':''} />
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label" for="isAuthoritative">${message(code:'speciesList.isAuthoritative.label', default: 'Authoritative')}</label>
                            <div class="controls">
                                <input type="checkbox" id="isAuthoritative" name="isAuthoritative" class="input-xlarge" value="true" data-value="${speciesList.isAuthoritative}" ${(speciesList.isAuthoritative == true) ? 'checked="checked"':''} />
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label" for="isInvasive">${message(code:'speciesList.isInvasive.label', default: 'Invasive')}</label>
                            <div class="controls">
                                <input type="checkbox" id="isInvasive" name="isInvasive" class="input-xlarge" value="true" data-value="${speciesList.isInvasive}" ${(speciesList.isInvasive == true) ? 'checked="checked"':''} />
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label" for="isThreatened">${message(code:'speciesList.isThreatened.label', default: 'Threatened')}</label>
                            <div class="controls">
                                <input type="checkbox" id="isThreatened" name="isThreatened" class="input-xlarge" value="true" data-value="${speciesList.isThreatened}" ${(speciesList.isThreatened == true) ? 'checked="checked"':''} />
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label" for="isSDS">${message(code: 'speciesList.isSDS.label', default: 'Part of the SDS')}</label>
                            <div class="controls">
                                <input type="checkbox" id="isSDS" name="isSDS" class="input-xlarge" value="true" data-value="${speciesList.isSDS}" ${(speciesList.isSDS == true) ? 'checked="checked"':''} />
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label" for="region">${message(code: 'speciesList.region.label', default: 'Region')}</label>
                            <div class="controls">
                                <input type="text" name="region" id="region" class="input-xlarge" value="${speciesList.region}" />
                            </div>
                        </div>

                        <g:if test="${speciesList.isSDS}">
                            <div class="control-group">
                                <label class="control-label" for="authority">${message(code: 'speciesList.authority.label', default: 'SDS Authority')}</label>
                                <div class="controls">
                                    <input type="text" name="authority" id="authority" class="input-xlarge" value="${speciesList.authority}" />
                                </div>
                            </div>

                            <div class="control-group">
                                <label class="control-label" for="category">${message(code: 'speciesList.category.label', default: 'SDS Category')}</label>
                                <div class="controls">
                                    <input type="text" name="category" id="category" class="input-xlarge" value="${speciesList.category}" />
                                </div>
                            </div>

                            <div class="control-group">
                                <label class="control-label" for="generalisation">${message(code: 'speciesList.generalisation.label', default: 'SDS Generalisation')}</label>
                                <div class="controls">
                                    <input type="text" name="generalisation" id="generalisation" class="input-xlarge" value="${speciesList.generalisation}" />
                                </div>
                            </div>

                            <div class="control-group">
                                <label class="control-label" for="sdsType">${message(code: 'speciesList.sdsType.label', default: 'SDS Type')}</label>
                                <div class="controls">
                                    <input type="text" name="sdsType" id="sdsType" class="input-xlarge" value="${speciesList.sdsType}" />
                                </div>
                            </div>
                        </g:if>
                    </g:if>

                    <div class="control-group">
                        <div class="controls">
                            <button type="submit" id="edit-meta-submit" class="erk-button erk-button--light">Save</button>
                            <button class="erk-button erk-button--light" onclick="toggleEditMeta(false);return false;">Cancel</button>
                        </div>
                    </div>
                </form>
            </div>
        </g:if>
    </div>

    <g:if test="${flash.message}">
        <div class="row">
            <div class="message alert alert-info">
                <strong>Alert:</strong> ${flash.message}
            </div>
        </div>
    </g:if>

    <div class="row">
        <div class="col-md-3 well" id="facets-column">
            <div class="boxedZ attachedZ">
                <section class="meta">
                    <ul class="erk-ulist">
                        <li class="erk-ulist--item">
                            Number of Taxa
                            <span class="count">${totalCount}</span>
                        </li>

                        <li class="erk-ulist--item">
                            Distinct Species
                            <span class="count">${distinctCount}</span>
                        </li>

                        <g:if test="${hasUnrecognised && noMatchCount!=totalCount}">
                            <li class="erk-ulist--item">
                                <g:link action="list" id="${params.id}" title="View unrecognised taxa" params="${[fq:sl.buildFqList(fqs:fqs, fq:"guid:null"), max:params.max]}">
                                    Unrecognised Taxa
                                </g:link>

                                <span class="count">${noMatchCount}</span>
                            </li>
                        </g:if>

                        %{--
                        <li class="erk-ulist--item">
                            <g:link controller="speciesList" action="list" class="wrk-button" title="My Lists">
                                My Lists
                            </g:link>
                        </li>
                        --}%
                    </ul>
                </section>

                <section>
                    <g:if test="${facets.size()>0 || params.fq}">
                        <h4>
                            Refine results
                        </h4>

                        <div id="accordion">
                            <g:set var="fqs" value="${params.list('fq')}" />
                            <g:if test="${fqs.size()>0&& fqs.get(0).length()>0}">
                                <div id="currentFilter">
                                    <div class="FieldName">
                                        Current Filters
                                    </div>

                                    <div id="currentFilters" class="subnavlist">
                                        <ul class="erk-ulist">
                                            <g:each in="${fqs}" var="fq">
                                                <g:if test="${fq.length() >0}">
                                                    <li class="erk-ulist--item">
                                                        <g:link action="list" id="${params.id}" params="${[fq:sl.excludedFqList(fqs:fqs, fq:fq), max:params.max]}" class="removeLink" title="Uncheck (remove filter)">
                                                            <span class="fa fa-check"></span>
                                                        </g:link>

                                                        <g:message code="facet.${fq.replaceFirst("kvp ","")}" default="${fq.replaceFirst("kvp ","")}" />
                                                    </li>
                                                </g:if>
                                            </g:each>
                                        </ul>
                                    </div>
                                </div>
                            </g:if>

                            <g:each in="${facets}" var="entry">
                                <g:if test="${entry.key == "listProperties"}">
                                    <g:each in="${facets.get("listProperties")}" var="value">
                                        <g:render template="facet" model="${[key:value.getKey(), values:value.getValue(), isProperty:true]}" />
                                    </g:each>
                                </g:if>
                                <g:else>
                                    <g:render template="facet" model="${[key:entry.key, values:entry.value, isProperty:false]}" />
                                </g:else>
                            </g:each>
                        </div>
                    </g:if>
                </section>
            </div>
        </div>

        <div class="col-md-9">
            <ul class="nav nav-tabs" role="tablist">
                <li class="nav-item">
                    <a class="nav-link active" data-toggle="tab" href="#list-tab" role="tab" title="View as detailed list">
                        <span class="fa fa-th-list"></span>
                        List
                    </a>
                </li>

                <li class="nav-item">
                    <a class="nav-link" data-toggle="tab" href="#grid-tab" role="tab" title="View as tumbnail image grid">
                        <span class="fa fa-th"></span>
                        Grid
                    </a>
                </li>
            </ul>

            <div class="tab-content">
                <div class="tab-pane active" id="list-tab" role="tabpanel">
                    <div class="speciesList table-responsive">
                        <table class="table table-sm table-bordered table-striped" id="speciesListTable">
                            <thead>
                                <tr>
                                    <th class="action">Action</th>
                                    <g:sortableColumn property="rawScientificName" title="Supplied Name" params="${[fq: fqs]}"></g:sortableColumn>
                                    <g:sortableColumn property="matchedName" title="Scientific Name (matched)" params="${[fq: fqs]}"></g:sortableColumn>
                                    <th>Image</th>
                                    <g:sortableColumn property="author" title="Author (matched)" params="${[fq: fqs]}"></g:sortableColumn>
                                    <g:sortableColumn property="commonName" title="Common Name (matched)" params="${[fq: fqs]}"></g:sortableColumn>
                                    <g:each in="${keys}" var="key">
                                        <th>${key}</th>
                                    </g:each>
                                </tr>
                            </thead>

                            <tbody>
                                <g:each var="result" in="${results}" status="i">
                                    <g:set var="recId" value="${result.id}" />
                                    <g:set var="bieTitle">species page for <span>${result.rawScientificName}</span></g:set>

                                    <tr class="${(i % 2) == 0 ? 'odd' : 'even'}" id="row_${recId}">
                                        <td class="action">
                                            <center>
                                                <a class="viewRecordButton" href="#viewRecord" title="view record" data-id="${recId}">
                                                    <span class="fa fa-info-circle"></span>
                                                </a>

                                                <g:if test="${userCanEditData}">
                                                    <a href="#" title="edit" data-remote="${createLink(controller: 'editor', action: 'editRecordScreen', id: result.id)}"
                                                        data-target="#editRecord_${recId}" data-toggle="modal" >
                                                        <span class="fa fa-pencil"></span>
                                                    </a>

                                                    <a href="#" title="delete" data-target="#deleteRecord_${recId}" data-toggle="modal">
                                                        <span class="fa fa-trash-o"></span>
                                                    </a>
                                                </g:if>
                                            </center>
                                        </td>

                                        <td class="rawScientificName">
                                            ${fieldValue(bean: result, field: "rawScientificName")}

                                            <g:if test="${result.guid == null}">
                                                <br />
                                                <strong>
                                                    unmatched
                                                </strong>
                                                - try
                                                <a href="http://google.com/search?q=${fieldValue(bean: result, field: "rawScientificName").trim()}" target="google">
                                                    Google
                                                </a>
                                                or
                                                <a href="${grailsApplication.config.biocache.baseURL}/occurrences/search?q=${fieldValue(bean: result, field: "rawScientificName").trim()}" target="biocache">
                                                    Occurrences
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
                                                    <img style="max-width: 400px;" src="${result.imageUrl}" class="smallSpeciesImage" />
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
                                            <g:set var="kvp" value="${result.kvpValues.find {it.key == key}}" />
                                            <g:set var="val" value="${kvp?.vocabValue?:kvp?.value}" />

                                            <td class="kvp ${val?.length() > 35 ? 'scrollWidth':''}">
                                                <div>${val}</div>
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
                        <g:set var="recId" value="${result.id}" />
                        <g:set var="bieTitle">species page for <span>${result.rawScientificName}</span></g:set>

                        <div class="imgCon">
                            <a class="thumbImage viewRecordButton" rel="thumbs" title="click to view details" href="#viewRecord"
                                data-id="${recId}">
                                <img src="${result.imageUrl?:g.createLink(uri:'/images/infobox_info_icon.png\" style=\"opacity:0.5')}" alt="thumbnail species image" />
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
                                        <br>${result.commonName}
                                    </g:if>

                                    <div class="float-right" style="display:inline-block; padding: 5px;">
                                        <a href="#viewRecord" class="viewRecordButton" title="view record" data-id="${recId}">
                                            <span class="fa fa-info-circle"></span>
                                        </a>&nbsp;

                                        <g:if test="${userCanEditData}">
                                            <a href="#" title="edit" data-remote="${createLink(controller: 'editor', action: 'editRecordScreen', id: result.id)}"
                                               data-target="#editRecord_${recId}" data-toggle="modal" >
                                               <span class="fa fa-pencil"></span>
                                            </a>&nbsp;

                                            <a href="#" title="delete" data-target="#deleteRecord_${recId}" data-toggle="modal">
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
                            <g:paginate total="${totalCount}" action="list" id="${params.id}" params="${[fq: params.fq]}" />
                        </g:if>

                        <g:else>
                            <g:paginate total="${totalCount}" action="list" id="${params.id}" />
                        </g:else>
                    </div>

                    <div class="float-right">
                        Items per page:
                        <select id="maxItems" class="input-mini" onchange="reloadWithMax(this)">
                            <g:each in="${[10,25,50,100]}" var="max">
                                <option ${(params.max == max)?'selected="selected"':''}>${max}</option>
                            </g:each>
                        </select>
                    </div>
                </div>
            </div>

            %{-- Output the BS modal divs (hidden until called) --}%
            <g:each var="result" in="${results}" status="i">
                <g:set var="recId" value="${result.id}" />

                <div class="modal fade" id="viewRecord">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header">
                                <button type="button" class="close" onclick="$('#viewRecord .modal-body').scrollTop(0);" data-dismiss="modal" aria-hidden="true">
                                    ×
                                </button>

                                <h3>
                                    View record details
                                </h3>
                            </div>

                            <div class="modal-body">
                                <p class="spinner">
                                    <img src="${resource(dir:'images',file:'spinner.gif')}" alt="spinner icon" />
                                </p>

                                %{-- TODO: .hide class. --}%
                                <table class="table table-sm table-bordered table-striped hide">
                                    <thead>
                                        <th>
                                            Field
                                        </th>

                                        <th>
                                            Value
                                        </th>
                                    </thead>

                                    <tbody></tbody>
                                </table>
                            </div>

                            %{-- TODO: .hide class. --}%
                            %{--
                            <div class="modal-footer">
                                <button class="erk-button erk-button--light hide" data-id="${recId}">Previous</button>
                                <button class="erk-button erk-button--light hide" data-id="${recId}">Next</button>
                                <button class="erk-button erk-button--light" onclick="$('#viewRecord .modal-body').scrollTop(0);" data-dismiss="modal" aria-hidden="true">Close</button>
                            </div>
                            --}%
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
                                Edit record values
                            </h3>
                        </div>

                        <div class="modal-body">
                            <p>
                                <img src="${resource(dir:'images',file:'spinner.gif')}" alt="spinner icon" />
                            </p>
                        </div>

                        <div class="modal-footer">
                            <button class="erk-button erk-button--light" data-dismiss="modal" aria-hidden="true">
                                Cancel
                            </button>

                            <button class="erk-button erk-button--light saveRecord" data-modal="#editRecord_${recId}" data-id="${recId}">
                                Save changes
                            </button>
                        </div>
                    </div>

                    <div class="modal fade" id="deleteRecord_${recId}">
                        <div class="modal-header">
                            <h3>
                                Are you sure you want to delete this species record?
                            </h3>
                        </div>

                        <div class="modal-body">
                            <p>
                                This will permanently delete the data for species <span>${result.rawScientificName}</span>
                            </p>
                        </div>

                        <div class="modal-footer">
                            <button class="erk-button erk-button--light" data-dismiss="modal" aria-hidden="true">
                                Cancel
                            </button>

                            <button class="erk-button erk-button--light deleteSpecies" data-modal="#deleteRecord_${recId}" data-id="${recId}">
                                Delete
                            </button>
                        </div>
                    </div>
                </g:if>
            </g:each>
        </div>
    </div>
</div>

<r:script>
    $(document).ready(function() {
        // make table header cells clickable
        $("table .sortable").each(function(i) {
            var href = $(this).find("a").attr("href");

            $(this).click(function() {
                window.location.href = href;
            });
        });
    });
</r:script>
</body>
</html>
