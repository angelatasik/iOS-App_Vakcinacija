//
//  RezzDetailsViewController.swift
//  Proekt-AMU
//
//  Created by Angela Tasikj on 8/26/21.
//  Copyright © 2021 Angela Tasikj. All rights reserved.
//

import UIKit
import Parse

class RezzDetailsViewController: UIViewController {

   
    var dataReq = NSDate()
    var DoctorId = String()
    var bolest = String()
    var status = String()
    var dateFinished = NSDate()
    var DatumPonuda = NSDate()
    var VakcinaPonuda = String()
    var ZakazanoNa = NSDate()
    
    @IBOutlet weak var slika: UIImageView!
    @IBOutlet weak var VakcinaP: UILabel!
    @IBOutlet weak var DatumBaranje: UILabel!
    @IBOutlet weak var QRCodeKopceOutlet: UIButton!
    @IBOutlet weak var Status: UILabel!
    @IBOutlet weak var ImePrezime: UILabel!
    @IBOutlet weak var Email: UILabel!
    @IBOutlet weak var DatumP: UILabel!
    @IBOutlet weak var Datum: UILabel!
    @IBOutlet weak var DatumZakazano: UILabel!
    @IBOutlet weak var Vakcina: UILabel!
    @IBOutlet weak var Zakazano: UILabel!
    @IBOutlet weak var Phone: UILabel!
    @IBOutlet weak var Odbij: UIButton!
    @IBOutlet weak var Prifati: UIButton!
    
    var datumi = [NSDate]()
    var MajstoriIds = [String]()
    var statuses = [String]()
    var descriptions = [String]()

    
    @IBAction func Accept(_ sender: Any) {
        let query = PFQuery(className: "Rezz")
        query.whereKey("from", equalTo: PFUser.current()?.objectId)
        query.whereKey("to", equalTo: DoctorId)
        query.whereKey("date", equalTo: dataReq)
        query.whereKey("vakcina", equalTo: VakcinaPonuda)
        query.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            }else if let obj = objects {
                for o in obj {
                    o["status"] = "scheduled"
                    o.saveInBackground()
                    self.displayAlert(title: "Success" , message: "Scheduled!")
                }
            }
        })
    }
    @IBAction func Reject(_ sender: Any) {
        
        let query = PFQuery(className: "Rezz")
        query.whereKey("from", equalTo: PFUser.current()?.objectId)
        query.whereKey("to", equalTo: DoctorId)
        query.whereKey("date", equalTo: dataReq)
        query.whereKey("vakcina", equalTo: VakcinaPonuda)
        query.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            }else if let obj = objects {
                for o in obj {
                    o["status"] = "scheduled"
                    o.deleteInBackground()
                }
            }
        })
        if status == "active"{
            displayAlert(title: "Succes", message: "The request has been canceled")
        }else {
            displayAlert(title: "Succes", message: "The request has been rejected")
        }
    }
    
    
    func displayAlert(title: String, message: String){
        let allertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        allertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(allertController,animated: true,completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd/MM/yyyy HH:mm"
        let stringDate = dateformatter.string(from: dataReq as Date)
        DatumBaranje.text = stringDate
        Status.text = status
        
        let query = PFUser.query()
        query?.whereKey("objectId", equalTo: DoctorId)
        query?.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            }else if let object = objects{
                for o in object {
                    if let doctor = o as? PFUser {
                        if let firsLastName = doctor["firstLastName"] {
                            
                                if let phoneNumber = doctor["phoneNumber"]{
                                    if let email = doctor.username {
                                        self.ImePrezime.text = (firsLastName as! String)
                                        self.Email.text = email
                                        self.Phone.text = (phoneNumber as! String)
                                        }
                                        
                                    }
                        }
                    }
                }
            }
        })
        
        if status == "active" { //aktivno baranje
            
            DatumZakazano.isHidden = true
            Zakazano.isHidden = true
            Vakcina.isHidden = true
            VakcinaP.isHidden = true
            Datum.isHidden = true
            DatumP.isHidden = true
            QRCodeKopceOutlet.isHidden = true
            Prifati.isHidden = true
            Odbij.setTitle("CANCEL", for: .normal)
            Odbij.isHidden = false
        }else if status == "pending" { //dobiena ponuda
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
            let StringDate = dateFormatter.string(from: DatumPonuda as Date)
            DatumP.text = StringDate
            VakcinaP.text = VakcinaPonuda
            Datum.isHidden = false
            Vakcina.isHidden = false
            VakcinaP.isHidden = false
            DatumP.isHidden = false
            Prifati.isHidden = false
            Odbij.setTitle("REJECT", for: .normal)
            Odbij.isHidden = false
            QRCodeKopceOutlet.isHidden = true
            Zakazano.isHidden = true
            DatumZakazano.isHidden = true
        }else if status == "scheduled" { //zakazana rabota
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
            let StringDate = dateFormatter.string(from: ZakazanoNa as Date)
            DatumZakazano.text = StringDate
            VakcinaP.text = VakcinaPonuda
            Vakcina.isHidden = false
            VakcinaP.isHidden = false
            DatumP.isHidden = true
            Datum.isHidden = true
            DatumZakazano.isHidden = false
            Zakazano.isHidden = false
            Zakazano.text = "Scheduled on:"
            QRCodeKopceOutlet.isHidden = true
            Prifati.isHidden = true
            Odbij.isHidden = true
        }else if status == "done" { //zavrsena rabota
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let StringDate = dateFormatter.string(from: dateFinished as Date)
            DatumZakazano.text = StringDate
            Vakcina.isHidden = true
            VakcinaP.isHidden = true
            DatumP.isHidden = true
            Datum.isHidden = true
            Zakazano.text = "Finished on: "
            DatumZakazano.isHidden = false
            Zakazano.isHidden = false
            //Image.isHidden = false
            Prifati.isHidden = true
            Odbij.isHidden = true
            QRCodeKopceOutlet.isHidden = false
        }
        
    }
    
    
    @IBAction func ShowQRCode(_ sender: Any) {
        
        var ImePrezimeCitizen = String()
        let VakcinaPrimena = self.VakcinaPonuda
        let DatumPrimanje = self.dateFinished
       
        let query = PFUser.query()
        query?.whereKey("tipKorisnik", equalTo: "Citizen" as? String)
//        print("kreira query PrimenaVakcina")
        query?.findObjectsInBackground(block: { (object, error) in
            if error != nil{
                print(error?.localizedDescription)
            }
            else if let citizen = object{
                for c in citizen{
                    if let Cit = c as? PFUser {
//                        print("pocnuva da zima od objektot-PrimenaVakcina")
                        ImePrezimeCitizen = Cit["firstLastName"] as! String
//                        print(ImePrezimeCitizen)
//                        print("staava ime prez-PrimenaVakcina")
                    
                    }
                }
            }
        })
        
        let combinedString = "ImePrezime: \(ImePrezimeCitizen) \n PrimenaVakcina: \(VakcinaPrimena) \n Datum: \(DatumPrimanje)"
        
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
