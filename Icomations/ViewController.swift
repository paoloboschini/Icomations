//
//  ViewController.swift
//  Icomations
//
//  Created by Paolo Boschini on 03/02/15.
//  Copyright (c) 2015 Paolo Boschini. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    private var data = ["Duration: ", "Rotations: "]
    private var steppers = [UIStepper(), UIStepper()]
    
    @IBOutlet var arrowUp: Icomation!
    @IBOutlet var arrowDown: Icomation!
    @IBOutlet var arrowLeft: Icomation!
    @IBOutlet var arrowRight: Icomation!
    @IBOutlet var close: Icomation!
    @IBOutlet var smallArrowUp: Icomation!
    @IBOutlet var smallArrowDown: Icomation!
    @IBOutlet var smallArrowLeft: Icomation!
    @IBOutlet var smallArrowRight: Icomation!
    @IBOutlet var smallClose: Icomation!
    var icons: [Icomation]!
    
    init() {
        super.init(nibName: "View", bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delaysContentTouches = false
        steppers[0].stepValue = 0.1
        steppers[0].value = 1.0
        data[0] = "Duration: \(steppers[0].value)"

        steppers[1].stepValue = 1
        data[1] = "Rotations: \(Int(steppers[1].value))"
        
        arrowUp.type = IconType.ArrowUp
        arrowDown.type = IconType.ArrowDown
        arrowLeft.type = IconType.ArrowLeft
        arrowRight.type = IconType.ArrowRight

        smallArrowUp.type = IconType.SmallArrowUp
        smallArrowDown.type = IconType.SmallArrowDown
        smallArrowLeft.type = IconType.SmallArrowLeft
        smallArrowRight.type = IconType.SmallArrowRight

        close.type = IconType.Close
        smallClose.type = IconType.SmallClose

        icons = [arrowUp, arrowDown, arrowLeft, arrowRight, smallArrowUp, smallArrowDown, smallArrowLeft, smallArrowRight, close, smallClose]
        
        title = "Icomations"

        // Add icomation via code
//        var icomation = Icomation(frame: CGRectMake(0, 0, 50, 50))
//        icomation.type = IconType.ArrowUp
//        icomation.animationDuration = 1.0
//        icomation.numberOfRotations = 3
//        
//        icomation.topShape.strokeColor = UIColor.redColor().CGColor
//        icomation.middleShape.strokeColor = UIColor.whiteColor().CGColor
//        icomation.bottomShape.strokeColor = UIColor.blackColor().CGColor
//        tableView.addSubview(icomation)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
        cell.textLabel?.text = data[indexPath.row]
        steppers[indexPath.row].addTarget(self, action: "valueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        cell.accessoryView = steppers[indexPath.row]
        return cell
    }
    
    func valueChanged(stepper: UIStepper) {
        if stepper == steppers[0] {
            for icon in icons {
                icon.animationDuration = stepper.value
            }
            data[0] = "Duration: \(stepper.value)"
        }
        if stepper == steppers[1] {
            for icon in icons {
                icon.numberOfRotations = stepper.value
            }
            data[1] = "Rotations: \(Int(stepper.value))"
        }
        tableView.reloadData()
    }
}