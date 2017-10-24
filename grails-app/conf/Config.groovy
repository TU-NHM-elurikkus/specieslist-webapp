import grails.util.Environment


grails.project.groupId = "au.org.ala"

default_config = "/data/${appName}/config/${appName}-config.properties"
commons_config = "/data/commons/config/commons-config.properties"
env_config = "conf/${Environment.current.name}/Config.groovy"

grails.config.locations = [
    "file:${env_config}",
    "file:${commons_config}",
    "file:${default_config}"
]

if(!new File(env_config).exists()) {
    println "ERROR - [${appName}] Couldn't find environment specific configuration file: ${env_config}"
}
if(!new File(default_config).exists()) {
    println "ERROR - [${appName}] No external configuration file defined. ${default_config}"
}
if(!new File(commons_config).exists()) {
    println "ERROR - [${appName}] No external commons configuration file defined. ${commons_config}"
}

println "[${appName}] (*) grails.config.locations = ${grails.config.locations}"

bie.nameIndexLocation = "/data/lucene/namematching"
registryApiKey = "xxxxxxxxxxxxxxxxxx"
bieApiKey = "xxxxxx"

rollbar.postApiKey = "xxx"  // This should be set in the external config file

/*** Config specific for species list ***/
updateUserDetailsOnStartup = false
iconicSpecies.uid = "dr781"

skin.layout = "generic"

 //the number of species to limit downloads to
/*** End config specific for species list ***/
grails.mime.file.extensions = true // enables the parsing of file extensions from URLs into the request format
grails.mime.use.accept.header = false
grails.mime.types = [ html: ['text/html','application/xhtml+xml'],
                      xml: ['text/xml', 'application/xml'],
                      text: 'text/plain',
                      js: 'text/javascript',
                      rss: 'application/rss+xml',
                      atom: 'application/atom+xml',
                      css: 'text/css',
                      csv: 'text/csv',
                      all: '*/*',
                      json: ['application/json','text/json'],
                      form: 'application/x-www-form-urlencoded',
                      multipartForm: 'multipart/form-data'
                    ]

// The default codec used to encode data with ${}
grails.views.default.codec = "none"
grails.views.gsp.encoding = "UTF-8"
grails.converters.encoding = "UTF-8"
//grails.converters.json.default.deep=true
// enable Sitemesh preprocessing of GSP pages
grails.views.gsp.sitemesh.preprocess = true
// scaffolding templates configuration
grails.scaffolding.templates.domainSuffix = 'Instance'

// Set to false to use the new Grails 1.2 JSONBuilder in the render method
grails.json.legacy.builder = false
// enabled native2ascii conversion of i18n properties files
grails.enable.native2ascii = true
// packages to include in Spring bean scanning
grails.spring.bean.packages = []
//necessary to allow method caching for the Services.
grails.spring.disable.aspectj.autoweaving = false
// whether to disable processing of multi part requests
grails.web.disable.multipart=false

// request parameters to mask when logging exceptions
grails.exceptionresolver.params.exclude = ['password']

// enable query caching by default
grails.hibernate.cache.queries = true

//localAuthService properties
auth.userDetailsUrl='http://auth.ala.org.au/userdetails/userDetails/'
auth.userNamesForIdPath='getUserList'
auth.userNamesForNumericIdPath='getUserListWithIds'

// set per-environment serverURL stem for creating absolute links
environments {
    development {
    }
    production {}
}

logging_dir = (System.getProperty('catalina.base') ? System.getProperty('catalina.base') + '/logs'  : '/var/log/tomcat6')
if(!new File(logging_dir).exists()){
    logging_dir = '/tmp'
}


// log4j configuration
log4j = {
    // Example of changing the log pattern for the default console
    // appender:
    appenders {
        environments {
            production {
                rollingFile name: "tomcatLog", maxFileSize: 102400000, file: logging_dir + "/specieslist.log", threshold: org.apache.log4j.Level.ERROR, layout: pattern(conversionPattern: "%d %-5p [%c{1}] %m%n")
                'null' name: "stacktrace"
            }
            development {
                console name: "stdout", layout: pattern(conversionPattern: "%d %-5p [%c{1}]  %m%n"), threshold: org.apache.log4j.Level.DEBUG
            }
            test {
                rollingFile name: "tomcatLog", maxFileSize: 102400000, file: "/tmp/specieslist-test.log", threshold: org.apache.log4j.Level.DEBUG, layout: pattern(conversionPattern: "%d %-5p [%c{1}]  %m%n")
                'null' name: "stacktrace"
            }
        }
    }

    root {
        // change the root logger to my tomcatLog file
        error 'tomcatLog'
        warn 'tomcatLog'
        additivity = true
    }

    error  'org.codehaus.groovy.grails.web.servlet',  //  controllers
            'org.codehaus.groovy.grails.web.pages', //  GSP
            'org.codehaus.groovy.grails.web.sitemesh', //  layouts
            'org.codehaus.groovy.grails.web.mapping.filter', // URL mapping
            'org.codehaus.groovy.grails.web.mapping', // URL mapping
            'org.codehaus.groovy.grails.commons', // core / classloading
            'org.codehaus.groovy.grails.plugins', // plugins
            'org.codehaus.groovy.grails.orm.hibernate', // hibernate integration
            'org.springframework',
            'org.hibernate',
            'net.sf.ehcache.hibernate',
            'org.codehaus.groovy.grails.plugins.orm.auditable',
            'org.mortbay.log', 'org.springframework.webflow',
            'grails.app',
            'org.apache',
            'org',
            'com',
            'au',
            'grails.app',
            'net',
            'grails.util.GrailsUtil',
            'grails.app',
            'grails.plugin.springcache',
            'au.org.ala.cas.client',
            'grails.spring.BeanBuilder',
            'grails.plugin.webxml'
    info    'grails.app'
    debug   'au.org.ala.specieslist'
}

//springcache configuration
springcache {
    defaults {
        // set default cache properties that will apply to all caches that do not override them
        eternal = false
        diskPersistent = false
    }
    caches {
        loggerCache {
            // set any properties unique to this cache
            eternal=true
            memoryStoreEvictionPolicy = "LRU"
        }
        authCache {
            memoryStoreEvictionPolicy = "LRU"
            timeToLive="600"
        }
    }
}

grails.cache.config = {

    defaults {
        eternal false
        overflowToDisk false
        maxElementsInMemory 20000
        timeToLiveSeconds 3600
    }
    cache {
        name 'userListCache'
    }
    cache {
        name 'userMapCache'
    }
    cache {
        name 'userDetailsCache'
    }

}
// Uncomment and edit the following lines to start using Grails encoding & escaping improvements

/* remove this line
// GSP settings
grails {
    views {
        gsp {
            encoding = 'UTF-8'
            htmlcodec = 'xml' // use xml escaping instead of HTML4 escaping
            codecs {
                expression = 'html' // escapes values inside null
                scriptlet = 'none' // escapes output from scriptlets in GSPs
                taglib = 'none' // escapes output from taglibs
                staticparts = 'none' // escapes output from static template parts
            }
        }
        // escapes all not-encoded output at final stage of outputting
        filteringCodecForContentType {
            //'text/html' = 'html'
        }
    }
}
remove this line */
