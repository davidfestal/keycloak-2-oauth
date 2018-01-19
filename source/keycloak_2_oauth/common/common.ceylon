shared String authServerUrl = "https://sso.prod-preview.openshift.io/auth";
shared String realm = "fabric8-test";
shared String clientId(Boolean useFabric8Auth) => if (useFabric8Auth) then "740650a2-9c44-4db5-b067-a3d1b2cd2d01" else "openshiftio-public";

shared object operations {
    shared variable Anything(Nothing)? getParsedJwtClaims = null;
}

shared String realmUrl()
    => "``authServerUrl``/realms/``realm``";

