//
//  DetailViewController.swift
//  myFlickr
//
//  Created by student on 6/23/17.
//  Copyright © 2017 student. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    @IBOutlet weak var uiDetailView: UIImageView!

   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: FlickrPhoto? {
        didSet{
        let urlRequest = URLRequest(url: detailItem?.url as! URL)
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: OperationQueue.main, completionHandler: { (response, data, error) -> Void in
             self.uiDetailView.image = UIImage(data: data!)
        })
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return uiDetailView
    }

}

