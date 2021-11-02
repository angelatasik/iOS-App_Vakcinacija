//
//  CitizenDetailsViewController.swift
//  Proekt-AMU
//
//  Created by Angela Tasikj on 8/23/21.
//  Copyright © 2021 Angela Tasikj. All rights reserved.
//

import UIKit
import MapKit
import Parse

class CitizenDetailsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
  
     @IBOutlet weak var Email: UILabel!
    @IBOutlet weak var Phone: UILabel!
    @IBOutlet weak var Mapa: MKMapView!
    @IBOutlet weak var Bolest: UILabel!
    @IBOutlet weak var NameSurname: UILabel!
    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var Vakcina: UILabel!
    @IBOutlet weak var Datum: UILabel!
    @IBOutlet weak var pickerViewButton: UIButton!
 
    
    
    var ImePrezime = String()
    var datum = NSDate()
    var bolest = String()
    var lokacija = String()
    var tel = String()
    var email = String()
    var lon = Double()
    var lat = Double()
    var vakcina = String()
    
    
    @IBAction func Reject(_ sender: Any) {
        let query = PFUser.query()
        query?.whereKey("firstLastName", equalTo: ImePrezime)
        query?.whereKey("phoneNumber", equalTo: tel)
        query?.whereKey("username", equalTo: email)
        query?.findObjectsInBackground(block: { (users, error) in
            if error != nil {
                print(error?.localizedDescription)
            }else if let user = users{
                for u in user {
                    if let userId = u.objectId{
                        let Query = PFQuery(className: "Rezz")
                        Query.whereKey("from", equalTo: userId)
                        Query.whereKey("to", equalTo: PFUser.current()?.objectId)
                        Query.whereKey("description", equalTo: self.bolest)
                        Query.whereKey("date", equalTo: self.datum)
                        Query.whereKey("location", equalTo: self.lokacija)
                        
                        Query.findObjectsInBackground(block: { (objects, error) in
                            if error != nil {
                                print(error?.localizedDescription)
                            }else if let object = objects {
                                for obj in object {
                                    obj.deleteInBackground()
                                }
                            }
                        })
                    }
                }
            }
        })
        displayAlert(title: "Uspesno", message: "You reject request")
    }
    
    @IBAction func Accept(_ sender: Any) {
        let vakcinaaa = self.vakcina
        displayAlert(title: "ACCEPTED", message: "Vaccine: \(vakcinaaa)")
    }
    
    @IBAction func MakeRez(_ sender: Any) {
       
            let DATA = DatePicker.date
            let query = PFUser.query()
            query?.whereKey("firstLastName", equalTo: ImePrezime)
            query?.whereKey("phoneNumber", equalTo: tel)
            query?.whereKey("username", equalTo: email)
            query?.findObjectsInBackground(block: { (users, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }else if let user = users{
                    for u in user {
                        if let userId = u.objectId{
                            let Query = PFQuery(className: "Rezz")
                            Query.whereKey("from", equalTo: userId)
                            Query.whereKey("to", equalTo: PFUser.current()?.objectId)
                            Query.whereKey("description", equalTo: self.bolest)
                            Query.whereKey("date", equalTo: self.datum)
                            Query.whereKey("location", equalTo: self.lokacija)
                            Query.findObjectsInBackground(block: { (objects, error) in
                                if error != nil {
                                    print(error?.localizedDescription)
                                }else if let object = objects {
                                    for obj in object {
                                        obj["status"] = "pending"
                                        obj["DateTime"] = DATA
                                        print("stava data")
                                        obj["vakcina"] = self.vakcina
                                        print("stava vakcina: 'vakcina'")
                                        obj.saveInBackground()
                                    }
                                }
                            })
                        }
                    }
                }
            })
            displayAlert(title: "Succesful!", message: "You make an reservation")

    }

    override func viewDidAppear(_ animated: Bool) {
        Vakcina.text = vakcina
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Bolest.text = bolest
        Email.text = email
        Phone.text = tel
        NameSurname.text = ImePrezime
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let stringDate = dateFormatter.string(from: datum as! Date)
        Datum.text = stringDate
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let region = MKCoordinateRegion(center: coord, span: span)
        self.Mapa.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coord
        annotation.title = lokacija
        self.Mapa.addAnnotation(annotation)
    }
       
    
    func displayAlert(title: String, message: String) {
        let alertC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertC,animated: true,completion: nil)
    }
    
    
    var pickerData: KeyValuePairs =
        [
            "sinopharm" : "sinopharm",
            "sinovac" : "sinovac",
            "pfizer" : "pfizer",
            "sputnik" : "sputnik"
        ]
    
    let screenW = UIScreen.main.bounds.width - 10
    let screenH = UIScreen.main.bounds.height - 50
    var selectedRow = 0
    
  
    
    @IBAction func Select(_ sender: Any) {
        print("kliknato select")
        let vc = UIViewController()
        print("kreira view")
        vc.preferredContentSize = CGSize(width: screenW, height: 70)
        
        let pickerview = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenW, height: 70))
        pickerview.dataSource = self
        pickerview.delegate = self
        
        pickerview.selectRow(selectedRow, inComponent: 0, animated: false)
        
        vc.view.addSubview(pickerview)
        pickerview.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        pickerview.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        print("doagja do alertot")
        let alert = UIAlertController(title: "Select vaccine", message: " ", preferredStyle: .actionSheet)
        print("kreira alert")
        
        alert.popoverPresentationController?.sourceView = pickerViewButton
        print("izvrsuva ova")
        alert.popoverPresentationController?.sourceRect = pickerViewButton.bounds
        print("i ova")
        
        alert.setValue(vc, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
            
        }))
        
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: { (UIAlertAction) in
            self.selectedRow = pickerview.selectedRow(inComponent: 0)
            let selected = Array(self.pickerData)[self.selectedRow]
            self.vakcina = selected.value
//            print("stavena e selektiranata vakcina")
            self.Vakcina.text = self.vakcina
//            print("ja stavab vo lab")
            
        }))
//        print("addAction")
        self.present(alert, animated: true, completion: nil)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH))
        label.text = Array(pickerData)[row].key
        label.sizeToFit()
        return label
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }   
    
}
