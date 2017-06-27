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
    var photoArray: [FlickrPhoto] = []
    var descriptions: [String] = []
    var imagesTmp:[FlickrPhoto] = []

    

    @IBOutlet weak var photoTitle: UILabel!
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
        
        photoArray = []
        let flickrInteresting = FKFlickrInterestingnessGetList()
        flickrInteresting.per_page = "15"
        
        
        FlickrKit.shared().call(flickrInteresting) { (response, error) -> Void in
            
            DispatchQueue.main.async(execute: { () -> Void in
                if let response = response, let photoArray = FlickrKit.shared().photoArray(fromResponse: response) {
                    // Pull out the photo urls from the results
                    for photoDictionary in photoArray {
                        let photoURL = FlickrKit.shared().photoURL(for: FKPhotoSize.medium800, fromPhotoDictionary: photoDictionary)
                        let thumbnailURL = FlickrKit.shared().photoURL(for: FKPhotoSize.smallSquare75, fromPhotoDictionary: photoDictionary)
                        let title = photoDictionary["title"] as! String
                        let id = photoDictionary["id"] as! String
                        var photo = FlickrPhoto(id: id,title: title, url : photoURL as NSURL, thumbnailurl:thumbnailURL as NSURL, imageSmall: nil, ImageBig: nil)
                        self.photoArray.append(photo)
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
        
        photoArray = []
        let photoSearch = FKFlickrPhotosSearch()
        photoSearch.text = mySearch
        photoSearch.sort = "relevance"
        photoSearch.media = "photos"
        photoSearch.per_page = "15"
        
        FlickrKit.shared().call(photoSearch) { (response, error) -> Void in
            
            DispatchQueue.global(qos: .userInitiated).async(execute: { () -> Void in
                if let response = response, let photoArray = FlickrKit.shared().photoArray(fromResponse: response) {
                    for photoDictionary in photoArray {
                        let photoURL = FlickrKit.shared().photoURL(for: FKPhotoSize.original, fromPhotoDictionary: photoDictionary)
                        let thumbnailURL = FlickrKit.shared().photoURL(for: FKPhotoSize.smallSquare75, fromPhotoDictionary: photoDictionary)
                        let id = photoDictionary["id"] as! String
                        let title = photoDictionary["title"] as! String

                        var photo = FlickrPhoto(id : id,title: title, url : photoURL as NSURL, thumbnailurl:thumbnailURL as NSURL, imageSmall: nil, ImageBig: nil)
                        self.photoArray.append(photo)
                        let getSizes = FKFlickrPhotosGetSizes()
                        getSizes.photo_id = id
                        FlickrKit.shared().call(getSizes){ (response, error) in
                            guard error == nil else{
                                return
                            }
                            if let response = response {
                                let size = (response["sizes"] as! [String: AnyObject])["size"] as!
                                [[String: AnyObject]]
                                findSize: for sizeString in ["Original", "Large", "Medium 800", "Medium 600", "Medium", "Small 320", "Small"]{
                                    
                                }
                            }
                        }
                    }
                    self.loadImages()
                    
                   
    }
    
            })
        }
        
        
    }
    func loadImages()  {
        self.imagesTmp = []
        descriptions = []
    for var url in self.photoArray {
        let urlRequest = URLRequest(url: url.thumbnailurl as URL)
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: OperationQueue.main, completionHandler: { (response, data, error) -> Void in
            let image = UIImage(data: data!)
            url.imageSmall = image!
            self.getDescription()
            self.imagesTmp.append(url)

        })
    }
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
              }

    func getDescription () {
        
        descriptions = []
        //getDescription
        let getInfo = FKFlickrPhotosGetInfo()
        for photoInStruct in photoArray{
        getInfo.photo_id = photoInStruct.id
        DispatchQueue.main.async(execute: { () -> Void in
            FlickrKit.shared().call(getInfo) { (response, error) in
                guard error == nil else {
                    return
                }
                if let response = response {
                    let photo = response["photo"] as! [String: AnyObject]
                    self.descriptions.append(((photo["description"] as! [String: AnyObject])["_content"] as? String)!)
                    
                }
                
            }
        })

        }

    }
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let item = imagesTmp[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = item
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PhotoTableViewCell
    
    
        //Load photos
        if imagesTmp.count > 0 {
        let object = imagesTmp[indexPath.row].imageSmall
        cell.imageView?.image = object
        }
        if !imagesTmp.isEmpty{
            cell.photoTitle.text = imagesTmp[indexPath.row].title
            
            if descriptions.count > 0 {
                cell.photoDescription.text = descriptions[indexPath.row]
            }
         
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

class PhotoTableViewCell: UITableViewCell {
    @IBOutlet weak var photoTitle: UILabel!
    
    @IBOutlet weak var photoDescription: UILabel!
}
