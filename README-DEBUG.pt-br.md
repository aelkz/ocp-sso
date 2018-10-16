+-------------------------------------------+
sso/ocp-deploy-sso.sh
+-------------------------------------------+

--> Deploying template "openshift/sso72-x509-postgresql-persistent" to project ntier

     Red Hat Single Sign-On 7.2 + PostgreSQL (Persistent)
     ---------
     An example RH-SSO 7 application with a PostgreSQL database. For more information about using this template, see https://github.com/jboss-openshift/application-templates.

     A new persistent RH-SSO service (using PostgreSQL) has been created in your project. The admin username/password for accessing the master realm via the RH-SSO console is admin/Redhat1!. The username/password for accessing the PostgreSQL database "root" is useralp/mArXqLvR2naswmpBcfba0JX7L6A5vJWb. The HTTPS keystore used for serving secure content, the JGroups keystore used for securing JGroups communications, and server truststore used for securing RH-SSO requests were automatically created via OpenShift's service serving x509 certificate secrets.

     * With parameters:
        * Application Name=sso
        * JGroups Cluster Password=HErsntO8Vc3OEnpvpWMH2vIda2jHiA3t # generated
        * Database JNDI Name=java:jboss/datasources/KeycloakDS
        * Database Name=root
        * Datasource Minimum Pool Size=
        * Datasource Maximum Pool Size=
        * Datasource Transaction Isolation=
        * PostgreSQL Maximum number of connections=
        * PostgreSQL Shared Buffers=
        * Database Username=useralp # generated
        * Database Password=mArXqLvR2naswmpBcfba0JX7L6A5vJWb # generated
        * Database Volume Capacity=1Gi
        * ImageStream Namespace=openshift
        * RH-SSO Administrator Username=admin
        * RH-SSO Administrator Password=Redhat1!
        * RH-SSO Realm=java-js-realm
        * RH-SSO Service Username=
        * RH-SSO Service Password=
        * PostgreSQL Image Stream Tag=9.5
        * Container Memory Limit=1Gi

--> Creating resources ...
    service "sso" created
    service "sso-postgresql" created
    service "sso-ping" created
    route "sso" created
    deploymentconfig "sso" created
    deploymentconfig "sso-postgresql" created
    persistentvolumeclaim "sso-postgresql-claim" created
--> Success
    Access your application via route 'sso-ntier.192.168.42.90.nip.io' 
    Run 'oc status' to view your app.
configmap "ntier-config" created

+-------------------------------------------+
Java-js-realm : RSA : Public Key
+-------------------------------------------+

MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAkwu9htkApdJ3ZXviEVxhxua8iMmeNEu5ang7+TF+AzMSsTpOVGEEJSOv77AEq4h5C7mgSpt6y/rY6F+Z++H4JGJZ5JicOySxvdVNhreVtyEnTsD7mTWcSA/z4d/Wc60zvNGL/AJ5G9YwqtJUDBJP7ox8EeMaOjh6BgSqsOFV2RG9OgEcEhnjsv6R3j9Q4kMGKKtNaXlBniSPUBw3XaYSy35zw+AjIDLkp2geqxyUrm/XsbYe8ANP6vmYQs1OWp8Ii2jyrsfitr3lzoEa0ctM8T/awPOPS9Qe6mqaMxS7xLl7Vakn5xsds8SMWbibNMY7K4Zf3FY5sxMUPq1asLNcMQIDAQAB

+-------------------------------------------+
app : EAP Deployment
+-------------------------------------------+

root@local  /home/rabreu/Documents/_vps/_rh-sso/workshop/ocp-sso-master/eap  ./ocp-deploy-eap.sh

Now using project "ntier" on server "https://192.168.42.90:8443".
Creating postgresql database
--> Deploying template "openshift/postgresql-persistent" to project ntier

     PostgreSQL
     ---------
     PostgreSQL database service, with persistent storage. For more information about using this template, including OpenShift considerations, see https://github.com/sclorg/postgresql-container/.
     
     NOTE: Scaling to more than one replica is not supported. You must have persistent volumes available in your cluster to use this template.

     The following service(s) have been created in your project: postgresql.
     
            Username: pguser
            Password: pgpass
       Database Name: jboss
      Connection URL: postgresql://postgresql:5432/
     
     For more information about using this template, including OpenShift considerations, see https://github.com/sclorg/postgresql-container/.

     * With parameters:
        * Memory Limit=512Mi
        * Namespace=openshift
        * Database Service Name=postgresql
        * PostgreSQL Connection Username=pguser
        * PostgreSQL Connection Password=pgpass
        * PostgreSQL Database Name=jboss
        * Volume Capacity=1Gi
        * Version of PostgreSQL Image=9.5

--> Creating resources ...
    secret "postgresql" created
    service "postgresql" created
    persistentvolumeclaim "postgresql" created
    deploymentconfig "postgresql" created
