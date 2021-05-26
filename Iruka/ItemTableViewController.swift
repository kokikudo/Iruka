//
//  ItemListTableViewController.swift
//  Iruka
//
//  Created by kudo koki on 2021/04/13.
//

import UIKit
import RealmSwift

class ItemTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    // outlets
    @IBOutlet var itemTableView: UITableView!
    
    // 商品リスト: showList()でその都度表示するリストを変える
    private var allList: Results<Item>!
    private var needToBeEvaluatedList: Results<Item>!
    private var searchedList: Results<Item>!
    
    // 検索機能のコントローラー: アプリ起動時にセットアップする
    private var searchController: UISearchController!
    
    // Realmオブジェクト
    private var realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(realm.configuration.fileURL!)
        
        self.itemTableView.delegate = self
        self.itemTableView.dataSource = self
        
        allList = realm.objects(Item.self)
        needToBeEvaluatedList = confirmEvaluationTargetItem()
        setupSearchController()
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        showList().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = self.itemTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ItemTableViewCell else {
            fatalError("セルのダウンキャストに失敗しました")
        }
        
        let item = showList()[indexPath.row]
        
        cell.registrationTimeText.text = item.date
        cell.photoImage.image = UIImage(data: item.photoImage)
        cell.itemNameText.text = item.name
        return cell
    }
    
    // セルの編集許可。削除機能に必要。
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    // スワイプするとデータを削除できる
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        try! realm.write {
            realm.delete(showList()[indexPath.row])
        }
        
        self.itemTableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.placeholder = "名前で検索します"
        
        searchController.searchBar.delegate = self
    }
    
    // private mathod
    @IBAction func searchBar(_ sender: UIBarButtonItem) {
        present(searchController, animated: true, completion: nil)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        let inputText = searchBar.text ?? ""
        if inputText.isEmpty {
            searchedList = needToBeEvaluatedList
        } else {
            searchedList = needToBeEvaluatedList.filter("name CONTAINS %@", inputText)
        }
        
        itemTableView.reloadData()
        searchController.isActive = false
    }
    
    // 表示する商品のリストを都度変更する
    private func showList() -> Results<Item> {
        if let a = searchedList, a.count > 0 {
            return a
        } else if needToBeEvaluatedList.count > 0 {
            return needToBeEvaluatedList
        } else {
            return allList
        }
    }
    
    // セルをタップしたらその商品の編集画面に移動
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "AddItem":
            print("AddItemのsegueが実行されました。")
        case "EditItem":
            // タップしたセルのインデックスパスを取得
            if let indexPath = itemTableView.indexPathForSelectedRow {
                
                // 遷移先のViewを特定しインスタンス化
                guard let destnation = segue.destination as? ItemEditPageViewController else {
                    fatalError("ItemEditPageViewController への遷移に失敗しました。")
                }
                destnation.item = showList()[indexPath.row]
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
            
            item.isReEvaluation = sourceViewController.isReEvaluation
            if item.isReEvaluation {
                item.beforeImpression = sourceViewController.beforeImpression
                item.beforeRating = sourceViewController.beforeRating
                item.afterImpression = sourceViewController.impressionText.text!
                item.afterRating = sourceViewController.ratingCount.rating
            } else {
                item.beforeImpression = sourceViewController.impressionText.text!
                item.beforeRating = sourceViewController.ratingCount.rating
                item.afterImpression = sourceViewController.afterImpression
                item.afterRating = sourceViewController.afterRating
            }
            // すでにIDがある時はそれを代入。ないときは一意の文字列を取得。
            item.id = sourceViewController.item?.id ?? NSUUID().uuidString
            
            // Realm更新。
            try! realm.write {
                realm.add(item, update: .modified) // .modified: IDがない時は追加。ある時は更新。
            }
            
            // テーブルビューのリロード
            itemTableView.reloadData()
            
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
    
    // アプリ起動時に実行。評価対象商品があれば表示リストに適用。
    func confirmEvaluationTargetItem() -> Results<Item> {
        
        // 評価対象の絞り込み
        let result = select(items: allList)
        
        // あればアラート
        if result.count > 0 {
            // アラート
            let alertController = UIAlertController(title: "テスト", message: "評価対象商品: \(result.count)", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            
        } else {
            print("対象商品はありません")
        }
        
        return result
    }
    // 2つの条件を満たした商品を絞り込む(去年以前であること、評価が終わってないこと)
    func select(items: Results<Item>) -> Results<Item> {
        
        // 去年の日付を算出し、秒数に変換
        let dateBefore1Year = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        let convertedDB1Y = Item.convertDateIntoDouble(date: dateBefore1Year)
        print("今日の日付：\(Item.convertDateIntoDouble(date: Date()))")
        print("去年の日付：\(convertedDB1Y)")
        
        // 条件を指定し検索
        let result = items.filter("dateSecond <= %@", convertedDB1Y).filter("isReEvaluation == NO")
        
        // 評価が終わったという処理をここで行う
        for a in result {
            try! realm.write {
                a.isReEvaluation = true
            }
        }
        return result
    }
}
