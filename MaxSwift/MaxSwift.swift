//
//  MaxSwift.swift
//  cmidi
//
//  Created by Joseph Mattiello on 8/6/16.
//
//

import Foundation
import Max.Max

struct Outlet {
    let name : String
}

struct Inlet {
    let name : String
}

public enum MaxWord {
    case Nothing
    case Long(Int64)
    case FloatingPoint(Double)
    case Symbol(symbol)
    case Object(object)
    case Unknown

    public init(withAtom atom : t_atom) {
        let type : e_max_atomtypes = e_max_atomtypes(rawValue: UInt32(atom.a_type))
        
        switch type {
        case A_NOTHING:
            self = .Nothing
        case A_LONG:
            self = .Long(atom.a_w.w_long)
        case A_FLOAT:
            self = .FloatingPoint(atom.a_w.w_float)
        case A_SYM:
            self = .Symbol(atom.a_w.w_sym.memory)
        case A_OBJ:
            self = .Object(atom.a_w.w_obj.memory)
        // TODO: Finish these
        default:
            // TODO: Shouyld make nullable init and return nil?
            self = .Unknown
        }
    }
}

extension MaxWord : CustomStringConvertible {
    public var description : String {
        /*
         A_NOTHING = 0,	///< no type, thus no atom
         A_LONG,			///< long integer
         A_FLOAT,		///< 32-bit float
         A_SYM,			///< t_symbol pointer
         A_OBJ,			///< t_object pointer (for argtype lists; passes the value of sym)
         A_DEFLONG,		///< long but defaults to zero
         A_DEFFLOAT,		///< float, but defaults to zero
         A_DEFSYM,		///< symbol, defaults to ""
         A_GIMME,		///< request that args be passed as an array, the routine will check the types itself.
         A_CANT,			///< cannot typecheck args
         A_SEMI,			///< semicolon
         A_COMMA,		///< comma
         A_DOLLAR,		///< dollar
         A_DOLLSYM,		///< dollar
         A_GIMMEBACK,	///< request that args be passed as an array, the routine will check the types itself. can return atom value in final atom ptr arg. function returns long error code 0 = no err. see gimmeback_meth typedef
         
         */
        
        switch self {
        case .Nothing:
            return "nothing"
        case .Long(let value):
            return "long : \(value)"
        case .FloatingPoint(let value):
            return "float : \(value)"
        case .Symbol(let symbol):
            return "symbol : \(symbol.description)"
        case .Object(let object):
            return "object : \(object)"
        case .Unknown:
            return "unknown"
            // TODO: Finish these
        }
    }
}

//extension object : CustomStringConvertible {
    //public var description : String {
        //let messlist = self.o_messlist
        //let inlet    = self.o_inlet
        //let outlet   = self.o_outlet
        
        //return "\(self.s_name) \(self.s_thing)"
    //}
//}

extension symbol : CustomStringConvertible {
    public var description : String {
        let name = String(UTF8String: s_name)
        return "\(name ?? "") \(self.s_thing)"
    }
}

// We wrap the Atom instead of using MaxWord directly with associated values so that
// we can pass the t_atom in an array from C/Obj-C to Swift.
@objc public class MaxAtom : NSObject {
    public let atom : t_atom
    public let value : MaxWord
    
    public lazy var type : e_max_atomtypes = {
       e_max_atomtypes(rawValue: UInt32(self.atom.a_type))
    }()
    
    // TODO: Value is a union struct. Have to use the type to determine the value casting
    // May be best to use a enum with associated values
    
    required public init(withAtom atom : t_atom) {
        self.atom = atom
        self.value = MaxWord(withAtom: atom)
        super.init()
    }
    
    public override var description : String {
        return "Atom {\(value)}"
    }
}

extension e_max_atomtypes : CustomStringConvertible {
    public var description : String {
        /*
         A_NOTHING = 0,	///< no type, thus no atom
         A_LONG,			///< long integer
         A_FLOAT,		///< 32-bit float
         A_SYM,			///< t_symbol pointer
         A_OBJ,			///< t_object pointer (for argtype lists; passes the value of sym)
         A_DEFLONG,		///< long but defaults to zero
         A_DEFFLOAT,		///< float, but defaults to zero
         A_DEFSYM,		///< symbol, defaults to ""
         A_GIMME,		///< request that args be passed as an array, the routine will check the types itself.
         A_CANT,			///< cannot typecheck args
         A_SEMI,			///< semicolon
         A_COMMA,		///< comma
         A_DOLLAR,		///< dollar
         A_DOLLSYM,		///< dollar
         A_GIMMEBACK,	///< request that args be passed as an array, the routine will check the types itself. can return atom value in final atom ptr arg. function returns long error code 0 = no err. see gimmeback_meth typedef
         
         */
        
        switch self {
        case A_NOTHING:
            return "nothing"
        case A_LONG:
            return "long"
        case A_FLOAT:
            return "float"
        case A_SYM:
            return "symbol"
        case A_OBJ:
            return "object"
        case A_DEFLONG:
            return "deflong"
        // TODO: Finish these
        default:
            return "unknown"
        }
    }
}

@objc public class MaxSwift : NSObject {
    
    var maxObject : t_object
    
    let outlets : [Outlet]
    let inlets : [Inlet]
    
    required public init(withMaxObject maxObject : t_object) {
        print("MaxSwift object init")
        self.maxObject = maxObject
        
        outlets = []
        inlets = []
        super.init()
    }
    
    deinit {
        print("De-init")
    }
}

// Functions that can be passed from inlets
public extension MaxSwift {
    public func bang() -> e_max_errorcodes {
        print("bang");
        return MAX_ERR_NONE
    }
    
    public func int(int : Int) -> e_max_errorcodes {
        print("int \(int)");
        return MAX_ERR_NONE
    }
    
    public func float(float : Double) -> e_max_errorcodes {
        print("Float \(float)");
        return MAX_ERR_NONE
    }
    
    public func list(list: [MaxAtom]) -> e_max_errorcodes  {
        print("list array \(list)");
        return MAX_ERR_NONE
    }
    
    public func doubleClick() -> e_max_errorcodes {
        print("Double Click");
        postMessage("Double Click")
        return MAX_ERR_NONE
    }
    
    public func anything(name : t_symbol, withValues values : [MaxAtom]) -> e_max_errorcodes {
        print("anything \(name) : \(values)")
        postMessage("anything \(name) \(values)")

        return MAX_ERR_NONE
    }
    
    /* Sending generic mesages */
    public func test() -> e_max_errorcodes {
        print("Test");
        postMessage("Test")
        return MAX_ERR_NONE
    }
    
    public func test(withValues values : [MaxAtom]) -> e_max_errorcodes {
        print("Test \(values)");
        postMessage("Test \(values)")
        return MAX_ERR_NONE
    }
}

private extension MaxSwift {
    func postMessage(message : String...) {
        let message = String(message)
        object_post_swift(&maxObject, message)
    }
    
    func postWarning(message : String) {
        object_post_swift(&maxObject, message)
    }
    
    func postError(message : String) {
        object_error_swift(&maxObject, message)
    }
}