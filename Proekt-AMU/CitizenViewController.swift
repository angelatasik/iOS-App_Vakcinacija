//
//  CitizenViewController.swift
//
//
//  Created by Angela Tasikj on 8/20/21.
//
import UIKit
import Parse
import MapKit

class CitizenViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var Mapa: MKMapView!
    
    @IBOutlet weak var labelaa: UILabel!
    @IBOutlet weak var PickerView: UIPickerView!
    @IBOutlet weak var Bolesti: UITextField!
    
    var pickerData:[String] = [String]()
    var manager = CLLocationManager()
    
    var locationChosen = Bool()
    var lat = Double()
    var long = Double()
    var vakcina = String()
    var firstLastNames = [String]()
    var gradovi = [String]()
    var doctorsIds = [String]()
    var place = String()
    var bolesti = String()
    var doctors = [String]()
    var select = String()
    
    
    @IBAction func Req(_ sender: Any) {
        self.performSegue(withIdentifier: "ToReqSeg", sender: nil)
    }
    
    @IBAction func LogOut(_ sender: Any) {
        PFUser.logOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func SelectDoctor(_: UIButton) {
//        print("vlaga vo prikaz na doktori")
        firstLastNames.removeAll()
        bolesti = Bolesti.text!
        
        let query = PFUser.query()
        
        query?.whereKey("tipKorisnik", equalTo: "Doctor" as? String)
//        print("kreira query")
        query?.findObjectsInBackground(block: { (object, error) in
            if error != nil{
                print(error?.localizedDescription)
            }
            else if let doktori = object{
                for o in doktori{
                    if let doktor = o as? PFUser {
//                        print("pocnuva da zima od objektot")
                        if let firstLastName = doktor["firstLastName"]{
                            
//                            print("gi stava")
                            self.firstLastNames.append(firstLastName as! String)
                            
                        }
                    }
                }
            }
            self.performSegue(withIdentifier: "ViewDoctorsSeg", sender: nil)
        })
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        vakcina = pickerData[row]
        
//        print(vakcina)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]

    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // print("vlaga tukaa")
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta:  0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        self.Mapa.setRegion(region, animated: true)
        // print("se izvrsi neso")
    }
    
    @objc func longpress(gestureRecognizer: UIGestureRecognizer) {
        //print("Go registrira longpressot")
//        print("longpress")
        if !locationChosen{
//            print("stisnato ee")
            if gestureRecognizer.state == UIGestureRecognizer.State.began {
                let touchPoint = gestureRecognizer.location(in: self.Mapa)
                let newCoordinate = self.Mapa.convert(touchPoint, toCoordinateFrom: self.Mapa)
                self.long = newCoordinate.longitude
                self.lat = newCoordinate.latitude
//                print(newCoordinate)
                let newLocation = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
                var title = ""
                CLGeocoder().reverseGeocodeLocation(newLocation, completionHandler:  { (placemarks, error) in
                    if error != nil {
                        print(error!)
                    }else{
                        if let placemark = placemarks?[0] {
                            if placemark.subThoroughfare != nil {
                                title += placemark.subThoroughfare! + " "
                            }
                            if placemark.thoroughfare != nil {
                                title += placemark.thoroughfare!
                            }
                        }
                        if title == "" {
                            title = "Added \(NSDate())"
                        }
                        
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = newCoordinate
                        annotation.title = title
                        self.Mapa.addAnnotation(annotation)
                        self.locationChosen = true
//                        print(title)
                        
                    }
                })
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewDoctorsSeg" {
            let destinationVC = segue.destination as! FamilyDoctorsController
            destinationVC.ImePrezime = firstLastNames
            destinationVC.lokacija = place
            destinationVC.bolest = bolesti
            destinationVC.lat = lat
            destinationVC.lon = long
            destinationVC.vakcina = vakcina
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func DisplayAlert(title: String, msg: String) {
        let alertCotnroller = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertCotnroller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertCotnroller,animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerData = ["sinopharm","sinovac","pfizer", "sputnik"]
        
        self.PickerView.delegate = self
        self.PickerView.dataSource = self
        
        locationChosen = false
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(longpress(gestureRecognizer:)))
        uilpgr.minimumPressDuration = 1
        Mapa.addGestureRecognizer(uilpgr)
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        // Do any additional setup after loading the view.
    }
    
    
}
