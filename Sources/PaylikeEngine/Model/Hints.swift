/**
 * Used when hints are gathered from the webview window during TDS Flow. It is needed to define a
 * deserializer for the Json format.
 */
internal struct Hints : Decodable {
    var hints = [String]()
}
