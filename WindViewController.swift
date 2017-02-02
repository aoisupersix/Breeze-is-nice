//
//  WindViewController.swift
//  Breezeisnice
//
//  Created by 田中葵 on 2017/02/02.
//  Copyright © 2017年 田中葵. All rights reserved.
//

import UIKit

protocol WindViewControllerDelegate {
    func refresh(_ sender: Any)
}

class WindViewController: UIViewController {
    
    var delegate: WindViewControllerDelegate?
    
    @IBAction func refresh(_ sender: Any) {
        delegate!.refresh(sender)
    }
    
    /*
     *  ContainerViewと紐付け
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MainViewContainer" {
            print("紐付け")
            let viewController = segue.destination as! ViewController
            self.delegate = viewController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
