<div class="list-items-controls clearfix">
    <div class="float-left">
        <button
            type="button"
            class="erk-button erk-button--light"
            data-toggle="modal"
            data-target="#list-info-modal"
        >
            <i class="fa fa-info-circle"></i>
            <g:message code="speciesListItem.list.listInfo" />
        </button>

        <button type="button" class="erk-button erk-button--light"
            title="${message(code: 'speciesListItem.list.viewDownload')}" data-toggle="modal"
            data-target="#download-dialog">

            <i class="fa fa-download"></i>
            <g:message code="speciesListItem.list.download" />
        </button>
    </div>

    <div class="float-right">
        <g:message code="general.pageItems" />:
        <select class="input-mini" onchange="reloadWithMax(this)">
            <g:each in="${[10,25,50,100]}" var="max">
                <option ${(params.max == max)?'selected="selected"' :'' }>
                    ${max}
                </option>
            </g:each>
        </select>
    </div>
</div>
