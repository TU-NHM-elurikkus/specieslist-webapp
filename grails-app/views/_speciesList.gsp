<%-- Template for displaying a list of species list with or without a delete button. --%>
<script type="text/javascript">
    function deleteAction() {
        var listId = this.id.replace('dialog_', '');
        var url = '${createLink(controller: "speciesList", action: "delete")}/' + listId;

        $.post(url, function(data) {
            window.location.reload();
        });

        this.cancel();
    }

    function confirmAction(msg, listId, action, callback) {
        var url = '${request.contextPath}/speciesList/' + action + '/' + listId;
        var doProceed = confirm(msg + listId + '?');

        if(doProceed) {
            $.post(url, function(data) {
                alert(action + ' was successful');
                window.location.reload();
            }).error(function(jqXHR, textStatus, error) {
                alert("An error occurred: " + error + " - " + jqXHR.responseText);
            });
        }
    }
</script>

<div id="speciesList" class="speciesList table-responsive vertical-block">
    <table class="table table-sm table-borderless">
        <thead>
            <tr>
                <g:sortableColumn property="listName" params="${[q:params.q]}" titleKey="general.listName" />
                <g:sortableColumn property="listType" params="${[q:params.q]}" titleKey="general.listType" />

                <g:if test="${request.isUserInRole(" ROLE_ADMIN")}">
                    <g:sortableColumn property="isBIE" params="${[q:params.q]}" titleKey="general.isBIE" />
                    <g:sortableColumn property="isSDS" params="${[q:params.q]}" titleKey="general.isSDS" />
                </g:if>

                <g:sortableColumn property="isAuthoritative" params="${[q:params.q]}" titleKey="general.isAuthoritative" />
                <g:sortableColumn property="isInvasive" params="${[q:params.q]}" titleKey="general.isInvasive" />
                <g:sortableColumn property="isThreatened" params="${[q:params.q]}" titleKey="general.isThreatened" />
                <g:sortableColumn property="ownerFullName" params="${[q:params.q]}" titleKey="general.owner" />
                <g:sortableColumn property="dateCreated" params="${[q:params.q]}" titleKey="general.dateCreated" />
                <g:sortableColumn property="itemsCount" params="${[q:params.q]}" titleKey="default.itemCount" />

                <g:if test="${request.getUserPrincipal()}">
                    <th colspan="2">
                        <g:message code="default.actions" />
                    </th>
                </g:if>
            </tr>
        </thead>

        <tbody>
            <g:each in="${lists}" var="list">
                <tr>
                    <td>
                        <a href="${request.contextPath}/speciesListItem/list/${list.dataResourceUid}">
                            <span class="fa fa-check-circle"></span> ${fieldValue(bean: list, field: "listName")}
                        </a>
                    </td>

                    <td>
                        ${list.listType?.getDisplayValue()}
                    </td>

                    <g:if test="${request.isUserInRole('ROLE_ADMIN')}">
                        <td>
                            <g:formatBoolean boolean="${list.isBIE ?: false}" true="Yes" false="No" />
                        </td>
                        <td>
                            <g:formatBoolean boolean="${list.isSDS ?: false}" true="Yes" false="No" />
                        </td>
                    </g:if>

                    <td>
                        <g:formatBoolean boolean="${list.isAuthoritative ?: false}" true="Yes" false="No" />
                    </td>
                    <td>
                        <g:formatBoolean boolean="${list.isInvasive ?: false}" true="Yes" false="No" />
                    </td>
                    <td>
                        <g:formatBoolean boolean="${list.isThreatened ?: false}" true="Yes" false="No" />
                    </td>
                    <%-- <td>${fieldValue(bean: list, field: "firstName")} ${fieldValue(bean: list, field: "surname")}</td> --%>
                    <td>
                        ${list.ownerFullName}
                    </td>
                    <td>
                        <g:formatDate format="yyyy-MM-dd" date="${list.dateCreated}" />
                    </td>
                    <td>
                        ${list.itemsCount}
                    </td>

                    <g:if test="${list.username == request.getUserPrincipal()?.attributes?.email || request.isUserInRole('ROLE_ADMIN')}">
                        <td>
                            <g:set var="test" value="${[id: list.id]}" />

                            <button
                                type="button"
                                class="erk-button erk-button--light"
                                onclick="confirmAction('Are you sure that you would like to delete ${list.listName.encodeAsHTML()}', ${list.id}, 'delete');"
                            >
                                <g:message code="default.delete" />
                            </button>
                        </td>

                        <td>
                            <button
                                type="button"
                                class="erk-button erk-button--light"
                                onclick="confirmAction('Are you sure that you would like to rematch ${list.listName.encodeAsHTML()}', ${list.id}, 'rematch');"
                            >
                                <g:message code="default.rematch" />
                            </button>
                        </td>

                        <td>
                            <button
                                type="button"
                                class="erk-button erk-button--light"
                                onclick="window.location='${request.contextPath}/speciesList/upload/${list.dataResourceUid}';"
                            >
                                <g:message code="default.reload" />
                            </button>
                        </td>
                    </g:if>
                </tr>
            </g:each>
        </tbody>
    </table>

    <g:if test="${params.max < total}">
        <div class="pagination" id="searchNavBar" data-total="${total}" data-max="${params.max}">
            <g:paginate total="${total}" params="${params}" />
        </div>
    </g:if>
</div>
