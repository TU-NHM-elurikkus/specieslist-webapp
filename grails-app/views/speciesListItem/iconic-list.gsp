<!doctype html>
<g:set var="bieUrl" value="${grailsApplication.config.bie.baseURL?:'http://bie.ala.org.au'}"/>
<g:set var="collectoryUrl" value="${grailsApplication.config.collectory.baseURL}"/>
<g:set var="maxDownload" value="${grailsApplication.config.downloadLimit}"/>

<html>
    <head>
        <meta name="layout" content="${grailsApplication.config.skin.layout}"/>

        <title>
            <g:message code="general.speciesLists"/>
        </title>
        <style type="text/css">
            #buttonDiv {
                display: none;
            }
            #refine {
                display: none;
            }
            .bs-docs-sidenav {
                width: 228px;
                margin: 15px 0 0;
                padding: 0;
                background-color: #fff;
                -webkit-border-radius: 6px;
                -moz-border-radius: 6px;
                border-radius: 6px;
                -webkit-box-shadow: 0 1px 4px rgba(0,0,0,.065);
                -moz-box-shadow: 0 1px 4px rgba(0,0,0,.065);
                box-shadow: 0 1px 4px rgba(0,0,0,.065);
            }
            .bs-docs-sidenav > li > a {
                display: block;
                width: 190px \9;
                margin: 0 0 -1px;
                padding: 8px 14px;
                border: 1px solid #e5e5e5;
            }
            .bs-docs-sidenav > li:first-child > a {
                -webkit-border-radius: 6px 6px 0 0;
                -moz-border-radius: 6px 6px 0 0;
                border-radius: 6px 6px 0 0;
            }
            .bs-docs-sidenav > li:last-child > a {
                -webkit-border-radius: 0 0 6px 6px;
                -moz-border-radius: 0 0 6px 6px;
                border-radius: 0 0 6px 6px;
            }
            .bs-docs-sidenav > .active > a {
                /*position: relative;*/
                /*z-index: 2;*/
                padding: 9px 15px;
                border: 0;
                text-shadow: 0 1px 0 rgba(0,0,0,.15);
                -webkit-box-shadow: inset 1px 0 0 rgba(0,0,0,.1), inset -1px 0 0 rgba(0,0,0,.1);
                -moz-box-shadow: inset 1px 0 0 rgba(0,0,0,.1), inset -1px 0 0 rgba(0,0,0,.1);
                box-shadow: inset 1px 0 0 rgba(0,0,0,.1), inset -1px 0 0 rgba(0,0,0,.1);
            }
            /* Chevrons */
            .bs-docs-sidenav .icon-chevron-right {
                float: right;
                margin-top: 2px;
                margin-right: -6px;
                opacity: 0.25;
            }
            .bs-docs-sidenav > li > a:hover {
                background-color: #f5f5f5;
            }
            .bs-docs-sidenav a:hover .icon-chevron-right {
                opacity: 0.5;
            }
            .bs-docs-sidenav .active .icon-chevron-right,
            .bs-docs-sidenav .active a:hover .icon-chevron-right {
                /*background-image: url(../img/glyphicons-halflings-white.png);*/
                opacity: 1;
            }
            .bs-docs-sidenav.affix {
                top: 50px;
            }
            .bs-docs-sidenav.affix-bottomX {
                position: absolute;
                top: auto;
                bottom: 270px;
            }

            .general-search {
                width: 500px;
            }

            /* Responsive
        -------------------------------------------------- */

            /* Desktop large
        ------------------------- */
            @media (min-width: 1200px) {
                .bs-docs-container {
                    max-width: 970px;
                }
                .bs-docs-sidenav {
                    width: 258px;
                }
                .bs-docs-sidenav > li > a {
                    width: 230px \9;
                    /* Override the previous IE8-9 hack */
                }
                .general-search {
                    width: 500px;
                }
            }

            /* Desktop
        ------------------------- */
            @media (max-width: 980px) {
                /* When affixed, space properly */
                .bs-docs-sidenav {
                    top: 0;
                    width: 215px;
                    margin-top: 30px;
                    margin-right: 0;
                }
                .general-search {
                    width: 400px;
                }
            }

            /* Tablet to desktop
        ------------------------- */
            @media (min-width: 768px) and (max-width: 979px) {

                /* Adjust sidenav width */
                .bs-docs-sidenav {
                    width: 160px;
                    margin-top: 20px;
                }
                .bs-docs-sidenav.affix {
                    top: 0;
                }
                .general-search {
                    width: 300px;
                }
            }

            /* Tablet
        ------------------------- */
            @media (max-width: 767px) {
                /* Sidenav */
                .bs-docs-sidenav {
                    width: auto;
                    margin-bottom: 20px;
                }
                .bs-docs-sidenav.affix {
                    position: static;
                    width: auto;
                    top: 0;
                }
                .input-append .general-search {
                    width: 100%;
                }
            }

        </style>

        <g:javascript>
            $(document).ready(function(){
                // BS affix plugin for groups menu
                $('#groupsNav').affix({
                    offset: { top: $('#groupsNav').offset().top }
                });

            }); // end document ready

            function reloadWithMax(el) {
                var max = $(el).find(":selected").val();
                var params = {
                    max: max,
                    sort: "${params.sort}",
                    order: "${params.order}",
                    offset: "${params.offset?:0}",
                    fq: "${params.fq?:'kvp group:Birds'}"
                }
                var paramStr = jQuery.param(params);
                window.location.href =  '?' + paramStr;
            }
        </g:javascript>
    </head>
    <body class="yui-skin-sam nav-species">
        <div id="content">

            <div class="inner row-fluid">
                <div class="span12">
                    <h2>
                        <g:message code="speciesListItem.iconic.australia"/>
                    </h2>
                    <form
                        class="search-form"
                        role="search"
                        action="${bieUrl}/search"
                        method="get"
                        style="margin-bottom: 0"
                    >
                        <div class="input-append">
                            <input class="general-search" type="text" name="q" placeholder="Search Australia's Species"/>
                            <button class="erk-button erk-button--light" type="submit">
                                <g:message code="general.search"/>
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <g:if test="${flash.message}">
                <div class="inner row-fluid">
                    <div class="message alert alert-info">
                        <b><g:message code="general.alert"/>:</b>
                        ${flash.message}
                    </div>
                    <div>
            </g:if>

                    <h3>
                        <g:message code="speciesListItem.iconic.australiaBrowse"/>
                    </h3>

                    <div class="inner row-fluid">
                        <div class="span3">
                            <ul id="groupsNav" class="nav nav-list bs-docs-sidenav affix-top">
                                <g:set var="fqs" value="${params.list('fq')}"/>
                                <g:each in="${facets.get(" listProperties")}" var="group">
                                    <g:if test="${group.getKey() == 'group'}">
                                        <g:each in="${group.getValue().sort{it[1]}}" var="arr" status="i">
                                            <g:set
                                                var="active"
                                                value="${fqs.any{ it.contains(arr[1])} ? " active" : " "}"
                                            />
                                            <li class="${active}">
                                                <a href="?fq=kvp ${arr[0]}:${arr[1]}">
                                                    ${arr[1]} (${arr[3]})
                                                    <span class="fa fa-chevron-right"></span>
                                                </a>
                                            </li>
                                        </g:each>
                                    </g:if>
                                </g:each>
                            </ul>
                        </div>
                        <%-- /span3 --%>

                        <div class="span9">
                            <div id="gridView">
                                <g:each var="result" in="${results}" status="i">
                                    <g:set var="recId" value="${result.id}"/>
                                    <g:set var="bieSpecies" value="${bieItems?.get(result.guid)}"/>
                                    <g:set var="bieTitle">
                                        <g:message code="general.speciesPage"/>
                                        <i>
                                            ${result.rawScientificName}
                                        </i>
                                    </g:set>
                                    <div class="gallery-thumb">
                                        <a
                                            rel="thumbs"
                                            href="${bieUrl}/species/${result.guid?:bieSpecies?.get(2)}"
                                            data-id="${recId}"
                                        >
                                            <img
                                                class="gallery-thumb__img"
                                                src="${bieSpecies?.get(0)?:assetPath(src: 'fa-image.svg')}"
                                                alt="thumbnail species image"
                                            />
                                        </a>
                                        <g:set var="displayName">
                                            <g:if test="${bieSpecies?.get(1)}">
                                                ${bieSpecies?.get(1)}
                                            </g:if>
                                            <g:else>
                                                <i>
                                                    <g:if test="${result.guid == null}">
                                                        ${fieldValue(bean: result, field: "rawScientificName")}
                                                    </g:if>
                                                    <g:else>
                                                        ${bieSpecies?.get(2)}
                                                    </g:else>
                                                </i>
                                            </g:else>
                                        </g:set>
                                        <div class="gallery-thumb__footer">
                                            ${displayName}
                                        </div>
                                    </div>
                                </g:each>
                            </div>
                            <%-- /#iconView --%>

                            <g:if test="${params.max<totalCount}">
                                <div class="searchWidgets">
                                    <g:message code="message"/>
                                    <select id="maxItems" class="input-mini" onchange="reloadWithMax(this)">
                                        <g:each in="${[10,25,50,100]}" var="max">
                                            <option ${(params.max == max)?'selected="selected"' :'' }>
                                                ${max}
                                            </option>
                                        </g:each>
                                    </select>
                                </div>

                                <div class="pagination" id="searchNavBar">
                                    <g:if test="${params.fq}">
                                        <g:paginate
                                            total="${totalCount}"
                                            action="iconicSpecies"
                                            id="${params.id}"
                                            params="${[fq: params.fq]}"
                                        />
                                    </g:if>
                                    <g:else>
                                        <g:paginate total="${totalCount}" action="iconicSpecies" id="${params.id}"/>
                                    </g:else>
                                </div>
                            </g:if>
                        </div>
                        <!-- .span9 -->
                    </div>
                </div>
                <!-- content div -->

            </body>
        </html>
