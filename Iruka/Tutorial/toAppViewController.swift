//
//  toAppViewController.swift
//  Iruka
//
//  Created by kudo koki on 2021/06/03.
//

import UIKit

class toAppViewController: UIViewController {
    
    private var pageViewController: UIPageViewController!
    private var controllers: [UIViewController] = []
    private var pageControl: UIPageControl!
    private let imageCount = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initPageViewController()
        
        //
        self.setPageControl()
    }
    
    //　UIPageViewControllerを定義
    private func initPageViewController() {
        
        // 画像がセットされたビューを配列に格納する関数
        addingViewToArray(imageCount: imageCount)
        
        // PageViewControllerの定義
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageViewController.setViewControllers([self.controllers[0]], direction: .forward, animated: true, completion: nil)
        
        // 動作を定義するデリゲートメソッド
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        
        // コントローラーとビューを追加
        self.addChild(self.pageViewController)
        self.view.addSubview(self.pageViewController.view!)
    }
    
    // ページコントロール（現在のページの場所を表示するコントローラー）
    private func setPageControl() {
        // UIView ContorollerのpageControlプロパティにUIPageControlインスタンスをセット
        self.pageControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY - 100, width: UIScreen.main.bounds.width, height: 50))
        // 総ページ数
        self.pageControl.numberOfPages = self.controllers.count
        //　最初のページ
        self.pageControl.currentPage = 0
        // 他のページの色
        self.pageControl.pageIndicatorTintColor = .gray
        // 現在のページの色
        self.pageControl.currentPageIndicatorTintColor = UIColor(named: "Button")
        // 設置
        self.view.addSubview(self.pageControl)
    }
    
    // アセットカタログにセットした画像を作成したビューに貼り付けして配列に格納
    // 画像の名前は今の所はただの番号にすること
    private func addingViewToArray(imageCount: Int) {
        for i in 1 ... imageCount {
            // 画像を設置するためのビューを作成
            let myViewController: UIViewController = UIViewController()
            myViewController.view.frame = self.view.frame
            myViewController.view.backgroundColor = UIColor(named: "Background")
            
            // 画像を作成
            let image = UIImage(named: "\(i).001")!
            let imageView = UIImageView(image: image)
            myViewController.view.addSubview(imageView)
            
            // アスペクト比を崩さずに最大まで拡大
            imageView.contentMode = .scaleAspectFit
            
            // 制約を決める: 最初に自動でレイアウトを決めてくれる機能を無効にする
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                // サイズ
                imageView.widthAnchor.constraint(equalToConstant: myViewController.view.bounds.maxX), // 横幅：画面いっぱい
                imageView.heightAnchor.constraint(equalToConstant: myViewController.view.bounds.maxY - 100), // 縦幅：一番下から100を引く(PageControlより50上)
                
                // レイアウト: 上、左、右をセーフエリアから8pxで固定
                imageView.topAnchor.constraint(equalTo: myViewController.view.safeAreaLayoutGuide.topAnchor, constant: 8),
                imageView.leftAnchor.constraint(equalTo: myViewController.view.safeAreaLayoutGuide.leftAnchor, constant: 8),
                imageView.rightAnchor.constraint(equalTo: myViewController.view.safeAreaLayoutGuide.rightAnchor, constant: 8)
            ])
            
            // 最後のビューなら閉じるボタン追加
            if i == imageCount {
                let button = UIButton()
                button.setTitle("閉じる", for: .normal)
                button.setTitleColor(.white, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
                button.backgroundColor = UIColor(named: "Button")
                button.layer.cornerRadius = 20
                button.layer.masksToBounds = true
                // タップするとビューを閉じる
                button.addAction(.init { _ in self.dismiss(animated: true, completion: nil) }, for: .touchUpInside)
                myViewController.view.addSubview(button)
                
                // 制約
                button.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    // サイズ: とりあえず横100縦50で固定
                    button.widthAnchor.constraint(equalToConstant: 100),
                    button.heightAnchor.constraint(equalToConstant: 50),
                    // レイアウト: 中心に固定しイメージ画像の下辺に合わせる
                    button.centerXAnchor.constraint(equalTo: myViewController.view.centerXAnchor),
                    button.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
                ])
            }
            // 配列に追加
            self.controllers.append(myViewController)
        }
    }
}


extension toAppViewController: UIPageViewControllerDataSource {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        self.controllers.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let nowViewIndex = self.controllers.firstIndex(of: viewController),
           nowViewIndex < self.controllers.count - 1 {
            return self.controllers[nowViewIndex + 1]
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let nowViewIndex = self.controllers.firstIndex(of: viewController),
           nowViewIndex > 0 {
            return self.controllers[nowViewIndex - 1]
        } else {
            return nil
        }
    }
}

extension toAppViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        let currentPage = pageViewController.viewControllers![0]
        self.pageControl.currentPage = self.controllers.firstIndex(of: currentPage)!
    }
}

