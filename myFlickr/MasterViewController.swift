//
//  MasterViewController.swift
//  myFlickr
//
//  Created by student on 6/23/17.
//  Copyright © 2017 student. All rights reserved.
//

import UIKit
import FlickrKit

class MasterViewController: UITableViewController {
  
    var detailViewController: DetailViewController? = nil
    let apiKey:String = "c0a65bfe2f1c606a9a5a041a1678f2d9"
    let sharedSecret:String = "3110d4a7ebefdf30"
    var objects = [Any]()
    var photoURLs: [URL]!
    var images:[UIImage] = []
    
    @IBOutlet weak var searchTextView: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    //DataSource auf diesen Controller setzen
    @IBOutlet var myTableView: UITableView! {
        didSet {
            myTableView.dataSource = self
        }
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoURLs = []
        self.tableView.contentInset = UIEdgeInsets(top: 60,left: 0,bottom: 0,right: 0)
        self.myTableView.tableHeaderView = searchController.searchBar
        
        searchController.dimsBackgroundDuringPresentation = false
        
        FlickrKit.shared().initialize(withAPIKey: apiKey, sharedSecret: sharedSecret)
       
        findInteresting()
        loadImages()
        
                    // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func findInteresting(){
        
        let flickrInteresting = FKFlickrInterestingnessGetList()
        flickrInteresting.per_page = "15"
        
        
        FlickrKit.shared().call(flickrInteresting) { (response, error) -> Void in
            
            DispatchQueue.main.async(execute: { () -> Void in
                if let response = response, let photoArray = FlickrKit.shared().photoArray(fromResponse: response) {
                    // Pull out the photo urls from the results
                    for photoDictionary in photoArray {
                        let photoURL = FlickrKit.shared().photoURL(for: FKPhotoSize.small240, fromPhotoDictionary: photoDictionary)
                        self.photoURLs.append(photoURL)
                    }
                    self.loadImages()
                    //self.performSegue(withIdentifier: "SegueToPhotos", sender: self)
                } else {
                    // Iterating over specific errors for each service
                    if let error = error as? NSError {
                        switch error.code {
                        case FKFlickrInterestingnessGetListError.serviceCurrentlyUnavailable.rawValue:
                            break;
                        default:
                            break;
                        }
                        
                        let alert = UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                }
            })
        }

    }
    
    func findImages(mySearch:String){
        
        photoURLs = []
        let photoSearch = FKFlickrPhotosSearch()
        photoSearch.text = mySearch
        photoSearch.sort = "relevance"
        photoSearch.media = "photos"
        photoSearch.per_page = "15"
        
        FlickrKit.shared().call(photoSearch) { (response, error) -> Void in
            
            DispatchQueue.main.async(execute: { () -> Void in
                if let response = response, let photoArray = FlickrKit.shared().photoArray(fromResponse: response) {
                    for photoDictionary in photoArray {
                        let photoURL = FlickrKit.shared().photoURL(for: FKPhotoSize.small240, fromPhotoDictionary: photoDictionary)
                        self.photoURLs.append(photoURL)
                    }
    }
    
            })
        }
        loadImages()
        
    }
    func loadImages()  {

    for url in self.photoURLs {
        let urlRequest = URLRequest(url: url)
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: OperationQueue.main, completionHandler: { (response, data, error) -> Void in
            let image = UIImage(data: data!)
            self.images.append(image!)
        })


    }
              }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let image = images[indexPath.row] 
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = image
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
        //Load photos
        if images.count > 0 {
        let object = images[indexPath.row]
        cell.imageView?.image = object
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    @IBAction func onSearchButtonClicked(_ sender: UIButton) {
        let mySearch:String = searchTextView.text!
        findImages(mySearch: mySearch)
    }

}

