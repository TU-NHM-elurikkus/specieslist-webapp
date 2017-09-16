package au.org.ala.specieslist

class ListName {
    String name
    String locale

    static belongsTo = [slist: SpeciesList]

    static constraints = {
    }
}
