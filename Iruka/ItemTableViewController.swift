//
//  ItemListTableViewController.swift
//  Iruka
//
//  Created by kudo koki on 2021/04/13.
//

import UIKit

class ItemTableViewController: UITableViewController, UISearchBarDelegate{

    @IBOutlet weak var search: UISearchBar!
    
    let myRefreshControl = UIRefreshControl()
    var items = [Item]()
    var currentItems = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        search.delegate = self
        search.enablesReturnKeyAutomatically = false
        loadSampleItems()
        currentItems = items
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currentItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ItemTableViewCell else {
            fatalError("セルのダウンキャストに失敗しました")
        }
        let item = currentItems[indexPath.row]
        cell.registrationTimeText.text = item.registrationTime
        cell.photoImage.image = item.photoImage
        cell.itemNameText.text = item.name
        return cell
    }
    
    // private mathod
    // サンプルデータをセット
    private func loadSampleItems() {
        let image = UIImage(named: "defaultImage.001")
        let item = Item(registrationTime: "2021年4月20日", photoImage: image, name: "testItem", price: "500", impression: "テストテストテスト", rating: 4)
        items += [item]
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        }
    //
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            currentItems = items
            tableView.reloadData()
            return
        }
        currentItems = items.filter({ item -> Bool in
            item.name.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
