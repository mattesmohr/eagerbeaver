/// The parser for the tree construction
internal class Parser {
    
    /// A enumeration of possible errors
    internal enum Error: Swift.Error {
        
        case missingBodyTag
        case missingHeadTag
        case missingHtmlTag
        case missingDoctypeTag
        case invalidToken
        case invalidTag
    
        internal var description: String {
            
            switch self {
            case .missingBodyTag:
                return "Missing body tag"
                
            case .missingHeadTag:
                return "Missing head tag"
                
            case .missingHtmlTag:
                return "Missing html tag"
                
            case .missingDoctypeTag:
                return "Missing doctype tag"
                
            case .invalidToken:
                return "Invalid token"
                
            case .invalidTag:
                return "Invalid tag"
            }
        }
    }
   
    /// A enumeration of different states of the parser
    internal enum InsertionMode {
        
        case initial
        case beforehtml
        case beforehead
        case inhead
        case afterhead
        case inbody
        case text
        case afterbody
    }
    
    /// A enumeration of different level of the logging
    ///
    /// None is the initial state.
    internal enum LogLevel {
        
        case none
        case information
        case debug
    }
    
    /// The tree with nodes
    private var tree: [HtmlNode]
    
    /// The collection of nodes
    private var nodes: [ElementNode]
    
    /// The  state of the tokenizer
    private var mode: InsertionMode
    
    /// The level of logging
    private var level: LogLevel
    
    /// An enumeration of voids
    private var voids: [String] {
        return [
            "area",
            "base",
            "br",
            "col",
            "embed",
            "hr",
            "img",
            "input",
            "link",
            "meta",
            "param",
            "source",
            "track",
            "wbr"
        ]
    }
    
    /// Creates a parser
    internal init(mode: InsertionMode = .initial, log level: LogLevel = .none) {
        
        self.tree = []
        self.nodes = []
        self.mode = mode
        self.level = level
    }
    
    /// Logs the steps of the tokenizer depending on the log level
    private func log(_ message: Any...) {
        
        switch self.level {
        case .information:
            print("Message:", message)
            
        default:
            break
        }
    }
    
