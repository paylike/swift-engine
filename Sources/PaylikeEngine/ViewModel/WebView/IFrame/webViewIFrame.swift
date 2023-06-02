/**
 * Utility const to help the ThreeDS flow through the webView interactions.
 */
public let webViewIFrame =
"""
<!DOCTYPE html>
<html>
    <head>
        <style>
            body {
                height: 100%;
                width: 100%;
            }
            #iframe-div {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                display: flex;
                justify-content: center;
            }
            #tdsiframe {
                width: 100%;
                height: 100%;
            }
        </style>
    </head>
    <body>
        <div id="iframe-div">
            <iframe id="tdsiframe"></iframe>
        </div>
    </body>
    <script>
        if (!window.b64Decoder) {
            window.b64Decoder = (str) => decodeURIComponent(atob(str)
                .split("")
                .map((c) => "%" + ("00" + c.charCodeAt(0).toString(16)).slice(-2))
                .join("")
            );
        }
        function waitForHintsListener() {
            if (!window.webkit.messageHandlers.HintsListener) {
                setTimeout(waitForHintsListener, 1000);
                return;
            }
            window.webkit.messageHandlers.HintsListener.postMessage('isReady', "https://b.paylike.io/");
        }
        waitForHintsListener();
        window.addEventListener('message', function(e) {
            window.webkit.messageHandlers.HintsListener.postMessage(JSON.stringify(e.data), "https://b.paylike.io/");
        } );
    </script>
</html>
"""
