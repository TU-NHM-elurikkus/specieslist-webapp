<%--
  Created by IntelliJ IDEA.
  User: dos009
  Date: 21/03/13
  Time: 9:01 AM
  To change this template use File | Settings | File Templates.
--%>
<html>

    <head>
        <title>
            <g:message code="editor.permissions.title"/>
        </title>
    </head>

    <body>
        <g:if test="${flash.message}">
            <div class="message alert alert-info">
                <b><g:message code="general.alert"/>:</b>
                ${flash.message}
            </div>
        </g:if>

        <div>
            <g:message code="editor.permissions.description"/>
        </div>

        <div>
            &nbsp;
        </div>

        <form class="form-inline" id="userEditForm">
            <label class="control-label" for="search">
                <g:message code="editor.permissions.emailDescription"/>
            </label>
            <input id="search" type="text" class="input-xlarge" data-provide="typeahead" placeholder="Enter user's email address" autocomplete="off"/>
            <button type="submit" class="erk-button erk-button--light">
                <g:message code="editor.permissions.add"/>
            </button>
        </form>

        <table id="userTable" class="table table-bordered" style="margin-top: 10px;">
            <thead>
                <tr>
                    <th>
                        <g:message code="editor.permissions.name"/>
                    </th>
                    <th>
                        <g:message code="general.email"/>
                    </th>
                    <th>
                        <g:message code="editor.permissions.role"/>
                    </th>
                    <th>
                        <g:message code="general.action"/>
                    </th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>${speciesList.getFullName()}</td>
                    <td>${speciesList.username}</td>
                    <td><g:message code="general.owner"/></td>
                    <td></td>
                </tr>
                <g:set var="removeLink">
                    <a href='#' onclick='removeRow(this)'>
                        <g:message code="general.remove"/>
                    </a>
                </g:set>
                %{--<g:each in="${speciesList.editors}" var="editor">--}%
                    <g:each in="${editorsWithDetails}" var="editor">
                        <tr class='editor'>
                            <td>${editor.displayName}</td>
                            <td class='userId' data-userid='${editor.userId}'>${editor.userName}</td>
                            <td><g:message code="editor.permissions.editor"/></td>
                            <td>${removeLink}</td>
                        </tr>
                    </g:each>
                </tbody>
            </table>

            <script type="text/javascript">

                /**
        * Delete a row from the table
        */
                function removeRow(link) {
                    $(link).parent().parent().remove();
                }

                $(document).ready(function () {

                    /**
             * Add button for user id input - adds ID to the table
             */
                    $("#userEditForm").submit(function () {
                        var userId = $("#search").val().trim();
                        var url = "${g.createLink(controller:'webService', action:'checkEmailExists')}?email=" + userId;
                        $.getJSON(url, function (data) {
                            if (data && data.userId) {
                                console.log('data', data);
                                $("#userTable tbody").append("<tr class='editor'><td>" + data.displayName + "</td><td class='userId' data-userid='" + data.userId + "'>" + data.userName + "</td><td>editor</td><td>${removeLink}</td></tr>");
                                $("#search").val("");
                            } else {
                                alert("The user id " + userId + " was not found");
                            }
                        }).fail(function (jqxhr, textStatus, error) {
                            alert('Error checking email address: ' + textStatus + ', ' + error);
                        }).always(function () {
                            //$('#gallerySpinner').hide();
                        });
                        return false;
                    });

                    /**
             * Save changes button on modal div (in calling page)
             */
                    $("#saveEditors").click(function (el) {
                        el.preventDefault();
                        var editors = [];
                        $("#userTable tr.editor").each(function () {
                            //editors.push($(this).find("td.userId").html());
                            editors.push($(this).find("td.userId").data('userid'));
                        });
                        //console.log("editors", editors);
                        var params = {
                            id: "${params.id}",
                            editors: editors
                        };
                        $.post("${createLink(action: 'updateEditors')}", params, function (data, textStatus, jqXHR) {
                            //console.log("data", data, "textStatus", textStatus,"jqXHR", jqXHR);
                            alert("Editors were successfully saved");
                            $('#modal').modal('hide');
                            window.location.reload(true);
                        }).error(function (jqXHR, textStatus, error) {
                            alert("An error occurred: " + error + " - " + jqXHR.responseText);
                        });
                    });
                });
            </script>
        </body>
    </html>
