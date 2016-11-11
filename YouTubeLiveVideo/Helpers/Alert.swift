import UIKit

class Alert: NSObject {
    
    var popupWindow : UIWindow!
    var rootVC : UIViewController!

    class var sharedInstance: Alert {
        struct SingletonWrapper {
            static let sharedInstance = Alert()
        }
        
        return SingletonWrapper.sharedInstance;
    }
    
    private override init() {
        let screenBounds = UIScreen.mainScreen().bounds
        popupWindow = UIWindow(frame: CGRectMake(0, 0, screenBounds.width, screenBounds.height))
        popupWindow.windowLevel = UIWindowLevelStatusBar + 1
        
        rootVC = StatusBarShowingViewController()
        popupWindow.rootViewController = rootVC
        
        super.init()
    }

    func showOk(title: String, message: String, onComplete: ()->Void = { _ in }) {
        popupWindow.hidden = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { _ in
            self.resignPopupWindow()
            onComplete()
        }))
        
        rootVC.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showOkCancel(title: String, message: String, onComplete: (Void->Void)?, onCancel: (Void->Void)?) {
        popupWindow.hidden = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { _ in
            self.resignPopupWindow()
            onComplete?()
        })
        let cancelAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: { _ in
            self.resignPopupWindow()
            onCancel?()
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        rootVC.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showYesNo(title: String, message: String, onYes: ()->Void = {_ in}, onNo: ()->Void = {_ in}) {
        popupWindow.hidden = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { _ in
            self.resignPopupWindow()
            onYes()
        })
        let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: { _ in
            self.resignPopupWindow()
            onNo()
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        rootVC.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showConfirmCancel(title: String, message: String, onConfirm: ()->Void = {_ in}, onCancel: ()->Void = {_ in}) {
        popupWindow.hidden = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Conform", style: UIAlertActionStyle.Default, handler: { _ in
            self.resignPopupWindow()
            onConfirm()
        })
        let cancelAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: { _ in
            self.resignPopupWindow()
            onCancel()
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        rootVC.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showConfirmChange(title: String, message: String, onConfirm: ()->Void = {_ in}, onChange: ()->Void = {_ in}) {
        popupWindow.hidden = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Conform", style: UIAlertActionStyle.Default, handler: { _ in
            self.resignPopupWindow()
            onConfirm()
        })
        let cancelAction = UIAlertAction(title: "Change", style: UIAlertActionStyle.Default, handler: { _ in
            self.resignPopupWindow()
            onChange()
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        rootVC.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showOkChange(title: String, message: String, onOk: ()->Void = {_ in}, onChange: ()->Void = {_ in}) {
        popupWindow.hidden = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { _ in
            self.resignPopupWindow()
            onOk()
        })
        let cancelAction = UIAlertAction(title: "Change", style: UIAlertActionStyle.Default, handler: { _ in
            self.resignPopupWindow()
            onChange()
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        rootVC.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showLetsgoLater(title: String, message: String, onLetsGo: ()->Void = {_ in}, onLater: ()->Void = {_ in}) {
        popupWindow.hidden = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let letsGoAction = UIAlertAction(title: "Go", style: UIAlertActionStyle.Default, handler: { _ in
            self.resignPopupWindow()
            onLetsGo()
        })
        let laterAction = UIAlertAction(title: "Later", style: UIAlertActionStyle.Default, handler: { _ in
            self.resignPopupWindow()
            onLater()
        })
        alert.addAction(laterAction)
        alert.addAction(letsGoAction)
        
        rootVC.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showOkNo(title: String, message: String, onOk: ()->Void = {_ in}, onNo: ()->Void = {_ in}) {
        popupWindow.hidden = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let letsGoAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { _ in
            self.resignPopupWindow()
            onOk()
        })
        let laterAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: { _ in
            self.resignPopupWindow()
            onNo()
        })
        alert.addAction(laterAction)
        alert.addAction(letsGoAction)
        
        rootVC.presentViewController(alert, animated: true, completion: nil)
    }
    
    func resignPopupWindow() {
        self.popupWindow.hidden = true
    }
    
}
