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
    // 商品リスト
    private var showList: Results<Item>!
    private var allList: Results<Item>!
    private var needToBeEvaluatedList: Results<Item>!
    private var searchedList: Results<Item>!
    
    // 検索機能のコントローラー: アプリ起動時にセットアップする
    private var searchController: UISearchController!
    
    // Realmオブジェクト
    private var realm = try! Realm()
    
    // 全評価完了
    private var isAllEvaluationComplete: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ud = UserDefaults.standard
        let firstLunchKey = "firstLunch"
        if ud.bool(forKey: firstLunchKey) {
            ud.setValue(false, forKeyPath: firstLunchKey)
            ud.synchronize()
            self.performSegue(withIdentifier: "toApp", sender: nil)
        }
        
        view.backgroundColor = UIColor(named: "Background")
        
        isAllEvaluationComplete = false
        print(realm.configuration.fileURL!)
        
        self.itemTableView.delegate = self
        self.itemTableView.dataSource = self
        
        allList = realm.objects(Item.self)
        needToBeEvaluatedList = confirmEvaluationTargetItem()
        
        showList = toggleShowList()
        setupSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 評価が終わったら前リスト表示
        if isAllEvaluationComplete {
            showList = toggleShowList()
            let alertController = UIAlertController(title: "テスト", message: "評価完了", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
        navigationItem.title = "home"
        itemTableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        showList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = self.itemTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ItemTableViewCell else {
            fatalError("セルのダウンキャストに失敗しました")
        }
        
        let item = showList[indexPath.row]
        
        cell.registrationTimeText.text = Item.convertDateIntoString(date: item.date)
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
            realm.delete(showList[indexPath.row])
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
            showList = allList
        } else {
            showList = allList.filter("name CONTAINS %@", inputText)
        }
        
        itemTableView.reloadData()
        searchController.isActive = false
    }
    
    // 表示する商品のリストを都度変更する
    private func toggleShowList() -> Results<Item> {
        let list: Results<Item>
        
        if let a = searchedList, a.count > 0 {
            list = a
        } else if needToBeEvaluatedList.count > 0 {
            self.navigationItem.rightBarButtonItems?[0].isEnabled = false
            self.navigationItem.rightBarButtonItems?[1].isEnabled = false
            list = needToBeEvaluatedList
        } else {
            self.navigationItem.rightBarButtonItems?[0].isEnabled = true
            self.navigationItem.rightBarButtonItems?[1].isEnabled = true
            list = allList
        }
        let result = list.sorted(byKeyPath: "date", ascending: false)
        
        return result
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
                destnation.item = showList[indexPath.row]
            }
        case "toApp":
            print("チュートリアル表示")
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
            item.name = sourceViewController.nameText.text!
            item.price = sourceViewController.priceText.text!
            
            item.isReEvaluation = sourceViewController.isReEvaluation
            if item.isReEvaluation {
                item.beforeImpression = sourceViewController.beforeImpression
                item.beforeRating = sourceViewController.beforeRating
                item.afterImpression = sourceViewController.impressionText.text!
                item.afterRating = sourceViewController.ratingCount.rating
                item.isCompletedEvaluation = true
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
            
            // 通知登録
            setNotification(date: item.date)
        }
        
    }
    
    // ローカル通知
    private func setNotification(date: Date) {
        // trigger
        let current = Calendar.current
        let year = current.component(.year, from: date)
        let month = current.component(.month, from: date)
        let day = current.component(.day, from: date)
        
        // テスト用に1分後に通知が行くようにする
        let hour = current.component(.hour, from: date)
        let minute = current.component(.minute, from: date)
        let dateComp = DateComponents(year: year,
                                      month: month,
                                      day: day,
                                      hour: hour,
                                      minute: minute + 1)
        
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
        
        // 去年の日付の23時59分59秒より以前
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month, .day], from: Date())
        let dateBefore1Year = calendar.date(from: DateComponents(year: comps.year! - 1, month: comps.month, day: comps.day, hour: 23, minute: 59, second: 59))
        let convertedDB1Y = dateBefore1Year!.timeIntervalSince1970
        print("今日の日付：\(Item.convertDateIntoDouble(date: Date()))")
        print("去年の日付：\(convertedDB1Y)")
        
        // 条件を指定し検索
        let result = items.filter("dateSecond <= %@", convertedDB1Y).filter("isCompletedEvaluation == NO")
        
        // 評価対象のBool値をTrue
        for a in result {
            try! realm.write {
                a.isReEvaluation = true
            }
        }
        return result
    }
}
