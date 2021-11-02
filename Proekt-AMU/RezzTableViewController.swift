//
//  RezzTableViewController.swift
//  Proekt-AMU
//
//  Created by Angela Tasikj on 8/26/21.
//  Copyright © 2021 Angela Tasikj. All rights reserved.
//

import UIKit
import Parse

class RezzTableViewController: UITableViewController {
    var index = Int()
    var datumii = [NSDate]()
    var DoctorIds = [String]()
    var statusi = [String]()
    var bolesti = [String]()
    var datumPonuda = [NSDate]()
    var VakcinaPonuda = [String]()
    var DatumZavrsuvanje = [NSDate?]()
    
    
    var refresher: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTable()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(ReqResTableViewController.updateTable), for: UIControl.Event.valueChanged)
        self.view.addSubview(refresher)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return datumii.count
    }
    
    @objc func updateTable() {
        //print("Ja update-ira tabelata")
        datumii.removeAll()
        DoctorIds.removeAll()
        statusi.removeAll()
        bolesti.removeAll()
        DatumZavrsuvanje.removeAll()
        datumPonuda.removeAll()
        VakcinaPonuda.removeAll()
        
        let query = PFQuery(className: "Rezz")
//        print("kreira query")
        query.whereKey("from", equalTo: PFUser.current()?.objectId)
        query.addDescendingOrder("date")
        query.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            }else if let object = objects {
                for obj in object {
//                    print("niz objektot")
                    if let datumB = obj["date"] {
                        //print(datumB)
                        if let status = obj["status"]{
                            if let DoctorId = obj["to"]{
//                                print(DoctorId)
                                if let desc = obj["description"]{
                                    //if let vakcinaa = obj["Vakcina"]{
//                                        print("VAKCINATA ja stavi vo obj")
                                        self.datumii.append(datumB as! NSDate)
                                        self.DoctorIds.append(DoctorId as! String)
                                        self.statusi.append(status as! String)
                                        self.bolesti.append(desc as! String)
                                    
                                        if let DateTime = obj["DateTime"] {
                                            if let Vakcina = obj["vakcina"] {
                                                self.VakcinaPonuda.append(Vakcina as! String)
                                                self.datumPonuda.append(DateTime as! NSDate)
//                                                print("vakcinata i datumot postsaveni")
                                            }
                                        }else{
                                            self.datumPonuda.append(NSDate())
                                        }
                                        if let fDate = obj["finishDate"]{
                                            self.DatumZavrsuvanje.append(fDate as! NSDate)
                                        }else {
                                            self.DatumZavrsuvanje.append(nil)
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let DoctorId = DoctorIds[indexPath.row]
        let query = PFUser.query()
        query?.whereKey("objectId", equalTo: DoctorId)
        query?.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            }else if let obj = objects {
                for o in obj {
                    if let Doctor = o as? PFUser{
                        if let firstLastName = Doctor["firstLastName"]{
//                            print(firstLastName)
                            //print(lastName)
                            cell.textLabel?.text = firstLastName as! String
                        }
                    }
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let StringDate = dateFormatter.string(from: self.datumii[indexPath.row] as! Date)
                cell.detailTextLabel?.text = StringDate
                print("stava datum")
                let status = self.statusi[indexPath.row]
                if status == "active" {
                    cell.backgroundColor = UIColor.purple
                }else if status == "pending" {
                    cell.backgroundColor = UIColor.gray
                }else if status == "scheduled" {
                    cell.backgroundColor = UIColor.cyan
                }else if status == "done"{
                    cell.backgroundColor = UIColor.darkGray
                }
            }
        })
        
        return cell
//        print("vrakja")
    }
  
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     index = (tableView.indexPathForSelectedRow?.row)!
     performSegue(withIdentifier: "RezDetailsSeg", sender: nil)
     }
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     if segue.identifier == "RezDetailsSeg" {
     let destinationVC = segue.destination as! RezzDetailsViewController
     destinationVC.DoctorId = DoctorIds[index]
     destinationVC.dataReq = datumii[index]
     destinationVC.status = statusi[index]
     if statusi[index] == "pending"{
     destinationVC.DatumPonuda = datumPonuda[index]
     destinationVC.VakcinaPonuda = VakcinaPonuda[index]
     }else if statusi[index] == "scheduled" {
     destinationVC.DatumPonuda = datumPonuda[index]
     destinationVC.VakcinaPonuda = VakcinaPonuda[index]
     }else if statusi[index] == "done" {
     //destinationVC.imageFile.append(image[index]!)
     destinationVC.dateFinished = DatumZavrsuvanje[index]!
     }
     }
     }

}
