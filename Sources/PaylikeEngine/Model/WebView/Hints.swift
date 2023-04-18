/**
 * Used when hints are gathered from the webview window during TDS Flow. It is needed to define a
 * deserializer for the Json format.
 */
public struct Hints : Decodable { // @TODO: make it internal
    public var hints = [String]() // @TODO: make it internal
}
