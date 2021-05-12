//
//  ItemEditPageViewController.swift
//  Iruka
//
//  Created by kudo koki on 2021/04/13.
//

import UIKit
import RealmSwift

class ItemEditPageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Propaties
    @IBOutlet weak var registrationTimeLabel: UILabel!
    @IBOutlet weak var registrationTimeText: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var wordCountLabel: UILabel!
    private let itemNameTextMaxCount = 40
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceText: UITextField!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var impressionLabel: UILabel!
    @IBOutlet weak var changeButton: UISwitch!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var impressionText: UITextView!
    @IBOutlet weak var impressionWordCountLabel: UILabel!
    private let impressionMaxCount = 150
    @IBOutlet weak var ratingCount: RatingControl!
    
    var item: Item?
    var realm = try! Realm()
    
    
    private var isReEvaluation = false
    private var impressionDict: Dictionary<String, String> = ["before": "", "after": ""]
    private var ratingDict: Dictionary<String, Int> = ["before": 0, "after": 0]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameText.delegate = self
        priceText.delegate = self
        impressionText.delegate = self
        
        // 何もないところをタップでキーボードを下げる
        downKeyboardInTap()
        // 保存ボタンの初期値はfalse。必須項目入力後にtrue
        saveButton.isEnabled = false
        
        // 保存ボタンの有効無効の判断をするメソッドを実行させるための通知を登録
        // キーボードが閉じた時に通知
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                               object: nil,
                                               queue: nil,
                                               using: didchangeNotfication(notification:))
        // 評価が変更されたら通知
        NotificationCenter.default.addObserver(forName: .changeRatingNotification,
                                               object: nil,
                                               queue: nil,
                                               using: didchangeNotfication(notification:))
        
        // 金額入力のキーボードにリターンキーを追加
        addReturnBotton()
        // 感想文のプレースホルダーの状態
        impressionText.text = "(150文字まで)"
        impressionText.textColor = UIColor.lightGray
        
        // セルから移動してきた場合は商品の情報を反映しスイッチを表示、そうでなければ現在日時を取得しスイッチ非表示
        if let item = item {
            photoImage.image = item.photoImage
            registrationTimeText.text = item.registrationTime
            nameText.text = item.name
            priceText.text = item.price
            impressionText.text = item.impression
            ratingCount.rating = item.rating
            changeButton.isHidden = true
        } else {
            // 現在日時を取得
            let datefomatter = DateFormatter()
            datefomatter.dateStyle = .long
            datefomatter.timeStyle = .none
            datefomatter.locale = Locale(identifier: "ja_JP")
            registrationTimeText.text = datefomatter.string(from: Date())
            changeButton.isHidden = true
        }
        
        
    }
    
    
    func downKeyboardInTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    // 金額と感想のキーボードにリターンボタンを追加
    func addReturnBotton() {
        let priceTextToolber: UIToolbar = UIToolbar()
        let impressionTextToolber: UIToolbar = UIToolbar()
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let priceTextDone = UIBarButtonItem(title: "完了",
                                            style: .done,
                                            target: self,
                                            action: #selector(priceTextShouldReturn))
        priceTextToolber.items = [space, priceTextDone]
        priceTextToolber.sizeToFit()
        priceText.inputAccessoryView = priceTextToolber
        
        let impressionTextDone = UIBarButtonItem(title: "完了",
                                                 style: .done,
                                                 target: self,
                                                 action: #selector(impressionTextShouldReturn))
        impressionTextToolber.items = [space, impressionTextDone]
        impressionTextToolber.sizeToFit()
        impressionText.inputAccessoryView = impressionTextToolber
    }
    
    // 画像がタップされてたらアラート起動。カメラ撮影かライブラリ選択かを選び、それぞれの処理を実行。
    @IBAction func selectImage(_ sender: UITapGestureRecognizer) {
        
        // アラートインスタンス
        let alertController = UIAlertController(title: "写真を選択", message: "選択してください", preferredStyle: .alert)
        
        // カメラ撮影
        let cameraAction = UIAlertAction(title: "カメラで撮影", style: .default) { (action) in
            
            let cameraPickerController = UIImagePickerController()
            cameraPickerController.sourceType = .camera
            cameraPickerController.delegate = self
            self.present(cameraPickerController, animated: true, completion: nil)
        }
        
        // ライブラリ
        let libralyAction = UIAlertAction(title: "ライブラリから選択", style: .default) { (action) in
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        // キャンセル
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        // 各アラートアクションを追加
        alertController.addAction(cameraAction)
        alertController.addAction(libralyAction)
        alertController.addAction(cancelAction)
        
        // アラートコントローラーへ移動
        present(alertController, animated: true, completion: nil)
    }
    // デリゲートメソッド。キャンセルしたら何もせず画面を閉じる
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    // デリゲートメソッド。画像を取得できたらプロパティを更新する。
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        else {
            fatalError("画像の取得に失敗しました")
        }
        photoImage.image = selectedImage
        
        dismiss(animated: true, completion: nil)
    }
    
    // キーボードが閉じた時 or 評価の星の個数が変更された時に呼ばれるメソッド。全て入力したら保存ボタンが有効になる
    func didchangeNotfication(notification: Notification) {
        saveButton.isEnabled =
            nameText.text?.isEmpty == false &&
            priceText.text?.isEmpty == false &&
            impressionText.text?.isEmpty == false &&
            ratingCount.rating > 0
    }
    
    @IBAction func saveRealm(_ sender: Any) {
        
        /* 保存確認のアラート表示
        let alertController = UIAlertController(title: "確認", message: "登録してもよろしいですか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "はい", style: .default) { (action) in
            
            // 新しい商品をインスタンス化
            let photo = self.photoImage.image
            let registrationTime = self.registrationTimeText.text
            let name = self.nameText.text
            let price = self.priceText.text
            let impression = self.impressionText.text
            let rating = self.ratingCount.rating
            
            self.item = Item(registrationTime: registrationTime!, photoImage: photo, name: name!, price: price!, impression: impression!, rating: rating)
        }
        let noAction = UIAlertAction(title: "いいえ(編集に戻る)", style: .default) { (action) in }
        
        alertController.addAction(okAction)
        alertController.addAction(noAction)
        
        present(alertController, animated: true, completion: nil)
        */
    
        let item = Item(registrationTime: registrationTimeText.text!, photoImage: photoImage.image!, name: nameText.text!, price: priceText.text!, impression: impressionText.text, rating: ratingCount.rating)
        
        try! realm.write {
            realm.add(item)
        }
        
        // この画面をスタックから外し前の画面に戻る。
        self.navigationController?.popViewController(animated: true)
    }

    // キャンセルボタンの挙動。新規登録と既存の編集で処理を変える
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
        // 
        let isPresentingInAddItemMode = presentingViewController is UINavigationController
        
        if isPresentingInAddItemMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("商品ページがナビゲーションコントローラの中にありません。")
        }
    }

}

