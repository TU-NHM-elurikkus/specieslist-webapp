dataSource {
    pooled = true
    logSql = false
    driverClassName = "com.mysql.jdbc.Driver"
    username = "root"
    password = ""
    dialect = org.hibernate.dialect.MySQL5InnoDBDialect
    dbCreate = "update"
    url = "jdbc:mysql://localhost:3306/specieslist?autoReconnect=true&connectTimeout=0"
    properties {
        maxActive = 50
        maxIdle = 25
        minIdle = 5
        initialSize = 5
        minEvictableIdleTimeMillis = 60000
        timeBetweenEvictionRunsMillis = 60000
        maxWait = 10000
        validationQuery = ""
        numTestsPerEvictionRun = 3
        testOnBorrow = true
        testWhileIdle = true
        testOnReturn = true
        validationQuery = ""
    }
}

hibernate {
    cache.use_second_level_cache = true
    cache.use_query_cache = false
    cache.region.factory_class = "net.sf.ehcache.hibernate.EhCacheRegionFactory"
}

// environment specific settings
environments {
    development {
        dataSource {

        }
    }
    test {
        dataSource {

        }
    }
    production {
        dataSource {

        }
    }
}
