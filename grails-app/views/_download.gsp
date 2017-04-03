<%--
    Document   : downloadDiv
    Created on : Feb 25, 2011, 4:20:32 PM
    Author     : "Nick dos Remedios <Nick.dosRemedios@csiro.au>"
--%>

<div>
    <p>
        By downloading this content you are agreeing to use it in accordance with the Atlas of Living Australia
        <a href="http://www.ala.org.au/about/terms-of-use/#TOUusingcontent">Terms of Use</a> and any Data Provider Terms associated with the data download.
    </p>

    <p>
        Please provide the following details before downloading (* required):
    </p>

    <form>
        <div class="form-group row">
            <label for="email" class="col-sm-4 col-md-3 col-lg-2 col-form-label">
                Email
            </label>

            <input type="text" name="email" id="email" value="${request.remoteUser}" size="30" class="col-sm-8 col-md-6 col-lg-4"/>
        </div>

        <div class="form-group row">
            <label for="filename" class="col-sm-4 col-md-3 col-lg-2 col-form-label">
                File Name
            </label>

            <input type="text" name="filename" id="filename" value="${speciesList?.listName?.replaceAll(~/\s+/, "_")?:"data"}" size="30" class="col-sm-8 col-md-6 col-lg-4"/>
        </div>

        <div class="form-group row">
            <label for="reasonTypeId" class="col-sm-4 col-md-3 col-lg-2 col-form-label">
                Download Reason *
            </label>

            <select name="reasonTypeId" id="reasonTypeId" class="col-sm-8 col-md-6 col-lg-4">
                <option value="">-- select a reason --</option>

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
                    Download All Records
                </button>

                <g:if test="${grailsApplication.config.fieldGuide.baseURL}">
                    <button type="button" class="actionButton erk-button erk-button--light" id="downloadFieldGuideSubmitButton">
                        Download Species Field Guide
                    </button>
                </g:if>

                <button type="button" class="actionButton erk-button erk-button--light" id="downloadSpeciesListSubmitButton">
                    Download Species List
                </button>
            </div>
        </div>
    </form>

    <g:if test="${grailsApplication.config.fieldGuide.baseURL}">
        <p>
            <strong>Note</strong>: The field guide may take several minutes to prepare and download.
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
                $.fancybox.close();
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
