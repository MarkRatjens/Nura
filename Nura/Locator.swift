import CoreLocation

public protocol LocatorDelegate: class  {
	func didFind(locations: [CLLocation])
}

public class Locator: NSObject {
	public weak var delegate: LocatorDelegate?
	
	public func start() {
		if let lm = manager {
			if CLLocationManager.locationServicesEnabled() {
				lm.startUpdatingLocation()
			}
		}
	}
	
	public func setHome(_ home: CLLocation) {
		let hd: Data = NSKeyedArchiver.archivedData(withRootObject: home)
		userDefaults.set(hd, forKey: "My Home")
	}

	public lazy var manager: CLLocationManager? = {
		let lm = CLLocationManager()
		lm.delegate = self
		lm.desiredAccuracy = kCLLocationAccuracyBest
		lm.requestWhenInUseAuthorization()
		return lm
	}()

	public var home: CLLocation? {
		if let hd = userDefaults.object(forKey: "My Home") as! Data? {
			let h = NSKeyedUnarchiver.unarchiveObject(with: hd) as! CLLocation
			return  h
		} else {
			return nil
		}
	}
	
	public func center(of locations: [CLLocation]) -> CLLocation? {
		let c = Double(locations.count)
		if c > 0 {
			let lat = locations.map { $0.coordinate.latitude }.reduce(0, +) / c
			let long = locations.map { $0.coordinate.longitude }.reduce(0, +) / c
			return CLLocation(latitude: lat, longitude: long)
		}
		return nil
	}
	
	public var locations = [CLLocation]()
	public var location: CLLocation? { return locations.last }
	
	lazy var userDefaults = UserDefaults.standard
}


extension Locator: CLLocationManagerDelegate {	
	open func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		manager.stopUpdatingLocation()
		self.locations = locations
		delegate?.didFind(locations: locations)
	}
	
	open func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { print("Error \(error)") }
}
