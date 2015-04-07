//
//  calenderPatientView.swift
//  Memory Moments
//
//  Created by Jack Phillips on 3/28/15.
//  Copyright (c) 2015 Jack Phillips. All rights reserved.
//

//This is the main page class for the patient calender

import UIKit
import CoreData
import Foundation

class calenderPatientView: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var NewEvents = [(Int(), NSDate(), String(), String(), String())];
    var Events = [MainData]()
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    var logTableView = UITableView(frame: CGRectZero, style: .Plain)
    
    @IBOutlet var currentDateText: UILabel! //Var for current date box
    //vars for the date
    var date: NSDate!
    var calendar: NSCalendar!
    var components: NSDateComponents!
    var daysInMonth = [31,28,31,30,31,30,31,31,30,31,30,31];
    var dayString = ["Sun" , "Mon", "Tue", "Wed","Thu","Fri","Sat"];
    
    //screen demintions
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Use optional binding to confirm the managedObjectContext
        
        if let moc = self.managedObjectContext {
            postRequest()
            
            //ONLY FOR MAKING TEST DATA HERE WERE WE WANT TO PULL NEW DATA EVEYTIME
            
            
            
          
        
            var viewFrame = self.view.frame
            //Sets up the Table View
            viewFrame.origin.y += 260
            logTableView.frame = viewFrame
            logTableView.scrollEnabled = false;
            logTableView.rowHeight = 103;
            // Add the table view to this view controller's view
            self.view.addSubview(logTableView)
            // Here, we tell the table view that we intend to use a cell we're going to call "LogCell"
            logTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "LogCell")
            
            // This tells the table view that it should get it's data from this class, ViewController
            logTableView.dataSource = self
            logTableView.dataSource = self
            logTableView.delegate = self
            
            // Loop through, creating items
            
        }
        //gets current date
        date = NSDate()
        calendar = NSCalendar.currentCalendar()
        components = calendar.components(.DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit | .CalendarUnitWeekday,fromDate: date);
        let dateText = "\(components.month)/\(components.day)/\(components.year)";
        currentDateText.text = dateText;
        makeCalendar()
        //save()
        

        

        // Do any additional setup after loading the view.
    }
    //Gets the data from Core Data
    func fetchLog() {
        let fetchRequest = NSFetchRequest(entityName: "MainData")
        
        // Create a sort descriptor object that sorts on the "title"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "time", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MainData] {
            Events = fetchResults
        }
        
    }
    func pullInNewData() {
        fetchLog()
        for (ID, DATE, TYPE, Dis, Title) in NewEvents {
            // Create an individual item
            var used: Bool = false;
            for event in Events {
                if (event.evtid == ID){
                    used = true;
                }
            }
            if(!used){
                MainData.createInManagedObjectContext(self.managedObjectContext!, evtid: ID, time: DATE, type: TYPE, descrition: Dis, Title: Title)
            }
        }
        self.fetchLog()
        logTableView.reloadData()
        save()
        
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // How many rows are there in this section?
        // There's only 1 section, and it has a number of rows
        // equal to the number of logItems, so return the count
        return Events.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LogCell") as UITableViewCell
        
        // Get the LogItem for this index
        let envents = Events[indexPath.row]
        
        // Set the title of the cell to be the title of the logItem
        cell.textLabel?.text = envents.title
        return cell
    }
    
    //Clicked Event going to next Page
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("EventViewController") as EventViewController
        vc.passedData = Events[indexPath.row];
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    
    
    //Calendar

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func makeCalendar(){
        let screenWidth = screenSize.width
        
        //displays the days of week
        for i in 0...6 {
            var days = UILabel(frame: CGRect(x: (CGFloat(i) * screenWidth * CGFloat(0.1428)), y: 90, width: (screenWidth * CGFloat(0.1428)), height: 30))
            days.layer.borderWidth = 0.5;
            days.textAlignment = NSTextAlignment.Center;
            days.layer.borderColor = UIColor.blackColor().CGColor!;
            days.text = dayString[i];
            self.view.addSubview(days);
        }
    
        
        //Displays Days around the current day
        var day = components.day - (components.weekday-1);
        if(day < 1) {
            day = daysInMonth[components.month - 2] + day - 1;
        }
        for i in 0...13 {
            if(day > daysInMonth[components.month - 1]){
                day = 1;
            }
            if(components.day == day) {
                //prints current day
                var current = UILabel(frame: CGRect(x: (CGFloat(components.weekday-1) * screenWidth * CGFloat(0.1428)), y: 120, width: (screenWidth * CGFloat(0.1428)), height: 50))
                current.backgroundColor = UIColor.redColor();
                current.layer.borderWidth = 0.5;
                current.textAlignment = NSTextAlignment.Center;
                current.textColor = UIColor.whiteColor();
                current.layer.borderColor = UIColor.blackColor().CGColor!;
                current.text = "\(day)";
                self.view.addSubview(current);
            } else { //print every other day
                //works to create the next line and to make sure that is starts from the begining
                var a = 0;
                var b = i;
                if(i > 6) {
                    a = 1;
                    b -= 7;
                }
                var days = UILabel(frame: CGRect(x: (CGFloat(b) * screenWidth * CGFloat(0.1428)), y: (CGFloat(120) + (CGFloat(50) * CGFloat(a))), width: (CGFloat(screenWidth) * CGFloat(0.1428)), height: 50));
                days.layer.borderWidth = 0.5;
                days.textAlignment = NSTextAlignment.Center;
                days.layer.borderColor = UIColor.blackColor().CGColor!;
                days.text = "\(day)";
                self.view.addSubview(days);
                
            }
            day++;
        }
        

    }
    func save() {
        var error : NSError?
        if(managedObjectContext!.save(&error) ) {
            print("HERE")
            println(error?.localizedDescription)
        }
    }
    
    func postRequest() {
        var url: NSURL = NSURL(string: "http://aakatz3.asuscomm.com:8085/mobile/updateevents.php")!
        var request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        var bodyData = "pid=2"
        request.HTTPMethod = "POST"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
            {
                (response, data, error) in
                println("\(data)")
                var arr: [AnyObject];
                if let array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)  as? [AnyObject] {
                    arr = array;
                }else{
                    arr = [];
                }
                
                for event in arr {
                    let evtid = event["evtid"] as Int;
                    let dates = event["time"] as String;
                    let formatter = NSDateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    formatter.timeZone = NSTimeZone(name: "Asia/Dubai")
                    let date = formatter.dateFromString(dates)
                    let type = event["type"] as String;
                    let descrition = event["description"] as String;
                    println("\(date)")
                    self.NewEvents.append(evtid, date!, type, descrition, "No Title Item Yet");
                }
                self.NewEvents.removeAtIndex(0);
                self.pullInNewData()
                
        }
        
    }
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


