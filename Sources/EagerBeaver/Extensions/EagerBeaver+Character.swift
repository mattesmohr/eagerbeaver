import Foundation

extension Character {
    
    internal var isAmpersand: Bool {
        
        if self == "&" {
            return true
        }
        
        return false
    }
    
    internal var isQuestionMark: Bool {
        
        if self == "?" {
            return true
        }
        
        return false
    }
    
    internal var isGreaterThanSign: Bool {
        
        if self == ">" {
            return true
        }
        
        return false
    }
    
    internal var isLessThanSign: Bool {
        
        if self == "<" {
            return true
        }
        
        return false
    }
    
    internal var isSolidus: Bool {
        
        if self == "/" {
            return true
        }
        
        return false
    }
    
    internal var isExclamationMark: Bool {
        
        if self == "!" {
            return true
        }
        
        return false
    }
    
    internal var isEqualSign: Bool {
        
        if self == "=" {
            return true
        }
        
        return false
    }
    
    internal var isApostrophe: Bool {
        
        if self == "'" {
            return true
        }
        
        return false
    }
    
    internal var isQuotationMark: Bool {
        
        if self == "\"" {
            return true
        }
        
        return false
    }
    
    internal var isHyphenMinus: Bool {
        
        if self == "-" {
            return true
        }
        
        return false
    }
    
    internal var isNumberSign: Bool {
        
        if self == "#" {
            return true
        }
        
        return false
    }
}
