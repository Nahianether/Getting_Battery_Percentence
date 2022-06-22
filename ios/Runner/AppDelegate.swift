import UIKit
import Flutter
import AudioToolbox

enum ChannelName {
  static let battery = "samples.flutter.io/battery"
  static let charging = "samples.flutter.io/charging"
}

enum BatteryState {
  static let charging = "charging"
  static let discharging = "discharging"
}

enum MyFlutterErrorCode {
  static let unavailable = "UNAVAILABLE"
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("timer1212")
        GeneratedPluginRegistrant.register(with: self)
    guard let controller = window?.rootViewController as? FlutterViewController else {
      fatalError("rootViewController is not type FlutterViewController")
    }
    let batteryChannel = FlutterMethodChannel(name: ChannelName.battery,
                                              binaryMessenger: controller.binaryMessenger)
    batteryChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
      guard call.method == "getBatteryLevel" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.receiveBatteryLevel(result: result)
    })

    let chargingChannel = FlutterEventChannel(name: ChannelName.charging,
                                              binaryMessenger: controller.binaryMessenger)
    chargingChannel.setStreamHandler(self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func receiveBatteryLevel(result: FlutterResult) {
    print("timer10")
    //Timer(timeInterval: 1, repeats: true) { _ in print("Done!") }
    Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    print("bokachoda")
    //   viewDidLoad()
     // schedule()
    let device = UIDevice.current
    device.isBatteryMonitoringEnabled = true
    guard device.batteryState != .unknown  else {
      result(FlutterError(code: MyFlutterErrorCode.unavailable,
                          message: "Battery info unavailable",
                          details: nil))
      return
    }
    result(Int(device.batteryLevel * 100))
  }

  public func onListen(withArguments arguments: Any?,
                       eventSink: @escaping FlutterEventSink) -> FlutterError? {
                        print("timer5")
    self.eventSink = eventSink
    UIDevice.current.isBatteryMonitoringEnabled = true
    sendBatteryStateEvent()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(AppDelegate.onBatteryStateDidChange),
      name: UIDevice.batteryStateDidChangeNotification,
      object: nil)
    return nil
  }

  @objc private func onBatteryStateDidChange(notification: NSNotification) {
    print("timer1")
    sendBatteryStateEvent()
  }

  private func sendBatteryStateEvent() {
    guard let eventSink = eventSink else {
      return
    }

    switch UIDevice.current.batteryState {
    case .full:
      eventSink(BatteryState.charging)
    case .charging:
      eventSink(BatteryState.charging)
    case .unplugged:
      eventSink(BatteryState.discharging)
    default:
      eventSink(FlutterError(code: MyFlutterErrorCode.unavailable,
                             message: "Charging status unavailable",
                             details: nil))
    }
  }
//    public func viewDidLoad() {
//        var timer = Timer(timeInterval: 0.4, repeats: true) { _ in print("Done!") }
//        print("timer1212121212112")
//        // print(timer)
//    }

    // must be internal or public.
    @objc func update() {
        print("timer2012")
               let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
feedbackGenerator.impactOccurred()
        viewDidLoad()
  
    }


//     func schedule() {
//     DispatchQueue.main.async {
//       self.timer = Timer.scheduledTimer(timeInterval: 20, target: self,
//                                    selector: #selector(self.timerDidFire(timer:)), userInfo: nil, repeats: false)
//     }
//   }

