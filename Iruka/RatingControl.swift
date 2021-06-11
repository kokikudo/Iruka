//
//  RatingControl.swift
//  Iruka
//
//  Created by kudo koki on 2021/04/15.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    
    //MARK: Propaties
    var ratingButtons = [UIButton]() // 評価の星。5つあるためリストで格納
    var rating = 0 { // 星の数。更新時に設定値より下の配列の星をセレクト状態にする関数を実行
        didSet {
            updateButtonSelectionStates()
            NotificationCenter.default.post(name: .changeRatingNotification, object: nil)
        }
    }
    // 星のサイズ。storyboardのinspecter上でいじれるようになる。
    // 値が更新された場合はまたボタンを作り直す必要がある
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    // 星の数
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    
    //MARK: Initalization
    override init(frame: CGRect) { // CGRect: 描画するオブジェクトの位置とサイズを表現する型
        super.init(frame: frame)
        setupButtons() // ボタン生成
    }
    // required initが定義されてるNSCodingプロトコルがUIViewで定義されており、UIViewを継承しているUIStackViewでも定義する
    // 通常、初期化しない場合は不要だが、指定イニシャライザを定義する場合はこちらも定義するのがるーるらしい
    required init(coder: NSCoder) { // NSCoder: クラスをアーカイブに保存するための型
        super.init(coder: coder)
        setupButtons() // こっちにも同じ処理
    }
    
    //MARK: Button Action
    @objc func ratingButtonTapped(button: UIButton) {
        // 配列内にあるボタンの要素数から評価点を算出
        // 押されたボタンの要素数を取得
        guard let index = ratingButtons.firstIndex(of: button) else {
            fatalError("The button, \(button), is not in the ratingButtons array: \(ratingButtons)")
        }
        // 要素数に1を加算
        let selectedRating = index + 1
        // ratingと同じ数の場合（同じ星をタップした場合）、評価をクリアする
        if selectedRating == rating {
            rating = 0
        } else { // そうでない場合はratingを更新
            rating = selectedRating
        }
    }
    
    //MARK: Private Methods
    private func setupButtons() {
        
        // ボタンを新規作成するたびに、古いボタンを削除する必要がある。
        for button in ratingButtons {
            // ようわからんが、削除する時はこのコードを書く必要がある
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll() // プロパティの星を全削除
        
        // ボタンのイメージ画像をアセットから呼び出す
        let bundle = Bundle(for: type(of: self)) // バンドルをメインバンドルに設定
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightStar = UIImage(named: "highlightedStar", in: bundle, compatibleWith: self.traitCollection)
        
        // 評価の星を作成
        for index in 0..<starCount {
            // ボタンを作成
            let button = UIButton()
            button.setImage(emptyStar, for: .normal) // 通常の星のイメージ画像
            button.setImage(filledStar, for: .selected) // 選択された星のイメージ
            button.setImage(highlightStar, for: .highlighted) // 洗濯中（タップ中）のイメージ
            button.setImage(highlightStar, for: [.highlighted, .selected]) // 選択中、選択後のイメージ
            
            // 制約を追加
            //button.translatesAutoresizingMaskIntoConstraints = false // AutoLayoutを無効
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            // アクセシビリティ。現在設定している評価点を出力
            button.accessibilityLabel = "Set \(index + 1) star rating"
            
            // ボタンを押された時にアクションメソッドratingButtonTappedが実行されるように設定
            // .addTarget()は対象のクラスインスタンスに何かしらのアクションを起こしたときに関数を実行するようにする
            // actionには実行したい関数をセレクタという形式で渡す。関数の先頭に@objcを入れる。
            button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(button:)), for: .touchUpInside)
            
            addArrangedSubview(button) //　設定したボタンを追加
            ratingButtons.append(button) // プロパティにも追加
        }
    }
    
    // タップされたボタンより左のボタンを全てセレクト状態にする
    private func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
            
            // アクセシビリティの文章。評価点と星が一緒場合のヒント文
            let hintString: String?
            if rating == index + 1 {
                hintString = "Tap to reset the rating to zero."
            } else {
                hintString = nil
            }
            
            // アクセシビリティの文章。評価点によって変わる。
            let valueString: String
            switch rating {
            case 0:
                valueString = "No rating set."
            default:
                valueString = "\(rating) stars set."
            }
            
            // アクセシビリティの文章をセット
            button.accessibilityHint = hintString
            button.accessibilityValue = valueString
        }
    }
}
