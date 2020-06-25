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
# ./setup_ssh.sh sso74 secure-sso app.mydomain.com admin admin

function test_rhsso() {
	local RHSSO_NAMESPACE=$1
	local RHSSO_ROUTE=$2
	local OCP_WILDCARD_DOMAIN=$3
	local SSO_MASTER_REALM_USERNAME=$4
	local SSO_MASTER_REALM_PASSWORD=$5
	local SSO_URL=$(oc get route ${RHSSO_ROUTE} -n ${RHSSO_NAMESPACE} --template='{{ .spec.host }}')
	sleep 1
	local SSO_REALM=NTIER
	local SSO_AUTH_URL=https://${SSO_URL}/auth
	local SSO_MASTER_TOKEN_URL=https://${SSO_URL}/auth/realms/master/protocol/openid-connect/token
	local SSO_TOKEN_URL=https://${SSO_URL}/auth/realms/${SSO_REALM}/protocol/openid-connect/token
	local SSO_REALM_KEYS_URL=https://${SSO_URL}/auth/admin/realms/${SSO_REALM}/keys
	local SSO_REALM_USERNAME=admin
	local SSO_REALM_PASSWORD=12345

  echo "--------------------------------------------------"
	echo RHSSO_NAMESPACE=$RHSSO_NAMESPACE
	echo RHSSO_ROUTE=$RHSSO_ROUTE
	echo OCP_WILDCARD_DOMAIN=$OCP_WILDCARD_DOMAIN
	echo SSO_MASTER_REALM_USERNAME=$SSO_MASTER_REALM_USERNAME
	echo SSO_MASTER_REALM_PASSWORD=$SSO_MASTER_REALM_PASSWORD
	echo SSO_URL=$SSO_URL
	echo SSO_REALM=$SSO_REALM
	echo SSO_AUTH_URL=$SSO_AUTH_URL
	echo SSO_MASTER_TOKEN_URL=$SSO_MASTER_TOKEN_URL
	echo SSO_TOKEN_URL=$SSO_TOKEN_URL
	echo SSO_REALM_KEYS_URL=$SSO_REALM_KEYS_URL
	echo SSO_REALM_USERNAME=$SSO_REALM_USERNAME
	echo SSO_REALM_PASSWORD=$SSO_REALM_PASSWORD
  echo "--------------------------------------------------"

	MASTER_ADMIN_TKN=$(curl -v -k -X POST $SSO_MASTER_TOKEN_URL \
	 -H "Content-Type: application/x-www-form-urlencoded" \
	 -d "username=$SSO_MASTER_REALM_USERNAME" \
	 -d "password=$SSO_MASTER_REALM_PASSWORD" \
	 -d "grant_type=password" \
	 -d "client_id=admin-cli" \
	 | sed 's/.*access_token":"//g' | sed 's/".*//g')
}

