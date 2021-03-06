

import UIKit
import WebKit
import AudioToolbox
import ImageIO


@objc enum Star : Int {
    case blue
    case white
    case yellow
    case red
}

/*
 despite the Swift 3 small-letter convention, this is rendered as:
 
 typedef SWIFT_ENUM(NSInteger, Star) {
   StarBlue = 0,
   StarWhite = 1,
   StarYellow = 2,
   StarRed = 3,
 };

 */

public class MyClass {
    var name : String?
    var timer : Timer?
    func startTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1,
            target: self, selector: #selector(timerFired),
            userInfo: nil, repeats: true)
    }
    @objc func timerFired(_ t:Timer) { // will crash without @objc; #selector prevents with compiler error
        print("timer fired")
        self.timer?.invalidate()
    }
}

class MyOtherClass : NSObject, WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        decisionHandler(.allow)
    }
}

struct Pair {
    let x : Int
    let y : Int
}

class Womble : NSObject {
    override init() {
        super.init()
    }
}


class ViewController: UIViewController {
    
    var myOptionalInt : Int? // Objective-C cannot see this
    
    typealias MyStringExpecter = (String) -> ()
    class StringExpecterHolder : NSObject {
        var f : MyStringExpecter!
    }

    func blockTaker(_ f:()->()) {}
    // - (void)blockTaker:(void (^ __nonnull)(void))f;
    func functionTaker(_ f:@convention(c)() -> ()) {}
    // - (void)functionTaker:(void (* __nonnull)(void))f;
    
    // overloading while hiding
    @nonobjc func dismissViewControllerAnimated(_ flag: Int, completion: (() -> Void)?) {}
    
