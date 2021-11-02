//
//  MakeReqViewController.swift
//  Proekt-AMU
//
//  Created by Angela Tasikj on 8/23/21.
//  Copyright © 2021 Angela Tasikj. All rights reserved.
//

import UIKit
import Parse

class MakeReqViewController: UIViewController {

    var dates = [NSDate]()
    var DoctorId = String()
    var bolest = String()
    var lokacija = String()
    var lon = Double()
    var lat = Double()
    var ImePrezime = String()
    var vakcina = String()
    
    @IBAction func Req(_ sender: Any) {
        let request = PFObject(className: "Rezz")
        request["from"] = PFUser.current()?.objectId
        print("from stava")
        request["to"] = DoctorId
        print("doctor id")
        request["date"] = NSDate()
        request["status"] = "active"
        request["description"] = bolest
        request["location"] = lokacija
        request["lon"] = lon
        request["lat"] = lat
        request["Vakcina"] = vakcina
        print("se napolni objektot  po pritiskanje na kopceto MAKE A RESERVATION i vakcinata se stavi vo obj")
        request.saveInBackground() { (succes,error) in
            if succes {
                self.displayAlert(title: "Succesful", message: "Make a request")
            }else{
                self.displayAlert(title: "It's not succesfull", message:(error?.localizedDescription)! )
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        let DoctorQuery = PFUser.query()
        DoctorQuery?.whereKey("tipKorisnik", equalTo: "Doctor")
        DoctorQuery?.whereKey("firstLastName", equalTo: ImePrezime)
        
        DoctorQuery?.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else if let object = objects {
                for obj in object {
                    if let o = obj as? PFUser {
                        if let objectId = o.objectId {
                            self.DoctorId = objectId
                        }
                    }
                }
            }
        })
    }
    

    func displayAlert(title: String, message: String) {
        let allertContoller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        allertContoller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(allertContoller,animated: true,completion: nil)
    }
    
    func fetchData(){
        
        self.dates.removeAll()
        let doctorQ = PFUser.query()
        doctorQ?.whereKey("tipKorisnik", equalTo: "Doctor")
        doctorQ?.whereKey("firstLastame", equalTo: ImePrezime)
        
        doctorQ?.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else if let object = objects {
                for obj in object {
                    if let o = obj as? PFUser {
                        if let objectId = o.objectId {
                            let query = PFQuery(className: "Rezz")
                            query.whereKey("to", equalTo: objectId)
                            query.whereKey("status", equalTo: "done")
                            query.findObjectsInBackground(block: { (jobs, error) in
                                if error != nil {
                                    print(error?.localizedDescription)
                                } else if let jobs = jobs {
                                    for job in jobs {
                                        if let datum = job["finishDate"] {
                                           
                                                self.dates.append(datum as! NSDate)
                                            
                                           
                                        }
                                    }
                                }
                                                           })
                        }
                    }
                }
            }
        })
    }
}
