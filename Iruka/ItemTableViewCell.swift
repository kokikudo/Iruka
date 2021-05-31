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
        // Initialization code
        
        self.backgroundColor = UIColor(named: "Background")
        itemNameText.textColor = UIColor(named: "Headline")
        registrationTimeText.textColor = UIColor(named: "Headline")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
