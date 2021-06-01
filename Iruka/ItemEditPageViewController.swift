//
//  ItemEditPageViewController.swift
//  Iruka
//
//  Created by kudo koki on 2021/04/13.
//

import UIKit

class ItemEditPageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Propaties
    @IBOutlet weak var registrationTimeLabel: UILabel!
    @IBOutlet weak var registrationTimeText: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameText: newDesjgnUITextField!
    @IBOutlet weak var wordCountLabel: UILabel!
    private let itemNameTextMaxCount = 40
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceText: newDesjgnUITextField!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var impressionLabel: UILabel!
    @IBOutlet weak var changeButton: UISwitch!
    @IBOutlet weak var impressionText: UITextView!
    @IBOutlet weak var impressionWordCountLabel: UILabel!
    private let impressionMaxCount = 150
    private let impressionPlaceHolderText = "未入力"
    @IBOutlet weak var ratingCount: RatingControl!
    @IBOutlet weak var saveButton: SaveButton!
    
    
    var item: Item?
    
    var isReEvaluation = false   // 評価対象の商品の場合とそうでない場合で処理を変える
    var beforeImpression = ""
    var afterImpression = ""
    var beforeRating = 0
    var afterRating = 0
    
    // test date
    let testDate = Item.createDateObject(year: 2020, month: 4, day: 20)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameText.delegate = self
        priceText.delegate = self
        impressionText.delegate = self
        
        // 何もないところをタップでキーボードを下げる
        downKeyboardInTap()
        
        
        /* 保存ボタン
         保存ボタンの有効無効の判断をするメソッドを実行させるための通知を登録
         キーボードが閉じた or 評価点が変更された　で通知を飛ばす
         */
        saveButton.isEnabled = false
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                               object: nil,
                                               queue: nil,
                                               using: didchangeNotfication(notification:))
        NotificationCenter.default.addObserver(forName: .changeRatingNotification,
                                               object: nil,
                                               queue: nil,
                                               using: didchangeNotfication(notification:))
        
        // 金額入力のキーボードにリターンキーを追加
        addReturnBotton()
        // 感想文のプレースホルダーの状態
        impressionText.text = impressionPlaceHolderText
        impressionText.textColor = UIColor.lightGray
        // 変更ボタンを隠す
        changeButton.isHidden = true
        
        // セルから移動してきた場合は商品の情報を反映しスイッチを表示、そうでなければ現在日時を取得しスイッチ非表示
        if let item = item {
            
            photoImage.image = UIImage(data: item.photoImage)
            registrationTimeText.text = Item.convertDateIntoString(date: item.date)
            nameText.text = item.name
            showStringLength(text: nameText!)
            priceText.text = item.price
            isReEvaluation = item.isReEvaluation
            
            // 評価前後の感想文と評価点を各プロパティにセット
            beforeImpression = item.beforeImpression
            beforeRating = item.beforeRating
            afterImpression = item.afterImpression
            afterRating = item.afterRating
            
            // 評価するかしないかで感想文の初期値を変更する
            if isReEvaluation {
                //　評価時の感想と評価点を表示（初期値は何もない）
                if afterImpression.isEmpty {
                    afterImpression = impressionPlaceHolderText
                }
                impressionText.text = afterImpression
                ratingCount.rating = afterRating
                changeButton.isHidden = false
            } else {
                impressionText.text = beforeImpression
                ratingCount.rating = beforeRating
            }
            
        } else {
            // 現在日時を取得
            registrationTimeText.text = Item.convertDateIntoString(date: Date())
        }
        
        // 色の設定
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        presentingViewController?.beginAppearanceTransition(true, animated: animated)
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
        
        if isReEvaluation {
            saveButton.isEnabled =
                nameText.text?.isEmpty == false &&
                priceText.text?.isEmpty == false &&
                !afterImpression.isEmpty &&
                afterImpression != impressionPlaceHolderText &&
                ratingCount.rating > 0
            
        } else {
            saveButton.isEnabled =
                nameText.text?.isEmpty == false &&
                priceText.text?.isEmpty == false &&
                beforeImpression.isEmpty == false &&
                beforeImpression != impressionPlaceHolderText &&
                ratingCount.rating > 0
        }
        
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
    
    func showStringLength(text: Any) {
        switch text {
        case is UITextView:
            impressionWordCountLabel.text = "( \(impressionText.text!.count) / \(impressionMaxCount) )"
        case is UITextField:
            wordCountLabel.text = "( \(nameText.text!.count) / \(itemNameTextMaxCount) )"
        default:
            print("該当しない型が選択されました。")
        }
    }
    
    // ONで評価後、OFFで評価前の感想文と評価点を切り替える
    @IBAction func tapChangeButton(_ sender: UISwitch) {
        
        if sender.isOn {
            self.impressionText.text = afterImpression
            self.impressionText.isEditable = true
            self.ratingCount.rating = afterRating
            self.ratingCount.isUserInteractionEnabled = true
        } else {
            afterRating = ratingCount.rating
            
            self.impressionText.text = beforeImpression
            self.impressionText.isEditable = false
            self.ratingCount.rating = beforeRating
            self.ratingCount.isUserInteractionEnabled = false
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
        if textField === nameText {
            // 入力を反映したテキストを取得
            let resultText: String = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            return resultText.count <= itemNameTextMaxCount
        } else {
            return true
        }
    }
    
    // 現在の文字数表示
    func textFieldDidChangeSelection(_ textField: UITextField) {
        showStringLength(text: textField)
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
        showStringLength(text: textView)
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
            textView.text = impressionPlaceHolderText
            textView.textColor = UIColor.lightGray
        } else if isReEvaluation {
            afterImpression = textView.text!
        } else {
            beforeImpression = textView.text!
        }
    }
}


