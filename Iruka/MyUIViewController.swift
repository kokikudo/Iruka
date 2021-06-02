//
//  MyUIViewController.swift
//  Iruka
//
//  Created by kudo koki on 2021/06/02.
//

import UIKit

class MyUIViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.barTintColor = UIColor(named: "Navigation")
        navigationBar.tintColor = UIColor(named: "ButtonText")
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        
        switch navigationBar.restorationIdentifier {
        case "homeNavigation":
            print("gggg")
        default:
            print("aaa")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
