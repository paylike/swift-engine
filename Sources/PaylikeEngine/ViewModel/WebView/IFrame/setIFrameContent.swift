import Foundation

/**
 *
 */
func setIFrameContent(to content: String) -> String {
    return """
    var iframe = document.getElementById('tdsiframe');
    iframe = iframe.contentWindow.document;
    iframe.open();
    iframe.write(window.b64Decoder('\(Data(content.utf8).base64EncodedString(options: Data.Base64EncodingOptions()))'));
    iframe.close();
    """
}
