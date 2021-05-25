//
//  ItemListTableViewController.swift
//  Iruka
//
//  Created by kudo koki on 2021/04/13.
//

import UIKit
import RealmSwift

class ItemTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet var itemTableView: UITableView!
    
    //var currentItems = [Item]()
    
    var itemList: Results<Item>!
    var realm = try! Realm()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //search.delegate = self
        //search.enablesReturnKeyAutomatically = false
        //currentItems = items
        print(realm.configuration.fileURL!)
        
        self.itemTableView.delegate = self
        self.itemTableView.dataSource = self
        self.itemList = confirmEvaluationTargetItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.itemTableView.reloadData()
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
        
        cell.registrationTimeText.text = item.date
        cell.photoImage.image = UIImage(data: item.photoImage)
        cell.itemNameText.text = item.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    // スワイプするとデータを削除できる
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
            // タップしたセルのインデックスパスを取得
            if let indexPath = self.itemTableView.indexPathForSelectedRow {
                
                // 遷移先のViewを特定しインスタンス化
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
            item.photoImage = (sourceViewController.photoImage.image?.pngData()!)!
            item.date = sourceViewController.registrationTimeText.text!
            item.dateSecond = Item.convertDateIntoDouble(date: sourceViewController.registrationDay)
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
            // 通知登録
            setNotification(date: sourceViewController.registrationDay)
        }
        
    }
    
    // ローカル通知
    private func setNotification(date: Date) {
        // trigger
        let current = Calendar.current
        let year = current.component(.year, from: date)
        let month = current.component(.month, from: date)
        let day = current.component(.day, from: date)
        let dateComp = DateComponents(year: year, month: month, day: day, hour: 13, minute: 47)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
        
        // content
        let content = UNMutableNotificationContent()
        content.title = "あれを買って1年経ちました...覚えてますか？"
        content.body = "見返しましょう！"
        content.sound = UNNotificationSound.default
        
        // contentとtriggerをもとに通知を作成
        let request = UNNotificationRequest(identifier: "\(year)\(month)\(day)", content: content, trigger: trigger)
        
        // 通知を登録
        // UNUserNotificationCenterにrequestをaddする。エラーの時はエラー内容が返ってくる。
        let center = UNUserNotificationCenter.current()
        
        center.add(request) { (error) in
            if let error = error {
                print("通知処理が失敗:\(error.localizedDescription)")
            }
        }
    }
    
    // アプリ起動時に実行。評価対象商品があるか確認、あればアラート。
    func confirmEvaluationTargetItem() -> Results<Item> {
        let realm = try! Realm()
        var itemObject: Results<Item> = realm.objects(Item.self)
        
        let result = select(items: itemObject)
        
        if result.count > 0 {
            // アラート
            let alertController = UIAlertController(title: "テスト", message: "評価対象商品: \(result.count)", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            
            itemObject = result
            return itemObject
        } else {
            print("対象商品はありません")
            return itemObject
        }
    }
    
    func select(items: Results<Item>) -> Results<Item> {
        let dateBefore1Year = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        let convertedDB1Y = Item.convertDateIntoDouble(date: dateBefore1Year)
        
        let result = items.filter("dateSecond <= %@", convertedDB1Y).filter("isReEvaluation == %@", false)
        return result
    }
}
