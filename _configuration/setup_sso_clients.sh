#!/bin/bash

# author: rabreu@redhat.com
# description: Red Hat Single Sign-On lab configuration
# https://github.com/aelkz/ocp-sso

# usage example:
# $1 - Red Hat Single Sign-On namespace
# $2 - Red Hat Single Sign-On secure route name
# $3 - Openshift wildcard domain
# $4 - Red Hat Single Sign-On master username
# $5 - Red Hat Single Sign-On master password
# ./setup_ssh.sh sso74 ntier secure-sso app.mydomain.com admin admin

function setup_rhsso() {
	local RHSSO_NAMESPACE=$1
  local APP_NAMESPACE=$2
	local RHSSO_ROUTE=$3
	local OCP_WILDCARD_DOMAIN=$4
	local SSO_URL=$(oc get route ${RHSSO_ROUTE} -n ${RHSSO_NAMESPACE} --template='{{ .spec.host }}')
	local SSO_REALM=NTIER
	local SSO_AUTH_URL=https://${SSO_URL}/auth
	local SSO_MASTER_TOKEN_URL=https://${SSO_URL}/auth/realms/master/protocol/openid-connect/token
	local SSO_TOKEN_URL=https://${SSO_URL}/auth/realms/${SSO_REALM}/protocol/openid-connect/token
	local SSO_REALM_KEYS_URL=https://${SSO_URL}/auth/admin/realms/${SSO_REALM}/keys
	local SSO_REALM_USERNAME=$5
	local SSO_REALM_PASSWORD=$6

	local TKN=$(curl -v -k -X POST $SSO_TOKEN_URL \
	 -H "Content-Type: application/x-www-form-urlencoded" \
	 -d "username=$SSO_REALM_USERNAME" \
	 -d "password=$SSO_REALM_PASSWORD" \
	 -d "grant_type=password" \
	 -d "client_id=admin-cli" \
	 | sed 's/.*access_token":"//g' | sed 's/".*//g')

	# create js client at NTIER realm
  local CLIENT_ID=js
  local APP_NAME=nodejs-app
	local APPLICATION_ADMIN_URI=https://$APP_NAME-$APP_NAMESPACE.$OCP_WILDCARD_DOMAIN
	local APPLICATION_REDIRECT_URI=https://$APP_NAME-$APP_NAMESPACE.$OCP_WILDCARD_DOMAIN/*

	curl -v -k -X POST https://$SSO_URL/auth/admin/realms/$SSO_REALM/clients \
	-H "Accept: application/json" \
	-H "Content-Type: application/json;charset=UTF-8" \
	-H "Authorization: Bearer $TKN" \
	--data '{"enabled":true,"attributes":{},"clientId":"'$CLIENT_ID'","protocol":"openid-connect","adminUrl":"'$APPLICATION_ADMIN_URI'","baseUrl":"'$APPLICATION_ADMIN_URI'","publicClient":true,"consentRequired":true,"fullScopeAllowed":true,"redirectUris":["'$APPLICATION_REDIRECT_URI'"],"webOrigins":["+"]}'

	# create java client at NTIER realm
  local CLIENT_ID=java
  local APP_NAME=springboot-app
	local APPLICATION_ADMIN_URI=https://$APP_NAME-$APP_NAMESPACE.$OCP_WILDCARD_DOMAIN
	local APPLICATION_REDIRECT_URI=https://$APP_NAME-$APP_NAMESPACE.$OCP_WILDCARD_DOMAIN/*

	curl -v -k -X POST https://$SSO_URL/auth/admin/realms/$SSO_REALM/clients \
	-H "Accept: application/json" \
	-H "Content-Type: application/json;charset=UTF-8" \
	-H "Authorization: Bearer $TKN" \
	--data '{"enabled":true,"attributes":{},"clientId":"'$CLIENT_ID'","protocol":"openid-connect","adminUrl":"'$APPLICATION_ADMIN_URI'","baseUrl":"'$APPLICATION_ADMIN_URI'","secret":"bce5816d-98c4-404f-a18d-bcc5cb005c79","bearerOnly":true,"publicClient":false,"consentRequired":true,"fullScopeAllowed":true,"redirectUris":["'$APPLICATION_REDIRECT_URI'"],"webOrigins":["+"]}'
}

setup_rhsso $1 $2 $3 $4 $5 $6
