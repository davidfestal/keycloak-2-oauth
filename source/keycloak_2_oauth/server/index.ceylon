import ceylon.html {
    ...
}

Html index(Boolean oauth2) => Html {
    Head {
        Meta { charset = "utf-8"; },
        Script { src = "require.js"; }
    },
    Body {
        Script {
            type = "text/javascript";
            "require.config({
                 baseUrl : 'modules/',
                 paths: {
                     'mithril/1.1.6/mithril-1.1.6': '../node_modules/mithril/mithril.min'
                 }
             });

             require(['keycloak_2_oauth/javascript/1.0.0/keycloak_2_oauth.javascript-1.0.0'],
                 function(entryPoint) {
                     entryPoint.run(`` oauth2 ``);
                 });"
        }
    }
};
