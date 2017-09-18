<div
    class="modal fade"
    id="download-dialog"
    tabindex="-1" role="dialog"
    aria-labelledby="download-dialog-title"
    aria-hidden="true"
>
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h3 id="download-dialog-title">
                    <g:message code="general.btn.download.title"/>
                </h3>
            </div>

            <div id="downloadForm" class="modal-body">
                <p>
                    <g:message code="download.terms1"/>
                    <a href="https://plutof.ut.ee/#/privacy-policy" target="_blank">
                        <g:message code="download.terms2"/>
                    </a>
                    <g:message code="download.terms3"/>
                </p>

                <p>
                    <g:message code="download.sentence"/>
                </p>

                <form>
                    <div class="form-group">
                        <label for="email">
                            <g:message code="general.email"/>
                        </label>

                        <input
                            type="text"
                            name="email"
                            id="email"
                            value="${request.remoteUser}"
                            class="form-control"
                        />
                    </div>

                    <div class="form-group">
                        <label for="filename">
                            <g:message code="download.file"/>
                        </label>

                        <input
                            type="text"
                            name="filename"
                            id="filename"
                            value="${speciesList?.listName?.replaceAll(~/\s+/, '_')?:" data"}"
                            class="form-control"
                        />
                    </div>

                    <div class="form-group">
                        <label for="reasonTypeId">
                            <g:message code="download.reason"/>
                        </label>

                        <select name="reasonTypeId" id="reasonTypeId" class="form-control erk-radio-input">
                            <option value="">
                                --
                                <g:message code="download.select"/>
                                --
                            </option>

                            <g:each in="${downloadReasons}" var="reason">
                                <option value="${reason.key}">
                                    ${reason.value}
                                </option>
                            </g:each>
                        </select>
                    </div>

                    <div id="download-types" class="form-group">
                        <label class="control-label" for="downloadOption">
                            <g:message code="download.form.downloadType.label" /> *
                        </label>

                        <div>
                            <label class="erk-radio-label">
                                <input
                                    type="radio"
                                    class="erk-radio-input"
                                    name="download-types"
                                    value=0
                                    checked
                                >
                                &nbsp;<g:message code="download.all"/>
                            </label>
                        </div>
                        <div>
                            <label class="erk-radio-label">
                                <input
                                    type="radio"
                                    class="erk-radio-input"
                                    name="download-types"
                                    value=1
                                >
                                &nbsp;<g:message code="download.list"/>
                            </label>
                        </div>
                    </div>
                </form>

                <script type="text/javascript">
                    $(document).ready(function() {
                        // catch download submit button. Note Nick's unbind().bind() syntax - due to Jquery ready being inside <body> tag.
                        $("#downloadStart").unbind("click").bind("click",function(e) {
                            e.preventDefault();
                            var downloadOption = $("input:radio[name=download-types]:checked").val();

                            if(validateForm()) {
                                if(downloadOption == "1") {
                                    window.location.href =
                                        '${request.contextPath}/speciesListItem/downloadList/${params.id}${params.toQueryString()}' +
                                        '&file=' + $("#filename").val();
                                    notifyDownloadStarted();
                                } else {
                                    window.location.href =
                                        '${request.contextPath}/speciesList/occurrences/${params.id}${params.toQueryString()}' +
                                        '&type=Download' +
                                        '&email=' + $('#email').val() +
                                        '&reasonTypeId=' + $('#reasonTypeId').val() +
                                        '&file=' + $('#filename').val();
                                    notifyDownloadStarted();
                                }
                            }
                        });
                    });

                    function generateDownloadPrefix(downloadUrlPrefix) {
                        downloadUrlPrefix = downloadUrlPrefix.replace(/\\ /g, " ");
                        var searchParams = $(":input#searchParams").val();
                        if(searchParams) {
                            downloadUrlPrefix += searchParams;
                        } else {
                            // EYA page is JS driven
                            downloadUrlPrefix += '?q=*:*' +
                                '&lat=' + $('#latitude').val() +
                                '&lon=' + $('#longitude').val() +
                                '&radius=' + $('#radius').val();
                        }

                        return downloadUrlPrefix;
                    }

                    function notifyDownloadStarted() {
                        window.setTimeout(function() {
                            $('#download-dialog').modal('hide')
                        }, 500);
                    }

                    function validateForm() {
                        var isValid = true;
                        var reasonId = $("#reasonTypeId option:selected").val();

                        if(!reasonId) {
                            isValid = false;
                            $("#reasonTypeId").focus();
                            $("label[for='reasonTypeId']").css("color", "red");
                        } else {
                            $("label[for='reasonTypeId']").css("color", "inherit");
                        }

                        return isValid;
                    }
                </script>
            </div>

            <div class="modal-footer">
                <button class="erk-button erk-button--light" data-dismiss="modal" aria-hidden="true">
                    <g:message code="general.btn.close"/>
                </button>

                <button id="downloadStart" class="erk-button erk-button--light tooltips">
                    <span class="fa fa-download"></span>
                    <g:message code="general.btn.download.label" />
                </button>
            </div>
        </div>
    </div>
</div>
