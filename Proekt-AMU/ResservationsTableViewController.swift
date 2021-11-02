//
//  ResservationsTableViewController.swift
//  Proekt-AMU
//
//  Created by Angela Tasikj on 8/28/21.
//  Copyright © 2021 Angela Tasikj. All rights reserved.
//

import UIKit
import Parse

class ResservationsTableViewController: UITableViewController {
    
    
    var datumi = [NSDate]()
    var statusi = [String]()
    var IminjaPreziminja = [String]()
    var phones = [String]()
    var emails = [String]()
    var vakcini = [String]()
    var lats = [Double]()
    var longs = [Double]()
    var finishDates = [NSDate?]()
    var adresiDefekt = [String]()
    var rezzIds = [String]()
    
    
    var refresher: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTable()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(ResservationsTableViewController.updateTable), for: UIControl.Event.valueChanged)
        self.view.addSubview(refresher)
        
    }
    
    @objc func updateTable() {
        statusi.removeAll()
        IminjaPreziminja.removeAll()
        datumi.removeAll()
        phones.removeAll()
        emails.removeAll()
        vakcini.removeAll()
        lats.removeAll()
        longs.removeAll()
        finishDates.removeAll()
        rezzIds.removeAll()
        
        let array = ["done", "scheduled"]
        let predicate = NSPredicate(format: "status = %@ OR status = %@", argumentArray: array)
        let query = PFQuery(className: "Rezz", predicate: predicate)
        //print("kreiravme query vo RabotiTableViewCont")
        query.whereKey("to", equalTo: PFUser.current()?.objectId)
        query.addDescendingOrder("DateTime")
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else if let object = objects {
                for obj in object {
//                    print("vlaga vo forot")
                    if let status = obj["status"] {
//                        print(status)
                        if let date = obj["DateTime"] {
                                if let lat = obj["lat"] {
                                    if let lon = obj["lon"] {
                                        if let fDate = obj["finishDate"] {
                                            self.finishDates.append(fDate as! NSDate)
                                        }else {
                                            self.finishDates.append(nil)
                                        }
                                        if let rezzId = obj.objectId {
                                            
                                            if let userId = obj["from"] {
                                                if let vakcina = obj["vakcina"] {
                                                    
                                                    let userQuery = PFUser.query()
//                                                    print("se kreira UserQuery")
                                                    userQuery?.whereKey("objectId", equalTo: userId)
                                                    userQuery?.findObjectsInBackground(block: { (users, error) in
                                                        if error != nil {
                                                            print(error?.localizedDescription)
                                                        } else if let user = users {
                                                            for u in user{
                                                                if let u = u as? PFUser {
//                                                                    print(u)
                                                                    if let fLName = u["firstLastName"] {
//                                                                        print("se stava ime prez od user vo query")
                                                                            if let email = u.username {
//                                                                                print("if email")
                                                                                if let pNumber = u["phoneNumber"] {
                                                                                         self.datumi.append(date as! NSDate)
//                                                                                        print("stava data")
                                                                                        self.statusi.append(status as! String)
//                                                                                        print("stava status")
                                                                                        self.IminjaPreziminja.append(fLName as! String)
                                                                                    
                                                                                        self.phones.append(pNumber as! String)
//                                                                                        print("stava tel")
                                                                                        self.emails.append(email)
//                                                                                        print("stava emai")
                                                                                        self.lats.append(lat as! Double)
                                                                                        self.longs.append(lon as! Double)
                                                               
                                                                                                                self.rezzIds.append(rezzId as! String)
                                                                                    
                                                                                        self.vakcini.append(vakcina as! String)
//                                                                                        print("staviii vakcinaaaa vo reservations contorolerot")
                                                                                    
                                                                                    
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
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return statusi.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "kelija", for: indexPath)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let StringDate = dateFormatter.string(from: self.datumi[indexPath.row] as! Date)
        cell.textLabel?.text = StringDate
        cell.detailTextLabel?.text = IminjaPreziminja[indexPath.row]
        if statusi[indexPath.row] == "scheduled" {
            cell.backgroundColor = .cyan
        }else {
            cell.backgroundColor = .purple
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "konRezz" {
            if let index = tableView.indexPathForSelectedRow?.row {
                let destinationVC = segue.destination as! DetailViewController
                destinationVC.ImePrezime = IminjaPreziminja[index]
                destinationVC.status = statusi[index]
                destinationVC.phone = phones[index]
                destinationVC.lat = lats[index]
                destinationVC.email = emails[index]
                destinationVC.long = longs[index]
                destinationVC.datum = datumi[index]
                destinationVC.rezzId = rezzIds[index]
                destinationVC.vakcina = vakcini[index]
                if statusi[index] == "done" {
                    destinationVC.DatumZavrsuvanje = finishDates[index]!
                    
                }
            }
        }
    }

}
