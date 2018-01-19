import ceylon.interop.browser.dom {
    document,
    EventListener,
    Event
}

import keycloak_2_oauth.common {
    authServerUrl,
    realm,
    clientId
}

"Run the module `openshift_client_javascript`."
shared void run(Boolean useFabric8Auth) {
    assert (exists root = document.body);
    
    value script = document.createElement("script");
    dynamic {
        dynamic dynaScript = script;
        dynaScript.async = true;
        dynaScript.src = if (useFabric8Auth) then "OIDCKeycloak.js" else "``authServerUrl``/js/keycloak.js";
    }
    script.addEventListener("error", object satisfies EventListener { 
        shared actual void handleEvent(Event event) {
            dynamic  { alert("Error loading script."); }
        }
    });
    script.addEventListener("abort", object satisfies EventListener { 
         shared actual void handleEvent(Event event) {
             dynamic  { alert("Script loading aborted."); }
         }
    });
    script.addEventListener("load", object satisfies EventListener { 
        shared actual void handleEvent(Event event) {
            dynamic {
                dynamic keycloak = Keycloak(
                    if (!useFabric8Auth)
                    then dynamic [
                        url=authServerUrl;
                        realm=realm;
                        clientId=clientId(useFabric8Auth);
                    ]
                    else dynamic [
                        oidcProvider = "http://localhost:8089/api";
                        clientId=clientId(useFabric8Auth);
                    ]);
                keycloak.init(dynamic [
                        onLoad="login-required";
                        checkLoginIframe=false;
                        responseMode = "query";
                        useNonce=!useFabric8Auth;
                    ]).success(() {
                    eval("window")._keycloak = keycloak;
                    void doWithUpdatedKeycloak(void action(String updatedToken)) {
                        keycloak.updateToken(5).success(() {
                            action(keycloak.token);
                        }).error(() {
                            console.log("token refresh failed :", config.url);
                            keycloak.login();
                        });
                    }
                    mountRoot(root, doWithUpdatedKeycloak);
                });
            }
        }
    });
    
    document.head?.appendChild(script);
}