--> Success
    Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
     'oc expose svc/postgresql' 
    Run 'oc status' to view your app.
deploymentconfig "postgresql" updated
Waiting for Postgresql to finish deploying before deploying EAP
--> Deploying template "openshift/eap71-basic-s2i" to project ntier

     JBoss EAP 7.1 (no https)
     ---------
     An example EAP 7 application. For more information about using this template, see https://github.com/jboss-openshift/application-templates.

     A new EAP 7 based application has been created in your project.

     * With parameters:
        * Application Name=eap-app
        * Custom http Route Hostname=
        * Git Repository URL=https://github.com/aelkz/ocp-sso
        * Git Reference=master
        * Context Directory=/eap
        * Queues=
        * Topics=
        * A-MQ cluster password=XhwvxyWB # generated
        * Github Webhook Secret=N0ACPvrJ # generated
        * Generic Webhook Secret=871WvEIh # generated
        * ImageStream Namespace=openshift
        * JGroups Cluster Password=tfX4fY0w # generated
        * Deploy Exploded Archives=false
        * Maven mirror URL=
        * Maven Additional Arguments=-Dcom.redhat.xpaas.repo.jbossorg
        * ARTIFACT_DIR=
        * MEMORY_LIMIT=1Gi

--> Creating resources ...
    service "eap-app" created
    service "eap-app-ping" created
    route "eap-app" created
    imagestream "eap-app" created
    buildconfig "eap-app" created
    deploymentconfig "eap-app" created
--> Success
    Access your application via route 'eap-app-ntier.192.168.42.90.nip.io' 
    Build scheduled, use 'oc logs -f bc/eap-app' to track its progress.
    Run 'oc status' to view your app.
deploymentconfig "eap-app" updated
deleting default http route
route.route.openshift.io "eap-app" deleted
route "eap-app" created

+-------------------------------------------+
app : Springboot Deployment
+-------------------------------------------+

root@local  /home/rabreu/Documents/_vps/_rh-sso/workshop/ocp-sso-master/springboot  ./ocp-deploy-springboot.sh

Already on project "ntier" on server "https://192.168.42.90:8443".
--> Deploying template "openshift/openjdk18-web-basic-s2i" to project ntier

     OpenJDK 8
     ---------
     An example Java application using OpenJDK 8. For more information about using this template, see https://github.com/jboss-openshift/application-templates.

     A new java application has been created in your project.

     * With parameters:
        * Application Name=springboot-app
        * Custom http Route Hostname=
        * Git Repository URL=https://github.com/aelkz/ocp-sso
        * Git Reference=master
        * Context Directory=/springboot
        * Github Webhook Secret=Du4UNvBm # generated
        * Generic Webhook Secret=vdQLWX8G # generated
        * ImageStream Namespace=openshift

--> Creating resources ...
    service "springboot-app" created
    route "springboot-app" created
    imagestream "springboot-app" created
    buildconfig "springboot-app" created
    deploymentconfig "springboot-app" created
--> Success
    Access your application via route 'springboot-app-ntier.192.168.42.90.nip.io' 
    Build scheduled, use 'oc logs -f bc/springboot-app' to track its progress.
    Run 'oc status' to view your app.
deploymentconfig "springboot-app" updated

+-------------------------------------------+
front-end app : NodeJS Deployment
+-------------------------------------------+

root@local  /home/rabreu/Documents/_vps/_rh-sso/workshop/ocp-sso-master/node  ./ocp-deploy-node.sh

Already on project "ntier" on server "https://192.168.42.90:8443".
--> Found image a603093 (6 days old) in image stream "openshift/nodejs" under tag "8" for "nodejs"

    Node.js 8 
    --------- 
    Node.js 8 available as container is a base platform for building and running various Node.js 8 applications and frameworks. Node.js is a platform built on Chrome's JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.

    Tags: builder, nodejs, nodejs8

    * The source repository appears to match: nodejs
    * A source build using source code from https://github.com/aelkz/ocp-sso will be created
      * The resulting image will be pushed to image stream "nodejs-app:latest"
      * Use 'start-build' to trigger a new build
    * This image will be deployed in deployment config "nodejs-app"
    * Port 8080/tcp will be load balanced by service "nodejs-app"
      * Other containers can access this service through the hostname "nodejs-app"

--> Creating resources ...
    imagestream "nodejs-app" created
    buildconfig "nodejs-app" created
    deploymentconfig "nodejs-app" created
    service "nodejs-app" created
--> Success
    Build scheduled, use 'oc logs -f bc/nodejs-app' to track its progress.
    Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
     'oc expose svc/nodejs-app' 
    Run 'oc status' to view your app.
route "nodejs-app" created
deploymentconfig "nodejs-app" updated
