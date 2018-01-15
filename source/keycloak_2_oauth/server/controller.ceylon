import ceylon.http.client {
    get
}
import ceylon.http.server {
    Request,
    Response
}
import ceylon.json {
    JsonObject,
    parseJson=parse
}
import ceylon.uri {
    parseUri=parse
}

import io.jsonwebtoken {
    Claims,
    Jws,
    Jwts
}

import java.lang {
    JInteger=Integer,
    IllegalArgumentException
}
import java.security {
    SignatureException,
    NoSuchAlgorithmException,
    KeyFactory,
    PublicKey
}
import java.security.spec {
    InvalidKeySpecException,
    X509EncodedKeySpec
}
import java.text {
    DateFormat
}
import java.time {
    Instant
}
import java.util {
    Date,
    Base64
}

import keycloak_2_oauth.common {
    operations,
    realmUrl
}

void setupControllerOperations() {
    operations.getParsedJwtClaims = getParsedJwtClaims;
}

String keycloakTokenParam = "keycloakToken";
String jwtTokenParam = "jwtToken";

void controller(Request req, Response res) {
    try {
        value auth = req.header("Authorization");

        if (! exists auth) {
            res.writeString("No Auth");
            res.status = 403;
            return;
        }

        if (! auth.startsWith("Bearer ")) {
            res.writeString("No Bearer at start of the Auth token");
            res.status = 403;
            return;
        }

        value token = auth.spanFrom(7);
        print("token =``token``");
        req.session.put(keycloakTokenParam, token);

        variable Jws<Claims> jwt;
        try {
            jwt = Jwts.parser().setSigningKey(getJwtPublicKey()).parseClaimsJws(token);
            print("JWT = ``jwt``");
            print("issued at `` DateFormat.instance.format(jwt.body.issuedAt) ``");
            print("expires at `` DateFormat.instance.format(jwt.body.expiration) ``");
            value claims = jwt.body;
            req.session.put(jwtTokenParam, claims);
            value authTime = claims.get("auth_time", `JInteger`).longValue();
            print("auth_time at `` DateFormat.instance.format(Date.from(Instant.ofEpochSecond(authTime))) ``");
            //OK, we can trust this JWT
        } catch (SignatureException
        | NoSuchAlgorithmException
        | InvalidKeySpecException
        | IllegalArgumentException e) {
            //don't trust the JWT!
            print("Failed verifying the JWT token after public key update");
            res.writeString("Failed verifying the JWT token after public key update");
            res.status = 403;
            return;
        }
        if (exists action=req.pathParameter("action"),
            exists method = `\Ioperations`.getAttribute<\Ioperations, Anything(Nothing)?, Nothing>(action)?.bind(operations)?.get()) {
            if (is Anything(Request, Response) myMethod = method) {
                myMethod(req, res);
            }
        } else {
            res.writeString("Nothing to do");
        }
    } catch(Throwable e) {
        res.writeString(e.string);
    }
}

PublicKey? getJwtPublicKey() {
    String url = realmUrl();
    print("Pulling realm public key from URL : ``url``");
    value response = get(parseUri(url)).execute();
    try {
        if (is JsonObject realm = parseJson(response.contents),
            is String encodedPublicKey = realm.get("public_key")) {
            value decoded = Base64.decoder.decode(encodedPublicKey);
            value keySpec = X509EncodedKeySpec(decoded);
            value kf = KeyFactory.getInstance("RSA");
            return kf.generatePublic(keySpec);
        }
    } finally {
        response.close();
    }
    return null;
}
