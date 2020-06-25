#!/bin/bash

# author: rabreu@redhat.com
# description: N-Tier configmap configuration
# https://github.com/aelkz/ocp-sso

# usage example:
# $1 - Red Hat Single Sign-On namespace
# $2 - Red Hat Single Sign-On secure route name
# $3 - Openshift wildcard domain
# $4 - Red Hat Single Sign-On n-tier realm admin username
# $5 - Red Hat Single Sign-On n-tier realm admin password
# ./setup_configmap.sh sso74 secure-sso app.mydomain.com admin 12345

function setup_rhsso() {
	local RHSSO_NAMESPACE=$1
	local RHSSO_ROUTE=$2
	local OCP_WILDCARD_DOMAIN=$3
	local SSO_URL=$(oc get route ${RHSSO_ROUTE} -n ${RHSSO_NAMESPACE} --template='{{ .spec.host }}')
	local SSO_REALM=NTIER
	local SSO_AUTH_URL=https://${SSO_URL}/auth
	local SSO_MASTER_TOKEN_URL=https://${SSO_URL}/auth/realms/master/protocol/openid-connect/token
	local SSO_TOKEN_URL=https://${SSO_URL}/auth/realms/${SSO_REALM}/protocol/openid-connect/token
	local SSO_REALM_KEYS_URL=https://${SSO_URL}/auth/admin/realms/${SSO_REALM}/keys
	local SSO_REALM_USERNAME=$4
	local SSO_REALM_PASSWORD=$5

	local TKN=$(curl -v -k -X POST $SSO_TOKEN_URL \
	 -H "Content-Type: application/x-www-form-urlencoded" \
	 -d "username=$SSO_REALM_USERNAME" \
	 -d "password=$SSO_REALM_PASSWORD" \
	 -d "grant_type=password" \
	 -d "client_id=admin-cli" \
	 | sed 's/.*access_token":"//g' | sed 's/".*//g')

  TKN=$(curl -v -k -X POST $SSO_TOKEN_URL \
   -H "Content-Type: application/x-www-form-urlencoded" \
   -d "username=$SSO_REALM_USERNAME" \
   -d "password=$SSO_REALM_PASSWORD" \
   -d "grant_type=password" \
   -d "client_id=admin-cli" \
   | sed 's/.*access_token":"//g' | sed 's/".*//g')

  RSA_PUB_KEY=$(curl -v -k -X GET $SSO_REALM_KEYS_URL \
   -H "Authorization: Bearer $TKN" \
   | jq -r '.keys[]  | select(.type=="RSA") | .publicKey' )

  oc create configmap ntier-config \
      --from-literal=AUTH_URL=${SSO_AUTH_URL} \
      --from-literal=KEYCLOAK=true \
      --from-literal=PUBLIC_KEY=${RSA_PUB_KEY} \
      --from-literal=REALM=${SSO_REALM} \
      --from-literal=PG_CONNECTION_URL=jdbc:postgresql:\/\/postgresql\/jboss \
      --from-literal=PG_DATABASE=jboss \
      --from-literal=PG_USERNAME=pguser \
      --from-literal=PG_PASSWORD=pgpass
}

setup_rhsso $1 $2 $3 $4 $5
