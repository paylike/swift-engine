/**
 * Used when hints are gathered from the webview window during TDS Flow. It is needed to define a deserializer for the Json format.
 */
public struct Hints : Decodable {
    public var hints = [String]()
}
