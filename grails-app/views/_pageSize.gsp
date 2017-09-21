<script type="text/javascript">
    function reloadWithMax(el) {
        var max = $(el).find(":selected").val();
        //  collect all the params that are applicable for the a page resizing
        var paramStr = "${raw(params.findAll {key, value -> key != 'max' && key != 'offset' && key != 'controller' && key != 'action'}.collect { it }.join('&'))}&max=" + max
        window.location.href = window.location.pathname + '?' + paramStr;
    }
</script>

<g:message code="general.list.pageSize.label"/>:
<select onchange="reloadWithMax(this)">
    <g:each in="${[10, 25, 50, 100]}" var="max">
        <option ${(params.max == max) ? 'selected="selected"' : '' }>
            ${max}
        </option>
    </g:each>
</select>
