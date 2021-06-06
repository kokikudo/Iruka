//
//  MyUIViewController.swift
//  Iruka
//
//  Created by kudo koki on 2021/06/02.
//

import UIKit

class MyUINavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.barTintColor = UIColor(named: "Navigation")
        navigationBar.tintColor = UIColor(named: "ButtonText")
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
//       Idによって処理を変えるコード。不要なら消す
//        switch navigationBar.restorationIdentifier {
//        case "homeNavigation":
//            print("gggg")
//        default:
//            print("aaa")
//        }
    }
}
