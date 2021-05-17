//
//  ItemListTableViewController.swift
//  Iruka
//
//  Created by kudo koki on 2021/04/13.
//

import UIKit
import RealmSwift

class ItemTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet var itemTableView: UITableView!
    
    //var currentItems = [Item]()
    
    var itemList: Results<Item>!
    var realm = try! Realm()
    var isTappedNotification = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //search.delegate = self
        //search.enablesReturnKeyAutomatically = false
        //currentItems = items
        
        self.itemTableView.delegate = self
        self.itemTableView.dataSource = self
        self.itemList = realm.objects(Item.self)
        
        // 通知から来た場合、一年前の商品のみリストアップ
        if isTappedNotification {
            let oneyearItems = Implementor()
            let results = oneyearItems.select()
            
            self.itemList = results
            itemTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.itemTableView.reloadData()
        
        /* タップ状態を解除
        if let indexPath = itemTableView.indexPathForSelectedRow {
            itemTableView.deselectRow(at: indexPath, animated: true)
        */
    }
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = self.itemTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ItemTableViewCell else {
            fatalError("セルのダウンキャストに失敗しました")
        }
        
        let item = self.itemList[indexPath.row]
        
        cell.registrationTimeText.text = item.registrationTime
        cell.photoImage.image = UIImage(data: item.photoImage)
        cell.itemNameText.text = item.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    // スワイプするとデータが削除できる
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        try! realm.write {
            realm.delete(itemList[indexPath.row])
        }
        
        self.itemTableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    
    // private mathod
    
    /* 検索処理
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
    */

    // セルをタップしたらその商品の編集画面に移動
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "AddItem":
            print("AddItemのsegueが実行されました。")
        case "EditItem":
            if let indexPath = self.itemTableView.indexPathForSelectedRow {
                guard let destnation = segue.destination as? ItemEditPageViewController else {
                    fatalError("ItemEditPageViewController への遷移に失敗しました。")
                }
                
                destnation.item = self.itemList[indexPath.row]
            }
        default:
            fatalError("segueのIDが一致しませんでした。")
        }
        
    }
    
    // 保存ボタンが押されてこのページに戻ってきた時に実行。TableViewを更新する
    @IBAction func unwindToItemList(sender: UIStoryboardSegue) {
        
        // プライマリキーの有無で新規登録か既存の編集を判断し、Realmを更新する。
        if let sourceViewController = sender.source as? ItemEditPageViewController {
            
            let item = Item()
            item.registrationTime = sourceViewController.registrationTimeText.text!
            item.photoImage = (sourceViewController.photoImage.image?.pngData()!)!
            item.name = sourceViewController.nameText.text!
            item.price = sourceViewController.priceText.text!
            item.impression = sourceViewController.impressionText.text
            item.rating = sourceViewController.ratingCount.rating
            item.isReEvaluation = sourceViewController.isReEvaluation
            
            // すでにIDがある時はそれを代入。ないときは一意の文字列を取得。
            item.id = sourceViewController.item?.id ?? NSUUID().uuidString
            
            // Realm更新。
            try! realm.write {
                realm.add(item, update: .modified) // .modified: IDがない時は追加。ある時は更新。
            }
        }
    
    }
    
    
}
