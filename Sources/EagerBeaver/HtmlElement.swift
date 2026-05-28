/// A html element
public class HtmlElement {
    
    /// The different kind of elements
    public enum ElementKind {
        
        case text
        case comment
        case element
    }
    
    /// The name of the element
    public var name: String?
    
    /// The name of the element
    public var value: String?
    
    /// The element attributes
    public var attributes: [HtmlAttribute]?
    
    /// The kind of the element
    public var kind: ElementKind
    
    public var level: Int
    
    /// The content of the element
    public var children: [HtmlElement]?
    
    /// Creates a element
    public init(kind: ElementKind, level: Int) {
        
        self.kind = kind
        self.level = level
    }
    
    /// Maps a element node
    internal convenience init(node: ElementNode, level: Int) {
        
        self.init(kind: .element, level: level)
        self.name = node.name
        
        if let children = node.children {
            
            for child in children {
                
                if let comment = child as? CommentNode {
                    self.add(child: HtmlElement(node: comment, level: (level + 1)))
                }
                
                if let element = child as? ElementNode {
                    self.add(child: HtmlElement(node: element, level: (level + 1)))
                }
                
                if let text = child as? TextNode {
                    self.add(child: HtmlElement(node: text, level: (level + 1)))
                }
            }
        }
        
        if let attributes = node.attributes {
            
            for attribute in attributes {
                self.add(attribute: HtmlAttribute(node: attribute))
            }
        }
    }
    
    /// Maps a comment node
    internal convenience init(node: CommentNode, level: Int) {
        
        self.init(kind: .comment, level: level)
        self.value = node.data
    }
    
    /// Maps a text node
    internal convenience init(node: TextNode, level: Int) {
        
        self.init(kind: .text, level: level)
        self.value = node.data
    }
    
    /// Adds content to the element
    internal func add(child: HtmlElement) {
        
        if var children = children {
            
            children.append(child)
            
            self.children = children
            
        } else {
            self.children = [child]
        }
    }
    
    /// Adds content to the element
    internal func add(attribute: HtmlAttribute) {
        
        if var attributes = attributes {
            
            attributes.append(attribute)
            
            self.attributes = attributes
            
        } else {
            self.attributes = [attribute]
        }
    }
    
    internal func render() -> String {
        
        var output = ""
        
        switch kind {
        case .comment:
            output += "<!--\(value ?? "")-->"
            
        case .element:
            
            output += "<\(name ?? "")"
            
            if let attributes = attributes {
                
                for attribute in attributes {
                    output += attribute.render()
                }
            }
            
            output += ">"
            
            if let children = children {
                
                for child in children {
                    output += child.render()
                }
            }
            
            output += "</\(name ?? "")>"
            
        case .text:
            output += "\(value ?? "")"
        }
        
        return output
    }
}
