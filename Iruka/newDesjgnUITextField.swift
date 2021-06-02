//
//  newDesjgnUITextField.swift
//  Iruka
//
//  Created by kudo koki on 2021/06/01.
//

import UIKit

class newDesjgnUITextField: UITextField {

    let underline: UIView = UIView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        self.borderStyle = .none
        self.textAlignment = .left
        // プレースホルダーの色を変える。プレースホルダー必須の時のみ実装。
        switch self.restorationIdentifier {
        case "itemname":
            self.attributedPlaceholder = NSAttributedString(string: "40文字まで", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        case "itemprice":
            self.attributedPlaceholder = NSAttributedString(string: "0", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        default:
            fatalError("ID認証失敗：newDesjgnUITextField.restorationIdentifier")
        }
        
        composeUnderline()
    }
    
    private func composeUnderline() {
        self.underline.frame = CGRect(x: 0,
                                      y: self.frame.height,
                                      width: self.frame.width,
                                      height: 3.0)
        
        self.underline.backgroundColor = UIColor(named: "Underline")
        
        self.addSubview(self.underline)
        self.bringSubviewToFront(self.underline)
    }

}