    func testVisibility1(what:Int) {}
    func testVisibility2(what:MyClass) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            // proving that Swift structs don't get the zeroing initializer
            // let p = Pair()
            let pp = CGPoint()
        }
        
        do {
        
            let cs = ("hello" as NSString).utf8String
            let csArray = "hello".utf8CString
            if let cs2 = "hello".cString(using: .utf8) { // [CChar]
                let ss = String(validatingUTF8: cs2)
                print(ss)
            }
            
            "hello".withCString {
                var cs = $0 // UnsafePointer<Int8>
                while cs.pointee != 0 {
                    print(cs.pointee)
                    cs += 1 // or: cs = cs.successor()
                }
            }
            
//            _ = q
//            _ = qq
            _ = cs
            
        }
        
        do {
            let da = kDead
            print(da)
            
            setState(kDead)
            setState(kAlive)
            setState(State(rawValue:2)) // Swift can't stop you
            
            self.view.autoresizingMask = .flexibleWidth
            self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
        }
        
        do {
            // structs have suppressed the functions
            // CGPoint.make(CGFloat(0), CGFloat(0))
            let ok = CGPoint(x:1, y:2).equalTo(CGPoint(x:1.0, y:2.0))
        }
        
        do {
            UIGraphicsBeginImageContext(CGSize(width:200,height:200))
            let c = UIGraphicsGetCurrentContext()!
            let arr = [CGPoint(x:0,y:0),
                CGPoint(x:50,y:50),
                CGPoint(x:50,y:50),
                CGPoint(x:0,y:100),
            ]
            c.__strokeLineSegments(between: arr, count: 4)
            UIGraphicsEndImageContext()
        }
        
        do {
            UIGraphicsBeginImageContext(CGSize(width:200,height:200))
            let c = UIGraphicsGetCurrentContext()!
            let arr = UnsafeMutablePointer<CGPoint>.allocate(capacity:4)
            defer {
                arr.deinitialize()
                arr.deallocate(capacity:4)
            }
            arr[0] = CGPoint(x:0,y:0)
            arr[1] = CGPoint(x:50,y:50)
            arr[2] = CGPoint(x:50,y:50)
            arr[3] = CGPoint(x:0,y:100)
            c.__strokeLineSegments(between: arr, count:4)
            let im = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            self.view.addSubview(UIImageView(image:im)) // just checking :)
        }
        
        do {
            let col = UIColor(red: 0.5, green: 0.6, blue: 0.7, alpha: 1.0)
            if let comp = col.cgColor.__unsafeComponents, // *
                let sp = col.cgColor.colorSpace,
                sp.model == .rgb {
                let red = comp[0]
                let green = comp[1]
                let blue = comp[2]
                let alpha = comp[3]
                
                print(red, green, blue, alpha)
            }
        }
        
        do {
            struct Arrow {
                static let ARHEIGHT : CGFloat = 20
            }
            let myRect = CGRect(x: 10, y: 10, width: 100, height: 100)
            var arrow = CGRect.zero
            var body = CGRect.zero
            myRect.__divided(
                slice: &arrow, remainder: &body, atDistance: Arrow.ARHEIGHT, from: .minYEdge)
            let (arrowRect, bodyRect) = myRect.divided(atDistance: Arrow.ARHEIGHT, from: .minYEdge)

        }
        var which : Bool {return false}
        if which {
            let sndurl = Bundle.main.url(forResource:"test", withExtension: "aif")!
            var snd : SystemSoundID = 0
            AudioServicesCreateSystemSoundID(sndurl as CFURL, &snd)
        }
        
        do {
            class MyClass2 /*: NSObject*/ {
                var name : String?
            }
            let c = MyClass2()
            c.name = "cool"
            let arr = [c]
            let arr2 = arr as NSArray
            let name = (arr2[0] as? MyClass2)?.name
            print(name)
        }
        
        do {
            let lay = CALayer()
            class MyClass2 /*: NSObject*/ {
                var name : String?
            }
            let c = MyClass2()
            c.name = "cool"
            lay.setValue(c, forKey: "c")
            let name = (lay.value(forKey: "c") as? MyClass2)?.name
            print(name)
        }
        
        do {
            let lay = CALayer()
            lay.setValue(CGPoint(x:100,y:100), forKey: "point")
            lay.setValue([CGPoint(x:100,y:100)], forKey: "pointArray")
            let point = lay.value(forKey:"point")
            let pointArray = lay.value(forKey:"pointArray")
            print(type(of:point!))
            print(type(of:pointArray!))
        }
        
        do {
            let s = "hello"
            let s2 = s.replacingOccurrences(of: "ell", with:"ipp")
            // s2 is now "hippo"
            print(s2)
        }
        
        do {
            let sel = #selector(doButton)
            print(sel)
            let sel2 = #selector(makeHash as ([String]) -> Void)
            print(sel2)
            let sel3 = #selector(makeHash as ([Int]) -> Void)
            print(sel3)
            
            let arr = NSArray(objects:1,2,3)
        }
        
        do {
            // hold my beer and watch _this_!
            
            let arr = ["Mannyz", "Moey", "Jackx"]
            // @convention(c) (Any, Any, UnsafeMutableRawPointer?) -> Int, context: UnsafeMutableRawPointer?) -> [Any]
            func sortByLastCharacter(_ s1:Any,
                _ s2:Any, _ context: UnsafeMutableRawPointer?) -> Int { // *
                    let c1 = (s1 as! String).characters.last!
                    let c2 = (s2 as! String).characters.last!
                    return ((String(c1)).compare(String(c2))).rawValue
            }
            let arr2 = (arr as NSArray).sortedArray(sortByLastCharacter, context: nil)
            print(arr2)
            let arr3 = (arr as NSArray).sortedArray({
                s1, s2, context in
                let c1 = (s1 as! String).characters.last!
                let c2 = (s2 as! String).characters.last!
                return ((String(c1)).compare(String(c2))).rawValue
            }, context:nil)
            print(arr3)
        }

        self.testTimer()
        
        do {
            let grad = CAGradientLayer()
            grad.colors = [
                UIColor.lightGray.cgColor,
                UIColor.lightGray.cgColor,
                UIColor.blue.cgColor
            ]

        }
        
        do {
            func f (_ s:String) {print(s)}
            // let thing = f as! AnyObject // crash
            let holder = StringExpecterHolder()
            holder.f = f
            let lay = CALayer()
            lay.setValue(holder, forKey:"myFunction")
            let holder2 = lay.value(forKey: "myFunction") as! StringExpecterHolder
            holder2.f("testing")
        }
        
        do {
            let mas = NSMutableAttributedString()
            let r = NSMakeRange(0,0) // not really, just making sure we compile
            mas.enumerateAttribute("HERE", in: r) {
                value, r, stop in
                if let value = value as? Int, value == 1  {
                    // ...
                    stop.pointee = true
                }
            }

        }
        
        
        self.reportSelectors()
        
        do {
            let t = Thing2<NSString>()
            t.giveMeAThing("howdy")
        }
        
    }
    
    func inverting(_:ViewController) -> ViewController {
        return ViewController()
    }
    
    @IBAction func doButton(_ sender: Any?) {
    
    }
    
    func makeHash(ingredients stuff:[String]) {
        
    }
    
    func makeHash(of stuff:[Int]) {
        
    }
    
    override func prepare(for war: UIStoryboardSegue, sender trebuchet: Any?) {
        // ...
    }
    
    override func canPerformAction(_ action: Selector,
        withSender sender: Any?) -> Bool {
            if action == #selector(undo) {
            }
            return true
    }
    
    func undo () {}
    
    func testVariadic(_ stuff: Int ...) {}
    
    func testDefault(_ what: Int = 42) {}


    var myclass = MyClass() // Objective-C can't see this
    func testTimer() {
        self.myclass.startTimer()
    }

    func sayHello() -> String // "sayHello"
    { return "ha"}
    
    func say(_ s:String) // "say:"
    {}
    
    func say(string s:String) // "sayWithString:"
    {}
    
    func say(_ s:String, times n:Int) // "say:times:"
    {}

    func say(of s:String, loudly:Bool)
    {}
    
    func reportSelectors() {
        print(#selector(self.sayHello))
        print(#selector(self.say(_:)))
        print(#selector(self.say(string:)))
        print(#selector(self.say(_:times:)))
        print(#selector(self.say(of:loudly:)))
    }


}

