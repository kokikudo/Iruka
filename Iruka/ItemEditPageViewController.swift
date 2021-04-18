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
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var wordCountLabel: UILabel!
    private let itemNameTextMaxCount = 40
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceText: UITextField!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var impressionLabel: UILabel!
    @IBOutlet weak var changeButton: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var impressionText: UITextView!
    @IBOutlet weak var impressionWordCountLabel: UILabel!
    private let impressionMaxCount = 150
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameText.delegate = self
        priceText.delegate = self
        impressionText.delegate = self
        
        // タップでキーボードを下げる
        downKeyboardInTap()
        // 金額入力のキーボードにリターンキーを追加
        addReturnBotton()
        // 感想文のプレースホルダーの状態
        impressionText.text = "感想を入力..."
        impressionText.textColor = UIColor.lightGray
        // 現在日時を取得
        let datefomatter = DateFormatter()
        datefomatter.dateStyle = .long
        datefomatter.timeStyle = .none
        datefomatter.locale = Locale(identifier: "ja_JP")
        registrationTimeText.text = datefomatter.string(from: Date())
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
        let alertController: UIAlertController = UIAlertController(title: "写真を選択", message: "選択してください", preferredStyle: .alert)
        
        // カメラ撮影
        let cameraAction: UIAlertAction = UIAlertAction(title: "カメラで撮影", style: .default) { (action) in
            
            let cameraPickerController = UIImagePickerController()
            cameraPickerController.sourceType = .camera
            cameraPickerController.delegate = self
            self.present(cameraPickerController, animated: true, completion: nil)
        }
        
        // ライブラリ
        let libralyAction: UIAlertAction = UIAlertAction(title: "ライブラリから選択", style: .default) { (action) in
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        // キャンセル
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: {(action: UIAlertAction!) -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        
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
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// TextFieldのデリゲートとその他のメソッド
extension ItemEditPageViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 2 {
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
        // 金額に単位を追加
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
        
        // 入力を反映したテキストを取得
        let resultText: String = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        return resultText.count <= itemNameTextMaxCount
    }
    
    // 現在の文字数表示
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.tag == 1 {
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
            textView.text = "(必須。150文字まで)"
            textView.textColor = UIColor.lightGray
        }
    }
}


