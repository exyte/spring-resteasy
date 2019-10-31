# XProgram webservice quick setup

## 1. Install Wildfly (JBoss)
Use following instruction to install and configure Wildfly (JBoss) 17.0.1.Final on Ubuntu 18.04 LTS: https://vitux.com/install-and-configure-wildfly-jboss-on-ubuntu/

## 2. Deploy spring-resteasy.war to the server
Following instructions contains information how to deploy [spring-resteasy.war](spring-resteasy.war) application on WildFly using the Web Console or the CLI: http://www.mastertheboss.com/jboss-server/jboss-deploy/deploying-applications-on-wildfly-using-the-web-console-and-the-cli

## 3. Configure program to execute
Copy _holidays.cbl_ and _xholidays.cbl_ into __/vagrant/cobol/webservices/xholidays__ folder on the server and compile them:
```
cd /vagrant/cobol/webservices/xholidays
. /opt/cobol-it4-64/bin/cobol-it-setup.sh
cobc -b xholidays.cbl holidays.cbl
```

In the __/vagrant/cobol/webservices/xholidays__ folder create __run.sh__ script with following content:
```
#!/bin/bash
export COBOLIT_LICENSE=/opt/cobol-it4-64/citlicense.xml
COBOLITDIR=/opt/cobol-it4-64
PATH=$COBOLITDIR/bin:${PATH}
LD_LIBRARY_PATH="$COBOLITDIR/lib:${LD_LIBRARY_PATH:=}"
DYLD_LIBRARY_PATH="$COBOLITDIR/lib:${DYLD_LIBRARY_PATH:=}"
SHLIB_PATH="$COBOLITDIR/lib:${SHLIB_PATH:=}"
LIBPATH="$COBOLITDIR/lib:${LIBPATH:=}"
COB="COBOL-IT"
COB_ERROR_FILE=/tmp/coberrplus
export COB_FILE_PATH=/tmp
export COB COBOLITDIR LD_LIBRARY_PATH PATH DYLD_LIBRARY_PATH SHLIB_PATH LIBPATH COB_ERROR_FILE
cobcrun xholidays
```

## 4. Make POST requests
Use cURL to make a POST request to http://localhost:8080/spring-resteasy/xprogram:
```
curl -X POST -H "Content-Type: text/plain" -d @getstring http://localhost:8080/spring-resteasy/xprogram
```

# Implementation details

All source code located in the [src/](src/) folder.

Following quickstart example is used as an initial project: 
https://github.com/wildfly/quickstart/tree/17.0.1.Final/spring-resteasy

There are 3 key files:
* [XProgramBean](src/main/java/org/jboss/as/quickstarts/resteasyspring/XProgramBean.java) executes configured command line program in the specified working directory and returns program execution output.
* [XProgramSpringResource](src/main/java/org/jboss/as/quickstarts/resteasyspring/XProgramSpringResource.java) process POST requests to the XProgram bean:
```java
@Autowired
XProgramBean xProgramBean;

@POST
@Path("xprogram")
@Consumes("text/plain")
@Produces("text/plain")
public Response postXProgram(String body) {
    String result = xProgramBean.process(body);
    return Response.ok(result).build();
}

@POST
@Path("/xprogram-form")
@Consumes(MediaType.APPLICATION_FORM_URLENCODED)
public Response postXProgramForm(@FormParam("msg") String msg) {
    String result = xProgramBean.process(msg);
    return Response.ok(result).build();
}
```
* [applicationContext.xml](src/main/webapp/WEB-INF/applicationContext.xml) where you can configure path to the executable script
```xml
<!-- XProgram bean -->
<bean id="xProgramBean" class="org.jboss.as.quickstarts.resteasyspring.XProgramBean">
    <!-- Program execution working directory -->
    <constructor-arg index="0" type="java.lang.String" value="/vagrant/cobol/webservices/xholidays" />
    <!-- Program to execute -->
    <constructor-arg index="1" type="java.lang.String" value="/vagrant/cobol/webservices/xholidays/run.sh" />
</bean>

<!-- JAX-RS XProgram resource -->
<bean id="xProgramSpringResource" class="org.jboss.as.quickstarts.resteasyspring.XProgramSpringResource" />
```


