//
//  ItemDataTableViewCell.swift
//  Iruka
//
//  Created by kudo koki on 2021/04/19.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var itemNameText: UILabel!
    @IBOutlet weak var registrationTimeText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor(named: "Background")
        itemNameText.textColor = UIColor(named: "Text")
        registrationTimeText.textColor = UIColor(named: "Text")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
