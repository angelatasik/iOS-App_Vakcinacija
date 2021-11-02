//
//  DetailViewController.swift
//  Proekt-AMU
//
//  Created by Angela Tasikj on 8/28/21.
//  Copyright © 2021 Angela Tasikj. All rights reserved.
//

import UIKit
import Parse

class DetailViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var Korisnik: UILabel!
    @IBOutlet weak var SaveOutlet: UIButton!
    @IBOutlet weak var Phone: UILabel!
    @IBOutlet weak var slika: UIImageView!
    @IBOutlet weak var Status: UILabel!
    @IBOutlet weak var FinishDate: UILabel!
    @IBOutlet weak var Email: UILabel!
    @IBOutlet weak var Vaccine: UILabel!
    @IBOutlet weak var DateFinish: UILabel!
    @IBOutlet weak var Data: UILabel!
    var datum = NSDate()
    var status = String()
    var ImePrezime = String()
    var phone = String()
    var email = String()
    var vakcina = String()
    var lat = Double()
    var long = Double()
    var adresa = String()
    var rezzId = String()
    var datePicker = NSDate()
    var DatumZavrsuvanje = NSDate()
    
    @IBOutlet weak var GenerateOutlet: UIButton!
    
    @IBOutlet weak var Bye: UILabel!
    @IBOutlet weak var DatePicker: UIDatePicker!

    
    func displayAlert(title: String, message: String) {
        let allertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        allertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(allertController, animated: true, completion: nil)
    }
    
    override func prepare(for seg: UIStoryboardSegue, sender: Any?) {
        if seg.identifier == "ToMapSeg" {
            let dVC = seg.destination as! MapViewController
            dVC.lat = lat
            dVC.long = long
            dVC.lokacija = adresa
        }
    }
    
    
    @IBAction func SavePressed(_ sender: Any) {
        
            let query = PFQuery(className: "Rezz")
            query.whereKey("objectId", equalTo: rezzId)
            query.findObjectsInBackground { (objects,error) in
                if error != nil {
                    print(error?.localizedDescription)
                }else if let object = objects{
                    for obj in object {
                        obj["finishDate"] = self.datePicker
//                        print("SE STAVI FIINISH DATE")
                        obj["status"] = "done"
//                        print("STATUSOT E DONE SEGA")
                        obj["vakcina"] = self.vakcina
                        obj.saveInBackground()
//                        print("se izvrsuva save in backg")
                    }
                }
                
            }
            displayAlert(title: "Succesfull", message: "Finished!")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Korisnik.text = ImePrezime
        Status.text = status
        Phone.text = phone
        Email.text = email
        Vaccine.text = vakcina
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        let StringDate = formatter.string(from: datum as Date)
        Data.text = StringDate
        let stringFDate = formatter.string(from: DatumZavrsuvanje as Date)
        if status == "scheduled" {
            FinishDate.isHidden = true
            DateFinish.isHidden = true
            DatePicker.datePickerMode = .date
            DatePicker.isHidden = false
            GenerateOutlet.isHidden = false
            SaveOutlet.isHidden = false
            Bye.isHidden = false
            datePicker = DatePicker.date as NSDate
        }else{
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
            let StringDate = formatter.string(from: datum as Date)
            FinishDate.text = StringDate
            FinishDate.isHidden = false
            DatePicker.isHidden = true
            Bye.isHidden = true
            SaveOutlet.isHidden = true
            GenerateOutlet.isHidden = false
            }
        }
    
    @IBAction func generate(_ sender: Any) {
        
         let imePAcient = self.ImePrezime
         let vakcinaPrimena = self.vakcina
         let datumZavrsuvanje = self.datePicker
         let combinedString = "ImePrezime: \(imePAcient) \n PrimenaVakcina: \(vakcinaPrimena) \n Datum: \(datumZavrsuvanje)"
        
         slika.image = generateQRCode(Vneseno: combinedString)
        
    }
    
    func generateQRCode(Vneseno: String) -> UIImage?{
        let vnesena_data = Vneseno.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator"){
            filter.setValue(vnesena_data, forKey: "inputMessage")
            
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            if let output = filter.outputImage?.transformed(by: transform)
            {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
        
    }
}
    


