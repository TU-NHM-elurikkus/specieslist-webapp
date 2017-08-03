<%--
    Document   : downloadDiv
    Created on : Feb 25, 2011, 4:20:32 PM
    Author     : "Nick dos Remedios <Nick.dosRemedios@csiro.au>"
--%>

<div class="modal fade" id="download-dialog" tabindex="-1" role="dialog" aria-labelledby="download-dialog-title" aria-hidden="true">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                    ×
                </button>

                <h3 id="download-dialog-title">
                    <g:message code="download.downloads" />
                </h3>
            </div>

            <div class="modal-body">
                <p>
                    <g:message code="download.terms1" />
                    <a href="http://www.ala.org.au/about/terms-of-use/#TOUusingcontent">
                        <g:message code="download.terms2" />
                    </a>
                    <g:message code="download.terms3" />
                </p>

                <p>
                    <g:message code="download.sentence" />
                </p>

                <form>
                    <div class="form-group row">
                        <label for="email" class="col-sm-4 col-md-3 col-lg-2 col-form-label">
                            <g:message code="general.email" />
                        </label>

                        <input
                            type="text"
                            name="email"
                            id="email"
                            value="${request.remoteUser}"
                            size="30"
                            class="col-sm-8 col-md-6 col-lg-4" />
                    </div>

                    <div class="form-group row">
                        <label for="filename" class="col-sm-4 col-md-3 col-lg-2 col-form-label">
                            <g:message code="download.file" />
                        </label>

                        <input
                            type="text"
                            name="filename"
                            id="filename"
                            value="${speciesList?.listName?.replaceAll(~/\s+/, "_")?:"data"}"
                            size="30"
                            class="col-sm-8 col-md-6 col-lg-4" />
                    </div>

                    <div class="form-group row">
                        <label for="reasonTypeId" class="col-sm-4 col-md-3 col-lg-2 col-form-label">
                            <g:message code="download.reason" />
                        </label>

                        <select name="reasonTypeId" id="reasonTypeId" class="col-sm-8 col-md-6 col-lg-4">
                            <option value="">
                                -- <g:message code="download.select" /> --
                            </option>

                            <g:each in="${downloadReasons}" var="reason">
                                <option value="${reason.key}">
                                    ${reason.value}
                                </option>
                            </g:each>
                        </select>
                    </div>

                    <div class="form-group row">
                        <div class="col">
                            <button type="button" class="actionButton erk-button erk-button--light" id="downloadSubmitButton" onclick="return downloadOccurrences()">
                                <g:message code="download.all" />
                            </button>

                            <g:if test="${grailsApplication.config.fieldGuide.baseURL}">
                                <button type="button" class="actionButton erk-button erk-button--light" id="downloadFieldGuideSubmitButton">
                                    <g:message code="download.fieldGuide" />
                                </button>
                            </g:if>

                            <button type="button" class="actionButton erk-button erk-button--light" id="downloadSpeciesListSubmitButton">
                                <g:message code="download.list" />
                            </button>
                        </div>
                    </div>
                </form>

                <g:if test="${grailsApplication.config.fieldGuide.baseURL}">
                    <p>
                        <strong><g:message code="download.note" /></strong>: <g:message code="download.noteDescription" />
                    </p>
                </g:if>

                <div id="statusMsg" style="text-align: center; font-weight: bold; "></div>

                <script type="text/javascript">
                    $(document).ready(function() {
                        // catch download submit button
                        // Note the unbind().bind() syntax - due to Jquery ready being inside <body> tag.

                        $("#downloadSubmitButton").unbind("click").bind("click",function(e) {
                            e.preventDefault();

                            if (validateForm()) {
                                downloadURL = "${request.contextPath}/speciesList/occurrences/${params.id}${params.toQueryString()}&type=Download&email="+$("#email").val()+"&reasonTypeId="+$("#reasonTypeId").val()+"&file="+$("#filename").val();
                                window.location.href = downloadURL;
                                notifyDownloadStarted()
                            }
                        });

                        $("#downloadSpeciesListSubmitButton").unbind("click").bind("click",function(e) {
                            e.preventDefault();
                            if(validateForm()){
                                //alert("${request.contextPath}/speciesListItem/downloadList/${params.id}${params.toQueryString()}&file="+$("#filename").val())
                                window.location.href = "${request.contextPath}/speciesListItem/downloadList/${params.id}${params.toQueryString()}&file="+$("#filename").val()
                                notifyDownloadStarted()
                            }
                        });

                        // catch checklist download submit button
                        $("#downloadFieldGuideSubmitButton").unbind("click").bind("click",function(e) {
                            e.preventDefault();

                            if (validateForm()) {
                                var downloadUrl = "${request.contextPath}/speciesList/fieldGuide/${params.id}${params.toQueryString()}"
                                //alert(downloadUrl)
                                window.open(downloadUrl);
                                notifyDownloadStarted()
                            }
                        });
                    });

                    function generateDownloadPrefix(downloadUrlPrefix) {
                        downloadUrlPrefix = downloadUrlPrefix.replace(/\\ /g, " ");
                        var searchParams = $(":input#searchParams").val();
                        if (searchParams) {
                            downloadUrlPrefix += searchParams;
                        } else {
                            // EYA page is JS driven
                            downloadUrlPrefix += "?q=*:*&lat="+$('#latitude').val()+"&lon="+$('#longitude').val()+"&radius="+$('#radius').val();
                        }

                        return downloadUrlPrefix;
                    }

                    function notifyDownloadStarted() {
                        $("#statusMsg").html("Download has commenced");
                        window.setTimeout(function() {
                            $("#statusMsg").html("");
                            $('#download-dialog').modal('hide')
                        }, 2000);
                    }

                    function validateForm() {
                        var isValid = false;
                        var reasonId = $("#reasonTypeId option:selected").val();

                        if (reasonId) {
                            isValid = true;
                        } else {
                            $("#reasonTypeId").focus();
                            $("label[for='reasonTypeId']").css("color","red");
                            alert("Please select a \"download reason\" from the drop-down list");
                        }

                        return isValid;
                    }
                </script>
            </div>

            <div class="modal-footer">
                <button class="erk-button erk-button--light" data-dismiss="modal" aria-hidden="true">
                    <g:message code="general.close" />
                </button>
            </div>
        </div>
    </div>
</div>
