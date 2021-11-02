//
//  DoctorsTableViewController.swift
//  Proekt-AMU
//
//  Created by Angela Tasikj on 8/20/21.
//  Copyright © 2021 Angela Tasikj. All rights reserved.
//

import UIKit
import Parse
import MapKit
import CoreLocation

class DoctorsTableViewController: UITableViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    let locationManager = CLLocationManager()
    
    var ImePrezime = [String]()
    var datumi = [NSDate]()
    var bolesti = [String]()
    var lokacii = [String]()
    var phones = [String]()
    var emails = [String]()
    var longitudes = [Double]()
    var latitudes = [Double]()
    var index = Int()
    var currLat = Double()
    var currLong = Double()
    var Vakcini = [String]()
    
    var refresher:UIRefreshControl = UIRefreshControl()

    @IBAction func logout(_ sender: Any) {
        PFUser.logOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTable()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(DoctorsTableViewController.updateTable)
            , for: UIControl.Event.valueChanged)
        self.view.addSubview(refresher)
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }

    @objc func updateTable() {
        ImePrezime.removeAll()
        datumi.removeAll()
        bolesti.removeAll()
        emails.removeAll()
        longitudes.removeAll()
        latitudes.removeAll()
        phones.removeAll()
        lokacii.removeAll()
        Vakcini.removeAll()
        
        
        let query = PFQuery(className: "Rezz")
//        print("se kreira query")
        query.whereKey("to", equalTo: PFUser.current()?.objectId)
        query.whereKey("status", equalTo: "active")
        query.addDescendingOrder("date")
        query.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            }else if let obj = objects {
                for object in obj {
//                    print("vlaga vo for-ot")
                    if let userId = object["from"] {
//                        print("from")
                        if let datum = object["date"]{
//                            print("date")
                            if let bolest = object["description"]{
                                if let lokacija = object["location"]{
//                                    print("loc")
                                    if let vakcina = object["Vakcina"]{
//                                        print("vakcina")
//                                        print("Vakcinata e stavena")
                                    if let lat = object["lat"]{
                                        if let long = object["lon"]{
                                            let userQuery = PFUser.query()
                                            userQuery?.whereKey("objectId", equalTo: userId)
                                            userQuery?.findObjectsInBackground(block: { (users, error) in
                                                if error != nil {
                                                    print(error?.localizedDescription)
                                                }else if let userss = users{
                                                    for user in userss{
                                                        if let u = user as? PFUser {
//                                                            print("pocnuva da polni")
                                                            //print(u)
                                                            if let NameSurname = u["firstLastName"]{
                                                                
                                                                    if let pNubmer = u["phoneNumber"]{
                                                                        if let email = u.username{
                                                                            self.ImePrezime.append(NameSurname as! String)
                                                                           
                                                                            self.phones.append(pNubmer as! String)
                                                                            self.emails.append(email)
                                                                            self.datumi.append(datum as! NSDate)
                                                                           
                                                                        
                                                                  self.Vakcini.append(vakcina as! String)
//                                                                 print("stava vakcina")
                                                                            self.bolesti.append(bolest as! String)
                                                                            
//                                                                            print("stava bolest")
                                                                            self.lokacii.append(lokacija as! String)
                                                                            self.latitudes.append(lat as! Double)
                                                                            self.longitudes.append(long as! Double)
                                                                            
                                                                        }
                                                                    
                                                                }
                                                            }
                                                        
                                                    }
                                                    }
                                                }
                                                self.refresher.endRefreshing()
                                                self.tableView.reloadData()
//                                                print("ixvrusva i ova")
                                            })
                                        }
                                        }
                                    }
                                }
                                }
                            }
                        
                        
                    }
                }
            }
            self.refresher.endRefreshing()
            self.tableView.reloadData()
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ImePrezime.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "kelija", for: indexPath)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let StringDate = dateFormatter.string(from: self.datumi[indexPath.row] as! Date)
        cell.textLabel?.text = StringDate
        cell.detailTextLabel?.text = ImePrezime[indexPath.row]
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = (tableView.indexPathForSelectedRow?.row)!
        performSegue(withIdentifier: "DetailsCitizenSeg", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailsCitizenSeg" {
            let destVC = segue.destination as! CitizenDetailsViewController
            destVC.ImePrezime = ImePrezime[index]
            destVC.lokacija = lokacii[index]
            destVC.email = emails[index]
            destVC.tel = phones[index]
            destVC.datum = datumi[index]
            destVC.lat = latitudes[index]
            destVC.lon = longitudes[index]
            destVC.bolest = bolesti[index]
//            print("bolest")
            destVC.vakcina = Vakcini[index]
//            print("vakcina")
        }
    }

}
