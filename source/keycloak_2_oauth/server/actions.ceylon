import io.jsonwebtoken {
    Claims
}
import ceylon.http.server {
    Request,
    Response
}

void getParsedJwtClaims(Request req, Response res) {
    if (is Claims claims = req.session.get(jwtTokenParam)) {
        res.writeString(claims.string);
    } else {
        res.writeString("No Jwt Claims !");
    }
}

