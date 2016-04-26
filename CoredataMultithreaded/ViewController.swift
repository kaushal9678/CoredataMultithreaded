//
//  ViewController.swift
//  CoredataMultithreaded
//
//  Created by Mahir Abdi on 25/04/16.
//  Copyright © 2016 kaushal. All rights reserved.
//

import UIKit
import CoreData
class ViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {

    let restAPIManager = RestAPIManager()
    var arrayProducts = NSMutableArray()
    let coreDataStack = CoreDataStack()
    
    @IBOutlet weak var tableView_: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView_.delegate = self;
        tableView_.dataSource  = self;
    }
   
  override  func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    arrayProducts .removeAllObjects()
   // arrayProducts =  fetchRecordsFromProducTable();
    //
     arrayProducts = fetchCountrieFromTable();
    
  /*  if arrayProducts.count > 0{
        tableView_ .reloadData()
    }else{
        createUserInBackground()
    }*/
    
    if arrayProducts.count > 0{
        tableView_ .reloadData()
    }else{
        saveCountry()
    }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  
    
    private func createUserInBackground() {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.createUser()
        }
    }
    
    private func createUser() {
       
        
        var dictParam:[String:AnyObject]!
        dictParam = ["":""]
     let  URLString = "ListFeaturedProducts"
        restAPIManager.postparamsUsingAlamofire(dictParam, url: URLString) { (succeeded, result) -> () in
            
            let flag:NSInteger = (result?.valueForKey("status")?.integerValue)!;
            var message = "";
            if let messageServer = result?.valueForKey("message") as? String{
                message = messageServer;
            }else{
                message = "There is some problem. Please try again!"
            }
           
            if flag == 1{
                // KeychainWrapper .removeObjectForKey("category")
                if self.arrayProducts.count > 0{
                    self.arrayProducts .removeAllObjects();
                }
                self.arrayProducts = (result?.valueForKey("data")as? NSMutableArray)!.mutableCopy() as! NSMutableArray;
                print("array response = %@",self.arrayProducts);
                
               // self.allPhotos = Product.allProduct(self.arrayProducts as! NSArray);
               
                
                                for dict in self.arrayProducts{
                    
                    if let newPrivateQueueContext =
                        self.coreDataStack.newPrivateQueueContext()
                    {
                        newPrivateQueueContext.performBlock {
                            let newRecord =
                                NSEntityDescription
                                    .insertNewObjectForEntityForName("Products",
                                        inManagedObjectContext: newPrivateQueueContext)
                                    as! Products
                            
                            newRecord.name = dict.valueForKey("Name")as? String
                            newRecord.image = dict.valueForKey("Image")as? String
                            newRecord.productID = dict.valueForKey("ProductID")as? String
                            // newUser.email = "dude@rubikscube.com"
                            
                            newPrivateQueueContext.saveRecursively()
                        }
                    }
                    self.tableView_ .reloadData()
                }
              }else{
                let alertController = UIAlertController(title: "Information", message: message, preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(defaultAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    private func saveCountry() {
        
        
        var dictParam:[String:AnyObject]!
        dictParam = ["":""]
        let  URLString = "ListCountry"
        restAPIManager.postparamsUsingAlamofire(dictParam, url: URLString) { (succeeded, result) -> () in
            
            let flag:NSInteger = (result?.valueForKey("status")?.integerValue)!;
            var message = "";
            if let messageServer = result?.valueForKey("message") as? String{
                message = messageServer;
            }else{
                message = "There is some problem. Please try again!"
            }
            
            if flag == 1{
                // KeychainWrapper .removeObjectForKey("category")
                if self.arrayProducts.count > 0{
                    self.arrayProducts .removeAllObjects();
                }
                self.arrayProducts = (result?.valueForKey("data")as? NSMutableArray)!.mutableCopy() as! NSMutableArray;
                print("array response = %@",self.arrayProducts);
                
                // self.allPhotos = Product.allProduct(self.arrayProducts as! NSArray);
                
                
                for dict in self.arrayProducts{
                    
                    if let newPrivateQueueContext =
                        self.coreDataStack.newPrivateQueueContext()
                    {
                        newPrivateQueueContext.performBlock {
                            let newRecord =
                                NSEntityDescription
                                    .insertNewObjectForEntityForName("Country",
                                        inManagedObjectContext: newPrivateQueueContext)
                                    as! Country
                            
                            newRecord.country_id = dict.valueForKey("country_id")as? String
                            newRecord.name = dict.valueForKey("name")as? String
                            //newRecord.productID = dict.valueForKey("ProductID")as? String
                            // newUser.email = "dude@rubikscube.com"
                            
                            newPrivateQueueContext.saveRecursively()
                        }
                    }
                    
                }
                self.tableView_ .reloadData()
            }else{
                let alertController = UIAlertController(title: "Information", message: message, preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(defaultAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        
    }

    
   // fetch products from database
    func fetchRecordsFromProducTable() -> NSMutableArray {
       
        var arrayRecords = NSMutableArray();
        let fetchRequest = NSFetchRequest();
        // Create Entity Description
       
        if let newPrivateQueueContext =
            coreDataStack.newPrivateQueueContext()
        {
            newPrivateQueueContext.performBlockAndWait({ 
                let entityDescription = NSEntityDescription.entityForName("Products",inManagedObjectContext: newPrivateQueueContext)
                
                fetchRequest.entity = entityDescription
                
                do {
                    let result = try newPrivateQueueContext.executeFetchRequest(fetchRequest)
                    print(result)
                    
                    for managedObject in result {
                        let dict = NSMutableDictionary()
                        
                        dict .setObject(managedObject.valueForKey("ProductID")!, forKey: "ProductID")
                        dict .setObject(managedObject.valueForKey("name")!, forKey: "name")
                        dict.setObject(managedObject.valueForKey("image")!, forKey: "Image")
                        
                        arrayRecords .addObject(dict)
                    }
                    
                    
                } catch {
                    let fetchError = error as NSError
                    print(fetchError)
                }
   
            
            })
         
        }
        return arrayRecords;
        }
    
    
    // fetch products from database
    func fetchCountrieFromTable() -> NSMutableArray {
        
        var arrayRecords = NSMutableArray();
        let fetchRequest = NSFetchRequest();
        // Create Entity Description
        
        if let newPrivateQueueContext =
            coreDataStack.newPrivateQueueContext()
        {
            newPrivateQueueContext.performBlockAndWait({
                let entityDescription = NSEntityDescription.entityForName("Country",inManagedObjectContext: newPrivateQueueContext)
                
                fetchRequest.entity = entityDescription
                
                do {
                    let result = try newPrivateQueueContext.executeFetchRequest(fetchRequest)
                    print(result)
                    
                    for managedObject in result {
                        let dict = NSMutableDictionary()
                        
                        dict .setObject(managedObject.valueForKey("country_id")!, forKey: "country_id")
                        dict .setObject(managedObject.valueForKey("name")!, forKey: "name")
                        
                        arrayRecords .addObject(dict)
                    }
                    
                    
                } catch {
                    let fetchError = error as NSError
                    print(fetchError)
                }
                
                
            })
            
        }
        return arrayRecords;
    }

    
    
    //MARK: tableview datasource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayProducts.count
        //return 9;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "CustomCell";
        let cell = tableView .dequeueReusableCellWithIdentifier(cellIdentifier)as? CustomCell
        let dict = arrayProducts[indexPath.row]
       // cell?.labelTitle?.textColor = UIColor.redColor()
        cell?.labelTitle?.text = dict.valueForKey("name")as? String;
        return cell!;
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44;
    }
}

