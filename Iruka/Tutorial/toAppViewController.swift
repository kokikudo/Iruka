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
    //
    private var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initPageViewController()
        
        //
        self.setPageControl()
    }
    
    
    private func initPageViewController() {
        
        // 画像がセットされたビューを配列に格納する関数
        addingViewToArray(imageCount: 6)
        
        // PageViewControllerの定義
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageViewController.setViewControllers([self.controllers[0]], direction: .forward, animated: true, completion: nil)
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        
        // このビューにコントローラーとそのViewをそれぞれ追加
        self.addChild(self.pageViewController)
        self.view.addSubview(self.pageViewController.view!)
    }
    
    private func setPageControl() {
        //
        self.pageControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY - 100, width: UIScreen.main.bounds.width, height: 50))
        //
        self.pageControl.numberOfPages = self.controllers.count
        //
        self.pageControl.currentPage = 0
        //
        self.pageControl.pageIndicatorTintColor = .gray
        //
        self.pageControl.currentPageIndicatorTintColor = UIColor(named: "Button")
        
        self.view.addSubview(self.pageControl)
    }
    
    // アセットカタログにセットした画像を作成したビューに全面貼り付けして配列に格納
    // 画像の名前は今の所はただの番号にすること
    private func addingViewToArray(imageCount: Int) {
        for i in 1 ... imageCount {
            let myViewController: UIViewController = UIViewController()
            
            myViewController.view.frame = self.view.frame
            
            myViewController.view.backgroundColor = UIColor(named: "Background")
            
            let image = UIImage(named: "\(i)")!
            let imageView = UIImageView(image: image)
            
            myViewController.view.addSubview(imageView)
            
            imageView.contentMode = .scaleAspectFit
            
            // AutoLayout解除
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            // 制約を決める
            NSLayoutConstraint.activate([
                // サイズ
                imageView.widthAnchor.constraint(equalToConstant: myViewController.view.bounds.maxX), // 横幅：画面いっぱい
                imageView.heightAnchor.constraint(equalToConstant: myViewController.view.bounds.maxY - 100), // 縦幅：一番下から100を引く(PageControlより50上)
                
                // レイアウト
                imageView.topAnchor.constraint(equalTo: myViewController.view.safeAreaLayoutGuide.topAnchor, constant: 8), // top
                imageView.leftAnchor.constraint(equalTo: myViewController.view.safeAreaLayoutGuide.leftAnchor, constant: 8), // left
                imageView.rightAnchor.constraint(equalTo: myViewController.view.safeAreaLayoutGuide.rightAnchor, constant: 8) // right
                ])
        
            // 最後のビューなら閉じるボタン追加
//            if i == imageCount {
//                let button = UIButton()
//                button.frame = CGRect(x: screenWidth/2 - 50, y: UIScreen.main.bounds.maxY - 150, width: 100, height: 50)
//
//                button.setTitle("始める", for: .normal)
//                button.setTitleColor(.white, for: .normal)
//                button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
//                button.backgroundColor = UIColor(named: "Button")
//                button.layer.cornerRadius = 20
//                button.layer.masksToBounds = true
//                button.addAction(.init { _ in self.dismiss(animated: true, completion: nil) }, for: .touchUpInside)
//                myViewController.view.addSubview(button)
//            }
            
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

