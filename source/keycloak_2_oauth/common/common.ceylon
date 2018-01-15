shared String authServerUrl = "https://sso.openshift.io/auth";
shared String realm = "fabric8";
shared String clientId = "openshiftio-public";

shared object operations {
    shared variable Anything(Nothing)? getParsedJwtClaims = null;
}

shared String realmUrl()
    => "``authServerUrl``/realms/``realm``";