function setup_rhsso() {
	local RHSSO_NAMESPACE=$1
	local RHSSO_ROUTE=$2
	local OCP_WILDCARD_DOMAIN=$3
	local SSO_MASTER_REALM_USERNAME=$4
	local SSO_MASTER_REALM_PASSWORD=$5

	local SSO_URL=$(oc get route ${RHSSO_ROUTE} -n ${RHSSO_NAMESPACE} --template='{{ .spec.host }}')
	local SSO_REALM=NTIER
	local SSO_AUTH_URL=https://${SSO_URL}/auth
	local SSO_MASTER_TOKEN_URL=https://${SSO_URL}/auth/realms/master/protocol/openid-connect/token
	local SSO_TOKEN_URL=https://${SSO_URL}/auth/realms/${SSO_REALM}/protocol/openid-connect/token
	local SSO_REALM_KEYS_URL=https://${SSO_URL}/auth/admin/realms/${SSO_REALM}/keys

	local SSO_REALM_USERNAME=admin
	local SSO_REALM_PASSWORD=12345

	local MASTER_ADMIN_TKN=$(curl -v -k -X POST $SSO_MASTER_TOKEN_URL \
	 -H "Content-Type: application/x-www-form-urlencoded" \
	 -d "username=$SSO_MASTER_REALM_USERNAME" \
	 -d "password=$SSO_MASTER_REALM_PASSWORD" \
	 -d "grant_type=password" \
	 -d "client_id=admin-cli" \
	 | sed 's/.*access_token":"//g' | sed 's/".*//g')

	 # create app realm
  curl -v -k -X POST $SSO_AUTH_URL/admin/realms \
	-H "Accept: application/json" \
	-H "Content-Type: application/json;charset=UTF-8" \
	-H "Authorization: Bearer $MASTER_ADMIN_TKN" \
	--data '{"enabled":true,"id":"'$SSO_REALM'","realm":"'$SSO_REALM'","userManagedAccessAllowed":false}'

	# create app realm admin user
	curl -v -k -X POST "https://$SSO_URL/auth/admin/realms/$SSO_REALM/users" \
	-H "Accept: application/json" \
	-H "Content-Type: application/json;charset=UTF-8" \
	-H "Authorization: Bearer $MASTER_ADMIN_TKN" \
	--data '{"enabled":true,"attributes":{},"emailVerified":true,"username":"'$SSO_REALM_USERNAME'","firstName":"'$SSO_REALM_USERNAME'"}'

	local USER_ID=$(curl -v -k -X GET "https://$SSO_URL/auth/admin/realms/$SSO_REALM/users?briefRepresentation=true&first=0&max=1&search=$SSO_REALM_USERNAME" \
	-H "Accept: application/json" \
	-H "Content-Type: application/json;charset=UTF-8" \
	-H "Authorization: Bearer $MASTER_ADMIN_TKN" \
	| jq -r '.[0].id')

	curl -v -k -X PUT "https://$SSO_URL/auth/admin/realms/$SSO_REALM/users/$USER_ID/reset-password" \
	-H "Accept: application/json" \
	-H "Content-Type: application/json;charset=UTF-8" \
	-H "Authorization: Bearer $MASTER_ADMIN_TKN" \
	--data '{"type":"password","value":"'$SSO_REALM_PASSWORD'","temporary":false}'

	local REALM_MANAGEMENT_CLIENT_ID=$(curl -v -k -X GET "https://$SSO_URL/auth/admin/realms/$SSO_REALM/clients?clientId=realm-management&first=0&max=1&search=true" \
	-H "Accept: application/json" \
	-H "Content-Type: application/json;charset=UTF-8" \
	-H "Authorization: Bearer $MASTER_ADMIN_TKN" \
	| jq -r '.[0].id')

	local REALM_MANAGEMENT_CLIENT_ROLES=$(curl -v -k -X GET "https://$SSO_URL/auth/admin/realms/$SSO_REALM/clients/$REALM_MANAGEMENT_CLIENT_ID/roles?first=0&max=20" \
	-H "Accept: application/json" \
	-H "Content-Type: application/json;charset=UTF-8" \
	-H "Authorization: Bearer $MASTER_ADMIN_TKN")

	curl -v -k -X POST https://$SSO_URL/auth/admin/realms/$SSO_REALM/users/$USER_ID/role-mappings/clients/$REALM_MANAGEMENT_CLIENT_ID \
	-H "Accept: application/json" \
	-H "Content-Type: application/json;charset=UTF-8" \
	-H "Authorization: Bearer $MASTER_ADMIN_TKN" \
	--data "$REALM_MANAGEMENT_CLIENT_ROLES"

	local TKN=$(curl -v -k -X POST $SSO_TOKEN_URL \
	 -H "Content-Type: application/x-www-form-urlencoded" \
	 -d "username=$SSO_REALM_USERNAME" \
	 -d "password=$SSO_REALM_PASSWORD" \
	 -d "grant_type=password" \
	 -d "client_id=admin-cli" \
	 | sed 's/.*access_token":"//g' | sed 's/".*//g')

	# create app realm user = alice
	local APP_USER=alice

	curl -v -k -X POST "https://$SSO_URL/auth/admin/realms/$SSO_REALM/users" \
	-H "Accept: application/json" \
	-H "Content-Type: application/json;charset=UTF-8" \
	-H "Authorization: Bearer $TKN" \
	--data '{"enabled":true,"attributes":{},"emailVerified":true,"username":"'$APP_USER'","email":"alice@keycloak.org","firstName":"Alice","lastName":"In Chains"}'

	local USER_ID=$(curl -v -k -X GET "https://$SSO_URL/auth/admin/realms/$SSO_REALM/users?briefRepresentation=true&first=0&max=1&search=$APP_USER" \
	-H "Accept: application/json" \
	-H "Content-Type: application/json;charset=UTF-8" \
	-H "Authorization: Bearer $TKN" \
	| jq -r '.[0].id')

	curl -v -k -X PUT "https://$SSO_URL/auth/admin/realms/$SSO_REALM/users/$USER_ID/reset-password" \
	-H "Accept: application/json" \
	-H "Content-Type: application/json;charset=UTF-8" \
	-H "Authorization: Bearer $TKN" \
	--data '{"type":"password","value":"'$APP_USER'","temporary":false}'
}

# test_rhsso $1 $2 $3 $4 $5
setup_rhsso $1 $2 $3 $4 $5
