<html>
    <head>
        <title>Grails Runtime Exception</title>
        <meta name="layout" content="${grailsApplication.config.skin.layout}"/>
    </head>

    <body>
        <header id="page-header">
            <div class="inner">
                <div id="breadcrumb" class="">
                    <ol class="breadcrumb">
                        %{--<li>
                            <a href="http://www.ala.org.au">Home</a>
                            <span class=" icon icon-arrow-right"></span>
                        </li>--}%
                        <li>
                            <a href="${request.contextPath}/public/speciesLists">
                                Species lists
                            </a>
                            <span class=" icon icon-arrow-right"></span>
                        </li>
                        <li class="active">
                            Error Page
                        </li>
                    </ol>
                </div>

                <hgroup>
                    <h1>Error page</h1>
                </hgroup>
            </div>
        </header>

        <div class="inner">
            <div>
                <pre>
                You do not have permission to view this resource
            </pre>
            </div>
        </div>
    </body>
</html>
