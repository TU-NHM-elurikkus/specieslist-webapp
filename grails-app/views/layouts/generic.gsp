<!DOCTYPE html>
<%@ page import="grails.util.Environment" %>

<html lang="en">
    <head>
        <meta charset="utf-8" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />

        <g:render template="/manifest" plugin="elurikkus-commons" />

        <title>
            <g:layoutTitle />
        </title>

        <script>
            var GRAILS_APP = {
                environment: "${Environment.current.name}",
                rollbarApiKey: "${grailsApplication.config.rollbar.postApiKey}"
            };
        </script>

        <asset:stylesheet src="lists.css" />
        <asset:javascript src="lists.js" />

        <g:layoutHead />
    </head>

    <body>
        <g:render template="/menu" plugin="elurikkus-commons" />

        <div class="wrap">
            <g:layoutBody />
        </div>

        <g:render template="/footer" plugin="elurikkus-commons" />
    </body>
</html>