extension Notification.Name {
    static let changeRatingNotification = Notification.Name("changeRatingNotification")
}

// TextFieldに関するデリゲートとその他のメソッド
extension ItemEditPageViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == priceText {
            textField.text = ""
        }
    }
    
    // リターンキーでキーボードを下げる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    // 金額入力後、完了ボタンを押すと通貨記号が付いたフォーマットに変わりキーボードを閉じる
    @objc func priceTextShouldReturn() -> Bool {
        // フォーマットに適用するために金額をFloat型に変換
        guard let price = Float(priceText.text!) else {
            fatalError("数字以外の文字が入力されました")
        }
        // 単位を追加するフォーマットを作成
        let priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .currency  // 通貨記号をつける
        // セット
        priceText.text = priceFormatter.string(from: NSNumber(value: price))
        
        priceText.resignFirstResponder()
        return true
    }
    
    // 文字数制限
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 商品名のみに文字数制限
        if textField == nameText {
            // 入力を反映したテキストを取得
            let resultText: String = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            return resultText.count <= itemNameTextMaxCount
        } else {
            return true
        }
    }
    
    // 現在の文字数表示
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == nameText {
            wordCountLabel.text = "( \(textField.text!.count) / \(itemNameTextMaxCount) )"
        }
    }
    
}

// textView(感想入力欄)のデリゲートとその他のメソッド
extension ItemEditPageViewController: UITextViewDelegate {
    
    // 追加した完了ボタンを押すとキーボードが下がる
    @objc func impressionTextShouldReturn() -> Bool {
        impressionText.resignFirstResponder()
        return true
    }
    
    // 文字数制限
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let resultText: String = (textView.text! as NSString).replacingCharacters(in: range, with: text)
        return resultText.count <= impressionMaxCount
    }
    
    // 現在の文字数表示
    func textViewDidChange(_ textView: UITextView) {
        impressionWordCountLabel.text = "( \(textView.text!.count) / \(impressionMaxCount) )"
    }
    
    // プレースホルダー
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "(150文字まで)"
            textView.textColor = UIColor.lightGray
        }
    }
}