//   @objc private func timerDidFire(timer: Timer) {
//     print(timer)
//   }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    NotificationCenter.default.removeObserver(self)
    eventSink = nil
    return nil
  }	
  @IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var startStopButton: UIButton!
	@IBOutlet weak var resetButton: UIButton!
	
	var timerCounting:Bool = false
	var startTime:Date?
	var stopTime:Date?
	
	let userDefaults = UserDefaults.standard
	let START_TIME_KEY = "startTime"
	let STOP_TIME_KEY = "stopTime"
	let COUNTING_KEY = "countingKey"
	
	var scheduledTimer: Timer!
	
	 func viewDidLoad()
	{
//		super.viewDidLoad()
		
		startTime = userDefaults.object(forKey: START_TIME_KEY) as? Date
		stopTime = userDefaults.object(forKey: STOP_TIME_KEY) as? Date
		timerCounting = userDefaults.bool(forKey: COUNTING_KEY)
		
		
		if timerCounting
		{
			startTimer()
		}
		else
		{
			stopTimer()
			if let start = startTime
			{
				if let stop = stopTime
				{
					let time = calcRestartTime(start: start, stop: stop)
					let diff = Date().timeIntervalSince(time)
					setTimeLabel(Int(diff))
				}
			}
		}
	}

	@IBAction func startStopAction(_ sender: Any)
	{
		if timerCounting
		{
			setStopTime(date: Date())
			stopTimer()
		}
		else
		{
			if let stop = stopTime
			{
				let restartTime = calcRestartTime(start: startTime!, stop: stop)
				setStopTime(date: nil)
				setStartTime(date: restartTime)
			}
			else
			{
				setStartTime(date: Date())
			}
			
			startTimer()
		}
	}
	
	func calcRestartTime(start: Date, stop: Date) -> Date
	{
		let diff = start.timeIntervalSince(stop)
		return Date().addingTimeInterval(diff)
	}
	func startTimer()
	{
		scheduledTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(refreshValue), userInfo: nil, repeats: true)
		setTimerCounting(true)
		startStopButton.setTitle("STOP", for: .normal)
		startStopButton.setTitleColor(UIColor.red, for: .normal)
	}
	
	@objc func refreshValue()
	{
		if let start = startTime
		{
			let diff = Date().timeIntervalSince(start)
			setTimeLabel(Int(diff))
		}
		else
		{
			stopTimer()
			setTimeLabel(0)
		}
	}
	
	func setTimeLabel(_ val: Int)
	{
		let time = secondsToHoursMinutesSeconds(val)
		let timeString = makeTimeString(hour: time.0, min: time.1, sec: time.2)
		timeLabel.text = timeString
	}
	
	func secondsToHoursMinutesSeconds(_ ms: Int) -> (Int, Int, Int)
	{
		let hour = ms / 3600
		let min = (ms % 3600) / 60
		let sec = (ms % 3600) % 60
		return (hour, min, sec)
	}
	
	func makeTimeString(hour: Int, min: Int, sec: Int) -> String
	{
		var timeString = ""
		timeString += String(format: "%02d", hour)
		timeString += ":"
		timeString += String(format: "%02d", min)
		timeString += ":"
		timeString += String(format: "%02d", sec)
		return timeString
	}
	
	func stopTimer()
	{
		if scheduledTimer != nil
		{
			scheduledTimer.invalidate()
		}
		setTimerCounting(false)
		startStopButton.setTitle("START", for: .normal)
		startStopButton.setTitleColor(UIColor.systemGreen, for: .normal)
	}
	
	@IBAction func resetAction(_ sender: Any)
	{
		setStopTime(date: nil)
		setStartTime(date: nil)
		timeLabel.text = makeTimeString(hour: 0, min: 0, sec: 0)
		stopTimer()
	}
	
	func setStartTime(date: Date?)
	{
		startTime = date
		userDefaults.set(startTime, forKey: START_TIME_KEY)
	}
	
	func setStopTime(date: Date?)
	{
		stopTime = date
		userDefaults.set(stopTime, forKey: STOP_TIME_KEY)
	}
	
	func setTimerCounting(_ val: Bool)
	{
		timerCounting = val
		userDefaults.set(timerCounting, forKey: COUNTING_KEY)
	}

	 let manager = SocketManager(socketURL: URL(string: 
 "http://xxxxxxxxx.com")!, config: [.log(true), .compress])
 var socket = manager.defaultSocket

socket.connect()
    socket.on(clientEvent: .connect) {data, ack in
        print("socket connected")
        self.gotConnection()
       }
    }

 func gotConnection(){

 socket.on("new message here") { (dataArray, ack) in

    print(dataArray.count)

     }
   }

}
