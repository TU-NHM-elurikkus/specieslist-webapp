package au.org.ala.specieslist

import grails.converters.*
import grails.web.JSONBuilder
import org.springframework.context.i18n.LocaleContextHolder;

class PublicController {

    def queryService

    def index() {
        //redirect to the correct type of list based on whether or not the use is logged in
        try {
            redirect(action: 'speciesLists')
        } catch(Exception e) {
            render(view: '../error', model: [message: "Unable to retrieve species lists. Please let us know if this error persists. <br>Error:<br>" + e.getMessage()])
        }
    }

    def speciesLists() {
        if (params.isSDS) {
            // work around for SDS sub-list
            redirect(action:'sdsLists')
            return
        }

        params.max = Math.min(params.max ? params.int('max') : 25, 100)
        params.sort = params.sort ?: "listName"

        if (params.sort == "name") {
            params.sort = "listName"
        }

        log.info "params = " + params

        def locale = LocaleContextHolder.getLocale().getLanguage()

        try{
            def lists = queryService.getLists(params, locale)
            def count = lists.size()

            render (view:'specieslists', model:[
                lists: lists,
                total: count,
                locale: locale
            ])
        }
        catch(Exception e) {
            log.error "Error requesting species Lists: " ,e
            response.status = 404
            render(view: '../error', model: [message: "Unable to retrieve species lists. Please let us know if this error persists. <br>Error:<br>" + e.getMessage()])
        }
    }

    def sdsLists() {
        params.isSDS = "eq:true"
        try {
            def lists = queryService.getFilterListResult(params)
            log.debug("Lists: " + lists)
            render (view:'specieslists', model:[lists:lists, total:lists.totalCount])
        }
        catch(Exception e){
            log.error "Error requesting species Lists: " ,e
            response.status = 404
            render(view: '../error', model: [message: "Unable to retrieve species lists. Please let us know if this error persists. <br>Error:<br>" + e.getMessage()])
        }
    }

}
