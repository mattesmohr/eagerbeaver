/// A type that represents a html attribute.
public class HtmlAttribute {
    
    /// The name of the attribute.
    public var name: String
    
    /// The value of the attribute.
    public var value: String?
    
    /// Create an attribute.
    public init(name: String) {
        
        self.name = name
    }
    
    /// Maps an attribute node.
    internal convenience init(node: AttributeNode) {
        
        self.init(name: node.name)
        self.value = node.value
    }
    
    /// Renders an attribute node.
    internal func render() -> String {
        return " \(name)=\"\(value ?? "")\""
    }
}
