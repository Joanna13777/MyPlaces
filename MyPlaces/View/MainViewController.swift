//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Жанна Сергеевна  on 09/03/26.
//

import UIKit
import CoreData

class MainViewController: UITableViewController {
    
    var context: NSManagedObjectContext!
    var places = Place.getPlaces()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let place = places[indexPath.row]

        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        
        if place.image == nil {
            cell.imageOfPlaces.image = UIImage(named: place.restaurantImage!)
        } else {
            cell.imageOfPlaces.image = place.image
        }
        
        cell.imageOfPlaces.layer.cornerRadius = cell.imageOfPlaces.frame.size.height / 2
        cell.imageOfPlaces.clipsToBounds = true

        return cell
    }
    
    
  


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
   // override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
  //  }

    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
        guard let newPlaceCV = segue.source as? NewPlaceViewController  else { return }
        
        newPlaceCV.saveNewPlace()
        places.append(newPlaceCV.newPlace!)
        tableView.reloadData()
        
    }

}
