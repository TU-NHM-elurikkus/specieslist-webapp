package au.org.ala.specieslist

class SpeciesListTagLib {
    static namespace = 'sl'
    static returnObjectForTags = ['buildFqList', 'excludedFqList']

    /**
     * Generates a list of filter query strings including that identified by the fq parameter, if supplied.
     *
     * @attr fqs REQUIRED the current list of filter query strings
     * @attr fq the additional filter query string to be added
     */
    def buildFqList = { attrs, body ->
        ArrayList ret = []
        def fq = attrs.fq
        if (attrs.fqs) {
            attrs.fqs.each {
                if (!ret.contains(it) && it != "") {
                    ret << it
                }
            }
        }
        if (fq && !ret.contains(fq)) {
            ret << fq
        }
        ret
    }

    /**
     * Returns an image link of desired size.
     *
     * @attr imgUrl REQUIRED original image URL
     * @attr suffix REQUIRED file name suffix
     * @attr defImgUrl REQUIRED default image URL
     */
    def getImageUrl = { attrs, body ->
        def defImgUrl = attrs.defImgUrl
        def fileSuffix = attrs.suffix
        def imgUrl = attrs.imgUrl

        if(imgUrl) {
            def fileExtension = imgUrl.substring(imgUrl.lastIndexOf('.') + 1)
            def fileName = imgUrl.take(imgUrl.lastIndexOf('.'))

            out << [fileName, fileSuffix, '.', fileExtension].join()
        } else {
            out << defImgUrl
        }
    }

    /**
     * Generates a list of filter query strings without that identified by the fq parameter
     *
     * @attr fqs REQUIRED
     * @attr fq REQUIRED
     */
    def excludedFqList = { attrs, body ->
        def fq = attrs.fq
        def remainingFq = attrs.fqs - fq
        remainingFq
    }

    /**
     * Generates an HTML id from a string
     *
     * @attr key REQUIRED the value to use as id;
     * spaces will be replaced with hyphens, brackets will be removed
     * @attr prefix a prefix to use in the returned value;
     * a hyphen will be used to separate the prefix from the key, if provided
     */
    def facetAsId = { attrs, body ->
        def prefix = attrs.prefix ? attrs.prefix + "-" : ""
        out << prefix + attrs.key.replaceAll(" ", "-")
                .replaceAll("\\(", "").replaceAll("\\)", "")
                .toLowerCase()
    }

    /**
     * Get facet name from key:value string
     *
     * @attr facet REQUIRED
     */
    def getFacetName = { attrs, body ->
        out << attrs.facet.split(":")[0]
    }

    /**
     * Get facet value from key:value string
     *
     * @attr facet REQUIRED
     */
    def getFacetValue = { attrs, body ->
        def facet = attrs.facet

        if(facet.contains(":")) {
            out << facet.split(":", 2)[1]
        }
    }
}
