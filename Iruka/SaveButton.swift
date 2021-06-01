//
//  SaveButton.swift
//  Iruka
//
//  Created by kudo koki on 2021/06/01.
//

import UIKit

class SaveButton: UIButton {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    func setup() {
        self.setTitle("保存する", for: UIControl.State.normal)
        self.layer.cornerRadius = 20
        self.layer.borderColor = UIColor.black.cgColor //cgColor: CoreGraficsの色を使う
        self.layer.borderWidth = 1
        self.layer.masksToBounds = true // コンテンツを定義した枠線内に収める
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                backgroundColor = UIColor(named: "Button")
                setTitleColor(UIColor(named: "ButtonText"), for: .normal)
            } else {
                backgroundColor = UIColor(named: "disableButton")
                setTitleColor(UIColor(named: "disableButtonText"), for: .normal)
            }
        }
    }

}
