#!/bin/bash

# author: rabreu@redhat.com
# description: Red Hat Single Sign-On realm public key extractor
# https://github.com/aelkz/jee-datagrid

# usage example:
# $1 - Red Hat Single Sign-On namespace
# $2 - Red Hat Single Sign-On secure route name
# $3 - Openshift wildcard domain
# $4 - Red Hat Single Sign-On master username
# $5 - Red Hat Single Sign-On master password
# ./setup_ssh.sh sso74 secure-sso app.mydomain.com

function setup_rhsso() {
	local RHSSO_NAMESPACE=$1
	local RHSSO_ROUTE=$2
	local OCP_WILDCARD_DOMAIN=$3
	local SSO_URL=$(oc get route ${RHSSO_ROUTE} -n ${RHSSO_NAMESPACE} --template='{{ .spec.host }}')
	local SSO_REALM=lab
	local SSO_AUTH_URL=https://${SSO_URL}/auth
	local SSO_MASTER_TOKEN_URL=https://${SSO_URL}/auth/realms/master/protocol/openid-connect/token
	local SSO_TOKEN_URL=https://${SSO_URL}/auth/realms/${SSO_REALM}/protocol/openid-connect/token
	local SSO_REALM_KEYS_URL=https://${SSO_URL}/auth/admin/realms/${SSO_REALM}/keys
	local SSO_REALM_USERNAME=admin
	local SSO_REALM_PASSWORD=12345

	local TKN=$(curl -v -k -X POST $SSO_TOKEN_URL \
	 -H "Content-Type: application/x-www-form-urlencoded" \
	 -d "username=$SSO_REALM_USERNAME" \
	 -d "password=$SSO_REALM_PASSWORD" \
	 -d "grant_type=password" \
	 -d "client_id=admin-cli" \
	 | sed 's/.*access_token":"//g' | sed 's/".*//g')

  local RSA_PUB_KEY=$(curl -v -k -X GET $SSO_REALM_KEYS_URL \
  -H "Authorization: Bearer $TKN" \
  | jq -r '.keys[]  | select(.type=="RSA") | .publicKey' )

  oc set env dc/$APP_NAME --overwrite AUTH_REALM=$SSO_REALM
  oc set env dc/$APP_NAME --overwrite AUTH_URL=$SSO_AUTH_URL
  oc set env dc/$APP_NAME --overwrite AUTH_CLIENT_ID=$4
  oc set env dc/$APP_NAME --overwrite PUBLIC_KEY=$RSA_PUB_KEY
}

setup_rhsso $1 $2 $3 $4
