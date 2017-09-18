<div id="parsedData" xmlns="http://www.w3.org/1999/html">
    <div id="tabulatedData">
        <style type="text/css">
            table {
                border-collapse: collapse;
                margin-bottom: 0;
            }
            .fwtable {
                overflow-y: hidden;
                overflow-x: auto;
                width: 100%;
            }

        </style>

        <h1></h1>
        <g:if test="${error}">
            <div class="message alert alert-error">
                ${error}
            </div>
        </g:if>
        <g:else>
            <div id="recognisedDataDiv">
                <h2>
                    <g:message code="speciesList.parsedData.initial"/>
                </h2>
                <g:if test="${!nameFound}">
                    <div class="alert alert-error">
                        <g:message code="speciesList.parsedData.alert"/>
                        <g:each in="${nameColumns}" var="nc" status="i">
                            <g:if test="${i == nameColumns.size() - 1}">
                                , or
                            </g:if>
                            <g:elseif test="${i != 0}">
                                ,
                            </g:elseif>
                            “${nc}”
                        </g:each>
                    </div>
                </g:if>

                <p>
                    <g:message code="speciesList.parsedData.headingsAdjust"/>
                </p>

                <div class="fwtable table-responsive">
                    <table id="initialParse" class="table table-sm table-striped table-bordered">
                        <thead>
                            <g:if test="${columnHeaders}">
                                <g:each in="${columnHeaders}" var="hdr">
                                    <th class="parse">
                                        <input
                                            id="Head_${hdr}"
                                            class="columnHeaderInput"
                                            type="text"
                                            value="${hdr}"
                                            style="${hdr.startsWith('UNKNOWN') ? 'background-color: #E9AB17;' : ''}"
                                            onkeyup="javascript:window.setTimeout('updateH3(this.id)', 500, true);"
                                        />
                                    </th>
                                </g:each>
                            </g:if>
                        </thead>
                        <tbody>
                            <g:each in="${dataRows}" var="row">
                                <tr>
                                    <g:each in="${row}" var="value">
                                        <td class="parse">${value}</td>
                                    </g:each>
                                </tr>
                            </g:each>
                        </tbody>
                    </table>
                </div>
            </div>
            <%-- #recognisedDataDiv --%>

            <g:if test="${listProperties}">
                <p>
                    <g:message code="speciesList.parsedData.properties1"/>
                    <br/>
                    <g:message code="speciesList.parsedData.properties2"/>
                    <br/>
                    <g:message code="speciesList.parsedData.properties3"/>
                    <input
                        id="viewVocabButton"
                        class="datasetName actionButton erk-button erk-button--light"
                        type="button"
                        value="Click here to map..."
                        onclick="javascript:viewVocab();"
                    />
                </p>

                <div class="allVocabs well" id="listvocab">

                    <div class="pull-right">
                        <button class="erk-button erk-button--light" onclick="javascript:hideVocab();">
                            <g:message code="general.btn.close"/>
                        </button>
                    </div>

                    <g:each in="${listProperties.keySet()}" var="key">
                        <div class="vocabDiv">
                            <h3 class="vocabHeader" for="Head_${key}">
                                ${key}
                            </h3>

                            <div class="fhtable">
                                <table class="vocabularyTable table table-condensed" id="Voc_${key}" for="Head_${key}">
                                    <thead>
                                        <th class="parse">
                                            <g:message code="general.value"/>
                                        </th>
                                        <th class="parse">
                                            <g:message code="speciesList.parsedData.mapsTo"/>
                                        </th>
                                    </thead>
                                    <tbody class="vocabBody">
                                        <g:each in="${listProperties.get(key)}" var="rawKeyVal">
                                            <tr>
                                                <td class="parse">
                                                    ${rawKeyVal}
                                                </td>
                                                <td class="parse">
                                                    <input class="vocabHeader_${key}" type="text" value="">
                                                </td>
                                            </tr>
                                        </g:each>
                                    </tbody>
                                </table>
                            </div>
                            <%-- fhtable --%>
                        </div>
                        <%-- #vocabDiv --%>
                    </g:each>

                    <div class="pull-right">
                        <button class="erk-button erk-button--light" onclick="javascript:hideVocab();">
                            <g:message code="general.btn.close"/>
                        </button>
                    </div>
                </div>
                <%-- #listvocab --%>
            </g:if>
        </g:else>
    </div>
</div>
