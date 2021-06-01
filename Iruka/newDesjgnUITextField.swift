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
        
        //self.frame.size.height = 50 指定したらカウント数の文字列と重なった
        self.borderStyle = .none
        
        // プレースホルダーの色を変える。プレースホルダー必須の時のみ実装。
//        self.attributedPlaceholder = NSAttributedString(string: "placeholder text", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        composeUnderline()
    }
    
    private func composeUnderline() {
        self.underline.frame = CGRect(x: 0,
                                      y: self.frame.height,
                                      width: self.frame.width,
                                      height: 2.5)
        
        self.underline.backgroundColor = UIColor(named: "Underline")
        
        self.addSubview(self.underline)
        self.bringSubviewToFront(self.underline)
    }

}
