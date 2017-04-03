modules = {
    application {
        resource url: 'js/application.js'
        resource url: 'css/AlaBsAdditions.css'
    }

    fancybox {
        resource url: 'js/fancybox3/jquery.fancybox.min.css'
        resource url: 'js/fancybox3/jquery.fancybox.min.js'
    }

    amplify {
        resource url: [dir: 'js', file: 'amplify.js']
    }

    fileupload {
        resource url: [dir: 'js', file: 'bootstrap-fileupload.min.js']
        resource url: [dir: 'css', file: 'bootstrap-fileupload.min.css']
    }
}
