package au.org.ala.specieslist

import org.springframework.context.i18n.LocaleContextHolder


class PublicCommand {
    int max
    String sort
    String order

    static constrainst = {
        max(
            size: 10..100,
        )
        sort(
            inList: [
                "listName", "listType", "isAuthoritative", "isInvasive", "isThreatened", "ownerFullName", "dateCreated",
                "itemsCount",
            ],
        )
        order(
            inList: ["asc", "desc"],
        )
    }
}


class PublicController {

    def queryService

    def index() {
        //redirect to the correct type of list based on whether or not the use is logged in
        try {
            redirect(action: "speciesLists")
        } catch(Exception e) {
            render(
                view: "../error",
                model: [message: "Unable to retrieve species lists. Please let us know if this error persists. <br>Error: <br>" + e.getMessage()])
        }
    }

    def speciesLists(PublicCommand cmd) {
        if (cmd.hasErrors()) {
            if (cmd.errors.hasFieldErrors("max")) {
                params.max = 25
            }
            if (cmd.errors.hasFieldErrors("sort")) {
                params.sort = "listName"
            }
        }

        // Default values
        params.order = params.order ?: "asc"
        params.sort = params.sort ?: "listName"
        params.max = params.int("max", 25)

        def locale = LocaleContextHolder.getLocale().getLanguage()

        try {
            def lists = queryService.getLists(params, locale)
            def count = lists.size()

            render(
                view: "specieslists",
                model: [lists: lists, total: count, locale: locale]
            )
        }
        catch(Exception e) {
            log.error "Error requesting species Lists: ", e
            response.status = 404
            render(
                view: "../error",
                model: [message: "Unable to retrieve species lists. Please let us know if this error persists. <br>Error: <br>" + e.getMessage()])
        }
    }
}
