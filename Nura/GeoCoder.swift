import CoreLocation
import Contacts

public class GeoCoder {
	public func address(from location: CLLocation, then complete: @escaping (CNPostalAddress) -> Void) {
		placemark(from: location, then: { (placemark) in
			if let pa = placemark.postalAddress { complete(pa) }
		})
	}
	
	public func location(from string: String, then complete: @escaping (CLLocation) -> Void) {
		placemark(from: string, then: { (placemark) in
			if let l = placemark.location { complete(l) }
		})
	}

	public func placemark(from location: CLLocation, then complete: @escaping (CLPlacemark) -> Void) {
		geocoder.reverseGeocodeLocation(location, preferredLocale: nil) { (placemarks, error) in
			guard let p = placemarks?.first else {
				print("No placemark from Apple: \(String(describing: error))")
				return
			}
			complete(p)
		}
	}
	
	public func placemark(from string: String, then complete: @escaping (CLPlacemark) -> Void) {
		geocoder.geocodeAddressString(string) { (placemarks, error) in
			guard let p = placemarks?.first else {
				print("No placemark from Apple: \(String(describing: error))")
				return
			}			
			complete(p)
		}
	}

	public func mailingAddress(from postalAddress: CNPostalAddress) -> String {
		return postalAddressFormatter.string(from: postalAddress)
	}
	
	let geocoder = CLGeocoder()
	
	lazy var postalAddressFormatter: CNPostalAddressFormatter = {
		let paf = CNPostalAddressFormatter()
		paf.style = .mailingAddress
		return paf
	}()
	
	public init() {}
}
