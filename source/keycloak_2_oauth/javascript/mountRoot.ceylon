import keycloak_2_oauth.common {
    operations
}
import ceylon.interop.browser.dom {
    HTMLElement
}
import ceylon.interop.browser {
    newXMLHttpRequest
}
import ceylon.language.meta.declaration {
    FunctionOrValueDeclaration
}
import herd.thrillon {
    event,
    ExistingWatchedValue,
    TextAreaValue,
    mount,
    Args,
    Template,
    SelectValue
}
import ceylon.html {
    Main,
    Button,
    Option,
    Select,
    Div,
    TextArea
}
void mountRoot(HTMLElement root, void doWithUpdatedKeycloak(void action(String updatedToken)) ) {
    mount(root, object satisfies Template {
        value input = TextAreaValue(ExistingWatchedValue<String>(""));
        value output = TextAreaValue(ExistingWatchedValue<String>(""));
        value operation = SelectValue(ExistingWatchedValue<String>(`value operations.getParsedJwtClaims`.name));

        build(Args attrs) =>
                Main {
                    Div {
                        TextArea {
                            rows = 30;
                            style = "width: 100%";
                            attributes = [ input.binder ];
                        }
                    },
                    Div {
                        Select {
                            attributes = [ operation.binder ];

                            for(op in `class operations`.declaredMemberDeclarations<FunctionOrValueDeclaration>())
                            Option { val = op.name; op.name}
                        },
                        Button {
                            attributes = [
                                event.click((evt) {
                                    doWithUpdatedKeycloak((String updatedToken) {
                                        value request = newXMLHttpRequest();

                                        request.open {
                                            method = "get";
                                            url = "/action/``operation.val +
                                            (if (input.val.trimmed.empty) then ""
                                            else "?" + input.val) ``";
                                        };
                                        request.setRequestHeader("Authorization", "Bearer ``updatedToken``");
                                        dynamic { console.log("submitting request", request); }
                                        request.send();
                                        output.val = request.responseText;
                                    });
                                })
                            ];
                            "Call"
                        },
                        Button {
                            attributes = [
                                event.click((evt) {
                                    dynamic {
                                        eval("window")._keycloak.logout();
                                    }
                                })
                            ];
                            "Logout"
                        }
                    },
                    Div {
                        TextArea {
                            rows = 30;
                            style = "width: 100%";
                            contentEditable = false;
                            disabled = true;
                            attributes = [ output.binder ];
                        }
                    }
                };
    });
}
