<%--
<g:if test="${userCanEditPermissions}">
    <a href="#" class="erk-button erk-button--light" id="edit-meta-button">
        <span class="fa fa-pencil"></span>
        <g:message code="speciesListItem.list.edit" />
    </a>
</g:if>
--%>

<dl class="row" id="show-meta-dl">
    <dt class="col-sm-6 col-md-6">
        ${message(code: 'general.owner')}
    </dt>
    <dd class="col-sm-6 col-md-6">
        ${speciesList.username ?: "&nbsp;"}
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
        <g:formatDate format="yyyy-MM-dd" date="${speciesList.dateCreated?:0}" /><!-- ${speciesList.lastUpdated} -->
    </dd>

    <dt class="col-sm-6 col-md-6">
        ${message(code: 'speciesListItem.list.isPrivate')}
    </dt>
    <dd class="col-sm-6 col-md-6">
        <g:formatBoolean boolean="${speciesList.isPrivate?:false}" true="Yes" false="No" />
    </dd>

    <dt class="col-sm-6 col-md-6">
        ${message(code: 'general.isBIE')}
    </dt>
    <dd class="col-sm-6 col-md-6">
        <g:formatBoolean boolean="${speciesList.isBIE?:false}" true="Yes" false="No" />
    </dd>

    <dt class="col-sm-6 col-md-6">
        ${message(code: 'general.isAuthoritative')}
    </dt>
    <dd class="col-sm-6 col-md-6">
        <g:formatBoolean boolean="${speciesList.isAuthoritative?:false}" true="Yes" false="No" />
    </dd>

    <dt class="col-sm-6 col-md-6">
        ${message(code: 'general.isInvasive')}
    </dt>
    <dd class="col-sm-6 col-md-6">
        <g:formatBoolean boolean="${speciesList.isInvasive?:false}" true="Yes" false="No" />
    </dd>

    <dt class="col-sm-6 col-md-6">
        ${message(code: 'general.isThreatened')}
    </dt>
    <dd class="col-sm-6 col-md-6">
        <g:formatBoolean boolean="${speciesList.isThreatened?:false}" true="Yes" false="No" />
    </dd>

    <dt class="col-sm-6 col-md-6">
        ${message(code: 'general.isSDS')}
    </dt>
    <dd class="col-sm-6 col-md-6">
        <g:formatBoolean boolean="${speciesList.isSDS?:false}" true="Yes" false="No" />
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

    <%-- <g:if test="${speciesList.editors}">
        <dt class="col-sm-6 col-md-6">
            ${message(code: 'speciesListItem.list.editors')}
        </dt>
        <dd class="col-sm-6 col-md-6">
            ${speciesList.editors.collect{ sl.getFullNameForUserId(userId: it) }?.join(", ")}
        </dd>
    </g:if> --%>

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
            <input type="hidden" name="id" value="${speciesList.id}" />

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

            <%-- <div class="control-group">
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
                                <sl:getFullNameForUserId userId="${userId}" />
                            </option>
                        </g:each>
                    </select>
                </div>
            </div> --%>

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
                    <input
                        type="url"
                        name="url"
                        id="url"
                        class="input-xlarge"
                        value="${speciesList.url}"
                    />
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
                        value="<g:formatDate format='yyyy-MM-dd' date='${speciesList.dateCreated?:0}' />"
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
                    <button
                        type="submit"
                        id="edit-meta-submit"
                        class="erk-button erk-button--light"
                    >
                        <g:message code="speciesListItem.list.save" />
                    </button>
                    <button
                        class="erk-button erk-button--light"
                        onclick="toggleEditMeta(false);return false;"
                    >
                        <g:message code="speciesListItem.list.cancel" />
                    </button>
                </div>
            </div>
        </form>
    </div>
</g:if>
