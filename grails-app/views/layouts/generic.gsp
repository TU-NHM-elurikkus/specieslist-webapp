<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>
            <g:layoutTitle />
        </title>

        <r:require modules="jquery, fontawesome, menu"/>

        <!-- Resources -->
        <r:layoutResources/>

        <!-- Head -->
        <g:layoutHead />
    </head>

    <body>
        <div class="wrap">
            <g:render template="/menu" plugin="elurikkus-commons" />

            <g:layoutBody/>
        </div>

        <!-- Resources -->
        <r:layoutResources/>
    </body>
</html>
