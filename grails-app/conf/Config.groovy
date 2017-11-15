import grails.util.Environment
// from /commons/lib/
import com.nextdoor.rollbar.RollbarLog4jAppender


grails.project.groupId = "au.org.ala"

default_config = "/data/${appName}/config/${appName}-config.properties"
commons_config = "/data/commons/config/commons-config.properties"

grails.config.locations = [
    "file:${commons_config}",
    "file:${default_config}"
]

def prop = new Properties()
def rollbarServerKey = ""

// Load rollbar key from commons config file.
try {
    File fileLocation = new File(commons_config)
    prop.load(new FileInputStream(fileLocation))
    rollbarServerKey = prop.getProperty("rollbar.postServerKey") ?: ""
} catch(IOException e) {
    // e.printStackTrace()
}

if(!new File(default_config).exists()) {
    println "ERROR - [${appName}] No external configuration file defined. ${default_config}"
}
if(!new File(commons_config).exists()) {
    println "ERROR - [${appName}] No external commons configuration file defined. ${commons_config}"
}
if(rollbarServerKey.isEmpty()) {
    println "ERROR - [${appName}] No Rollbar key."
}

println "[${appName}] (*) grails.config.locations = ${grails.config.locations}"

bie.nameIndexLocation = "/data/lucene/namematching"
registryApiKey = "xxxxxxxxxxxxxxxxxx"
bieApiKey = "xxxxxx"

rollbar.postApiKey = "xxx"  // This should be set in the external config file

/*** Config specific for species list ***/
updateUserDetailsOnStartup = false

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


def logging_dir = System.getProperty("catalina.base") ? System.getProperty("catalina.base") + "/logs"  : "/var/log/tomcat7"
if(!new File(logging_dir).exists()) {
    logging_dir = "/tmp"
}

println "INFO - [${appName}] logging_dir: ${logging_dir}"

log4j = {
    def logPattern = pattern(conversionPattern: "%d %-5p [%c{1}] %m%n")

    def rollbarAppender = new RollbarLog4jAppender(
        name: "rollbar",
        layout: logPattern,
        threshold: org.apache.log4j.Level.ERROR,
        environment: Environment.current.name,
        accessToken: rollbarServerKey
    )

    def tomcatLogAppender = rollingFile(
        name: "tomcatLog",
        maxFileSize: "10MB",
        file: "${logging_dir}/specieslist.log",
        threshold: org.apache.log4j.Level.WARN,
        layout: logPattern
    )

    appenders {
        environments {
            production {
                appender(tomcatLogAppender)
                appender(rollbarAppender)
            }
            test {
                appender(tomcatLogAppender)
                appender(rollbarAppender)
            }
            development {
                console(
                    name: "stdout",
                    layout: logPattern,
                    threshold: org.apache.log4j.Level.DEBUG)
            }
        }
    }

    root {
        error "tomcatLog", "rollbar"
        warn "tomcatLog"
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
