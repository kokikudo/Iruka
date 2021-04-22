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
        let image = UIImage(named: "test_icon")
        let item = Item(registrationTime: "2021年4月20日", photoImage: image, name: "testItem", price: "500", impression: "テストテストテスト", rating: 4)
        items += [item]
    }
    
    // 検索処理
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
    // 検索ボタンをタップしたらキーボードが下がる
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    // セルをタップしたらその商品の編集画面に移動
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "AddItem":
            print("AddItemのsegueが実行されました。")
        case "EditItem":
            if let indexPath = self.tableView.indexPathForSelectedRow {
                guard let destnation = segue.destination as? ItemEditPageViewController else {
                    fatalError("ItemEditPageViewController への遷移に失敗しました。")
                }
                
                destnation.item = self.currentItems[indexPath.row]
            }
        default:
            fatalError("segueのIDが一致しませんでした。")
        }
        
    }
    
    // 保存ボタンが押されてこのページに戻ってきた時に実行。TableViewを更新する
    @IBAction func unwindToItemList(sender: UIStoryboardSegue) {
        
        // 遷移元の確認と遷移元で作成したitemデータを取得
        if let sourceViewController = sender.source as? ItemEditPageViewController,
           let item = sourceViewController.item {
            
            // セルがタップされていた場合（編集の場合）その行の値を更新する
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                items[selectedIndexPath.row] = item
                currentItems = items
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                // そうでない場合（新規登録の場合）新しくデータと行を追加
                let newIndexPath = IndexPath(row: items.count, section: 0)
                items.append(item)
                currentItems = items
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }
    
    // このページに戻ってきたとき（ビューが表示された時）にタップしたセルのセレクト状態を解除
    override func viewWillAppear(_ animated: Bool) {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}
