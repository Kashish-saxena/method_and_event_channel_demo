import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private let batteryChannel = "samples.flutter.io/battery"
    private let chargingChannel = "samples.flutter.io/charging"
    
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        guard let controller = window?.rootViewController as? FlutterViewController else {
            fatalError("rootViewController is not type FlutterViewController")
        }
        let batteryChannel = FlutterMethodChannel(name: batteryChannel,
                                                  binaryMessenger: controller.binaryMessenger)
        batteryChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard call.method == "getBatteryLevel" else {
                result(FlutterMethodNotImplemented)
                return
            }
            self?.receiveBatteryLevel(result: result)
        })
        
        let chargingChannel = FlutterEventChannel(name: chargingChannel,
                                                  binaryMessenger: controller.binaryMessenger)
        chargingChannel.setStreamHandler(ChargingStreamHandler())
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func receiveBatteryLevel(result: FlutterResult) {
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        if device.batteryState == .unknown {
            result(FlutterError(code: "UNAVAILABLE",
                                message: "Battery level not available.",
                                details: nil))
        } else {
            result(Int(device.batteryLevel * 100))
        }
    }
}

class ChargingStreamHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    var status = "Unknown";
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        UIDevice.current.isBatteryMonitoringEnabled = true
//        var batteryLevel: Float { UIDevice.current.batteryLevel }
//        print(batteryLevel)
        var batteryState: UIDevice.BatteryState { UIDevice.current.batteryState }
        switch batteryState {
            case .unplugged, .unknown:
                status = "not charging";
                print("not charging")
            case .charging:
                status = "charging";
           
                print("charging")
            case .full:
                status = "full";
                print(" full")
        @unknown default:
            print("err")
        }
        
        events(status)
        self.eventSink = events
    
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(onBatteryStateDidChange),
//            name: UIDevice.batteryStateDidChangeNotification,
//            object: nil
//        )
//        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
       
       
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        eventSink = nil
        return nil
    }
   
//    @objc func batteryLevelDidChange(_ notification: Notification) {
//        var batteryState: UIDevice.BatteryState { UIDevice.current.batteryState }
//        switch batteryState {
//            case .unplugged, .unknown:
//                print("not charging")
//            case .charging:
//                print("charging")
//             case .full:
//                print(" full")
//        @unknown default:
//            print("err")
//        }
//    }
    
//    @objc private func onBatteryStateDidChange(notification: Notification) {
//        guard let eventSink = eventSink else { return }
//        let batteryState = UIDevice.current.batteryState
//        switch batteryState {
//            case .charging, .full:
//                eventSink("charging")
//            case .unplugged:
//                eventSink("discharging")
//            default:
//                eventSink(FlutterError(code: "UNAVAILABLE",
//                                   message: "Charging status unavailable",
//                                   details: nil))
//        }
//    }
}

