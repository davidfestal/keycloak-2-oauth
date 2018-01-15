suppressWarnings("packageName")
native("jvm")
module keycloak_2_oauth.server "1.0.0" {
    import java.base "8";
    import ceylon.http.server "1.3.3";
    import maven:io.jsonwebtoken:"jjwt" "0.7.0";
    import ceylon.interop.java "1.3.3";
    import ceylon.http.client "1.3.3";
    import ceylon.json "1.3.3";
    import keycloak_2_oauth.common "1.0.0";
    import ceylon.html "1.3.3";
}
