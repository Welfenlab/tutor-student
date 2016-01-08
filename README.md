# Tutor Student Web Interface

This is the student web interface for tutor.

## Installation

For production please see [tutor-docker-student](https://github.com/Welfenlab/tutor-docker-student)

If you want to try the web interface please consider using the [tutor meta package](https://github.com/Welfenlab/Tutor). It contains a
complete example setup.

In order to install this you have first install all dependencies via NPM and Bower, run:

```
npm install
bower install
```

After this you have to build the web app via `gulp`.

You will need a RethinkDB instance running and configured in `config.cson`.

## Configuration

By default starting the server via `node index.js` will load the `config.cson` in the CWD. If you
want to use a different configuration pass the configuration file as the first argument `node index.js myconfig.cson`

The config contains the following parts:

```cson
# Use this configuration for the development.
# Deployment will replace it with an appropriate one
# domainname: SET VIA TUTOR_DOMAIN_NAME
database:
#  host : database host name. [SET VIA DOCKER LINK ENV RETHINKDB_PORT_28015_TCP_ADDR]
#  port : database port. [SET VIA DOCKER LINK ENV RETHINKDB_PORT_28015_TCP_PORT]
# Table name
  name : "TutorDB"
session:
#  secret: the session secret to store them persistent in the DB and on the users browser. [SET VIA TUTOR_SESSION_SECRET]
  restrict: "/api"
saml:
#  privateKey: Local PK for SAML authentification. [SET VIA TUTOR_SAML_KEY]
#  certificate: Local cert for SAML authentification. SET VIA TUTOR_SAML_CERT
# Path to the SAML metadata.xml
  entityPath: ''
# Where the SAML server should forward the user to, if the login was successful.
  assertEndpoint: '/Shibboleth.sso/SAML2/POST'
#  idpLoginUrl: Login URL for the IDP. [SET VIA TUTOR_IDP_LOGIN_URL] 
#  idpCertificate: Certificate of the IDP. [SET VIA TUTOR_IDP_CERT]
```

The parts in squared brackets are the environment variables for production. In production the
sensitive parts of the configuration come via environment variables and are not stored in the
configuration file. 

## Structure

This repository contains the server and the frontend component. You find the front end code in 'app/`. The
server resides in `src/` and in the `index.js`. The gulpfile will create a `build/` folder that is used for
delivering files.

## Development

You should definitely start with the [tutor meta package](https://github.com/Welfenlab/Tutor) if you want to start
developing for tutor. Most of the internals are done in other packages like markdown processing etc.

For UI development you can start the watch task in gulp to auto compile new files.

```
gulp watch
```

