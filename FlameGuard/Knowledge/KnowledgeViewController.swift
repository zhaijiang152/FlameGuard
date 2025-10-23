//
//  KnowledgeViewController.swift
//  FlameGuard
//
//  Created by 陈爽 on 2025/10/18.
//

import UIKit
import SnapKit

class KnowledgeViewController:UIViewController{
    
    let LearnData:[LearnItem] = [
        LearnItem(image: "AI消防", title: "AI消防助手", subtitle: "有问必答的安全小帮手", color:.learn_pinkcolor,linearcolor: .learn_pinklinearcolor),
        LearnItem(image: "拼图游戏", title: "拼图游戏", subtitle: "拼出安全与救援", color: .learn_yellowcolor,linearcolor: .learn_yellowlinearcolor),
        LearnItem(image: "火灾科学", title: "火灾科学", subtitle: "探索火灾形成原理与预防", color: .learn_bluecolor,linearcolor: .learn_bluelinearcolor),
        LearnItem(image: "逃生大师", title: "逃生大师", subtitle: "掌握紧急逃生技能", color: .learn_greencolor,linearcolor: .learn_greenlinearcolor)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
    }
    
    private func setupUI(){
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.addSubview(backgroundView)
        view.addSubview(collectionView)
    }

    private func setupLayout(){
        backgroundView.snp.makeConstraints{ make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        collectionView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(520)
        }
    }
    
    lazy var backgroundView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "homeBackground"))
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 180, height: 250)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.register(LearnCell.self, forCellWithReuseIdentifier: "LearnCell")
        collection.delegate = self
        collection.dataSource = self
        collection.isScrollEnabled = false
        collection.alwaysBounceVertical = true
        collection.contentInsetAdjustmentBehavior = .never
        return collection
    }()
    func openPuzzleGame() {
        let vc = ViewControllerpt()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    func openAIChat() {
        let vc = AIController(apiKey: "c4f36248dee84037a00880cf19655b1b.lSITW8ptgG2WXzlA")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
}
extension KnowledgeViewController:UICollectionViewDataSource,UICollectionViewDelegate{
    // MARK: - DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return LearnData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LearnCell", for: indexPath) as! LearnCell
        cell.configure(with: LearnData[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = LearnData[indexPath.item]
        switch item.title {
        case "AI消防助手":
            openAIChat()
        case "拼图游戏":
            openPuzzleGame()
        default:
            break
        }
    }
}
