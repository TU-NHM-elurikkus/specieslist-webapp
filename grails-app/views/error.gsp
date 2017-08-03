<html>
<head>
    <title>Grails Runtime Exception</title>
    <meta name="layout" content="main" />

</head>

<body>
    <header id="page-header">
        <div class="inner">
            <div id="breadcrumb" class="">
                <ol class="breadcrumb">
                    %{--<li><a href="http://www.ala.org.au">Home</a> <span class=" icon icon-arrow-right"></span></li>--}%
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
                ${message}
            </pre>
        </div>
        <div>
            ${exception}
        </div>
        <%-- class: ${exception.metaClass?.getTheClass()} --%>
        <g:renderException exception="${exception}" />
    </div>
</body>
</html>
