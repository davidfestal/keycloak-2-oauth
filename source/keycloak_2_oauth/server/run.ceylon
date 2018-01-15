import ceylon.http.common {
    get
}
import ceylon.http.server {
    newServer,
    startsWith,
    AsynchronousEndpoint,
    Endpoint,
    template,
    endsWith,
    isRoot,
    equals
}
import ceylon.http.server.endpoints {
    serveStaticFile,
    RepositoryEndpoint
}
import ceylon.io {
    SocketAddress
}
import ceylon.html {
    Span,
    A,
    renderTemplate,
    Html,
    Body
}


"Run the main Http server."
shared void run() {
    setupControllerOperations();
    value server = newServer {
        RepositoryEndpoint("/modules"),
        AsynchronousEndpoint(
            startsWith("/node_modules"),
            serveStaticFile("."),
            {get}
        ),
        AsynchronousEndpoint(
            endsWith(".js"),
            serveStaticFile("js", (req) => req.path),
            {get}
        ),
        Endpoint(
            template("/action/{action}"),
            controller,
            {get}
        ),
        Endpoint(
            equals("/keycloak"),
            (req, res) => renderTemplate(
                index(false),
                res.writeString),
            {get}
        ),
        Endpoint(
            equals("/oauth2"),
                    (req, res) => renderTemplate(
                        index(true),
                        res.writeString),
            {get}
        ),
        Endpoint(
            isRoot(),
            (req, res) => renderTemplate(
                Html {
                    Body {
                        Span {
                            "Use either ",
                            A { href="/keycloak"; "Keycloak" },
                            " or ",
                            A { href="/oauth2"; "OAuth 2" }
                        }
                    }
                },
                res.writeString),
            {get}
        )
    };
        
    server.start(SocketAddress("0.0.0.0", 8080));
}

    