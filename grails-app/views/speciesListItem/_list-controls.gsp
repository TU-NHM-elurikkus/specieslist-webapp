<div class="inline-controls float-left">
    <div class="inline-controls__group">
        <button
            type="button"
            class="erk-button erk-button--light"
            title="${message(code: 'speciesListItem.list.viewDownload')}"
            data-toggle="modal"
            data-target="#download-dialog"
        >
            <span class="fa fa-download"></span>
            <g:message code="general.btn.download.label" />
        </button>
    </div>

    <div class="inline-controls__group">
        <button
            type="button"
            class="erk-button erk-button--light"
            data-toggle="modal"
            data-target="#list-info-modal"
        >
            <g:message code="speciesListItem.list.listInfo" />
        </button>
    </div>
</div>

<div class="inline-controls inline-controls--right float-right">
    <div class="inline-controls__group">
        <label for="per-page">
            <g:message code="general.list.pageSize.label" />
        </label>

        <select id="per-page" class="input-mini" onchange="reloadWithMax(this)">
            <g:each in="${[10, 25, 50, 100]}" var="max">
                <option ${(params.max == max)?'selected="selected"' :'' }>
                    ${max}
                </option>
            </g:each>
        </select>
    </div>
</div>