    /// Inserts the node into the tree
    private func insert(node: HtmlNode) {
        
        self.log(#function)
        
        self.tree.append(node)
    }
    
    /// View the last node.
    private func peek() -> ElementNode? {
        
        self.log(#function)
        
        return self.nodes.last
    }
    
    /// Pops the last node.
    private func pop() {
    
        self.log(#function)
        
        let last = self.nodes.removeLast()
        
        if let penultimate = self.nodes.last {
            penultimate.add(child: last)
            
        } else {
            self.insert(node: last)
        }
    }
    
    /// Processes the content by the mode the parser is currently in
    internal func process(_ tokens: [HtmlToken]) throws -> [HtmlNode] {
        
        self.log(#function)
        
        for token in tokens {
            
            switch self.mode {
            case .beforehtml:
                self.mode = try processBeforeHtml(token)
                
            case .beforehead:
                self.mode = try processBeforeHead(token)
                
            case .inhead:
                self.mode = try processInHead(token)
                
            case .afterhead:
                self.mode = try processAfterHead(token)
                
            case .inbody:
                self.mode = try processInBody(token)
                
            case .text:
                self.mode = try processText(token)
                
            case .afterbody:
                self.mode = try processAfterBody(token)
                
            default:
                self.mode = try processInitial(token)
            }
        }
        
        return self.tree
    }
    
    /// Processes the token
    private func processInitial(_ token: HtmlToken) throws -> InsertionMode {
        
        self.log(#function, token)
        
        if let document = token as? DocumentToken {
            
            self.insert(node: DefinitionNode(token: document))
            
            return .beforehtml
        }
        
        throw Error.invalidToken
    }
    
    /// Processes the token
    private func processBeforeHtml(_ token: HtmlToken) throws -> InsertionMode {
        
        self.log(#function, token)
        
        if let tag = token as? TagToken {

            if tag.name == "html" {
                
                switch tag.kind {
                case .start:
                    self.nodes.append(ElementNode(token: tag))
                    
                case .end:
                    throw Error.invalidTag
                }
                
            } else {
                throw Error.missingHtmlTag
            }
            
            return .beforehead
        }
        
        throw Error.invalidToken
    }
    
    /// Processes the token
    private func processBeforeHead(_ token: HtmlToken) throws -> InsertionMode {
        
        self.log(#function, token)
        
        if let tag = token as? TagToken {
        
            if tag.name == "head" {
                
                switch tag.kind {
                case .start:
                    self.nodes.append(ElementNode(token: tag))
                    
                case .end:
                    throw Error.invalidTag
                }
                
            } else {
               throw Error.missingHeadTag
            }
            
            return .inhead
        }
        
        if let attribute = token as? AttributeToken {
            
            if let last = self.nodes.last {
                last.add(attribute: AttributeNode(token: attribute))
            }
            
            return .beforehead
        }
        
        throw Error.invalidToken
    }
    
    /// Processes the token
    private func processInHead(_ token: HtmlToken) throws -> InsertionMode {
        
        self.log(#function, token)
        
        if let comment = token as? CommentToken {
            
            if let last = self.nodes.last {
                last.add(child: CommentNode(token: comment))
            }
            
            return .inhead
        }
        
        if let tag = token as? TagToken {
            
            switch tag.kind {
            case .start:
                
                if let last = peek() {
                    
                    if self.voids.contains(last.name) {
                        self.pop()
                    }
                }
                
                self.nodes.append(ElementNode(token: tag))
                
            case .end:
                
                if let last = peek() {
                    
                    if self.voids.contains(last.name) {
                        self.pop()
                    }
                }

                self.pop()
                
                if tag.name == "head" {
                    return .afterhead
                }
            }
            
            return .inhead
        }
        
        if let text = token as? TextToken {
            
            if let last = self.nodes.last {
                last.add(child: TextNode(token: text))
            }
            
            return .inhead
        }
        
        if let attribute = token as? AttributeToken {
            
            if let last = self.nodes.last {
                last.add(attribute: AttributeNode(token: attribute))
            }
            
            return .inhead
        }
        
        throw Error.invalidToken
    }
    
    /// Processes the token
    private func processAfterHead(_ token: HtmlToken) throws -> InsertionMode {
        
        self.log(#function, token)
        
        if let comment = token as? CommentToken {
            
            if let last = self.nodes.last {
                last.add(child: CommentNode(token: comment))
            }
            
            return .afterhead
        }
        
        if let text = token as? TextToken {
            
            if let last = self.nodes.last {
                last.add(child: TextNode(token: text))
            }
            
            return .afterhead
        }
        
        if let tag = token as? TagToken {
            
            if tag.name == "body" {
                
                switch tag.kind {
                case .start:
                    self.nodes.append(ElementNode(token: tag))
                    
                case .end:
                    throw Error.invalidTag
                }
                
            } else {
               throw Error.missingBodyTag
            }

            return .inbody
        }
        
        if let attribute = token as? AttributeToken {
            
            if let last = self.nodes.last {
                last.add(attribute: AttributeNode(token: attribute))
            }
            
            return .afterhead
        }
        
        throw Error.invalidToken
    }
    
    /// Processes the token
    private func processInBody(_ token: HtmlToken) throws -> InsertionMode {
        
        self.log(#function, token)
        
        if let comment = token as? CommentToken {
            
            if let last = self.nodes.last {
                last.add(child: CommentNode(token: comment))
            }
            
            return .inbody
        }
                
        if let text = token as? TextToken {
            
            if let last = self.nodes.last {
                last.add(child: TextNode(token: text))
            }
            
            return .inbody
        }
        
        if let tag = token as? TagToken {
            
            switch tag.kind {
            case .start:
                
                if let last = peek() {
                    
                    if self.voids.contains(last.name) {
                        self.pop()
                    }
                }
                
                self.nodes.append(ElementNode(token: tag))
                
            case .end:
                
                if let last = peek() {
                    
                    if self.voids.contains(last.name) {
                        self.pop()
                    }
                }

                self.pop()
                
                if tag.name == "body" {
                    return .afterbody
                }
            }
            
            return .inbody
        }
        
        if let attribute = token as? AttributeToken {
            
            if let last = self.nodes.last {
                last.add(attribute: AttributeNode(token: attribute))
            }
            
            return .inbody
        }
        
        throw Error.invalidToken
    }
    
    /// Processes the token
    private func processText(_ token: HtmlToken) throws -> InsertionMode {
        
        self.log(#function, token)
        
        return .text
    }
    
    /// Processes the token
    private func processAfterBody(_ token: HtmlToken) throws -> InsertionMode {
        
        self.log(#function, token)
        
        if let comment = token as? CommentToken {
            
            if let last = self.nodes.last {
                last.add(child: CommentNode(token: comment))
            }
            
            return .afterbody
        }
                
        if let tag = token as? TagToken {
            
            if tag.name == "html" {
                
                switch tag.kind {
                case .start:
                    throw Error.invalidTag
                    
                case .end:
                    self.pop()
                }
                
            } else {
                throw Error.missingHtmlTag
            }
            
            return .afterbody
        }
        
        throw Error.invalidToken
    }
}
