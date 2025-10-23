//
//  learnCell.swift
//  FlameGuard
//
//  Created by 陈爽 on 2025/10/19.
//

import UIKit
import SnapKit

struct LearnItem{
    var image:String
    var title:String
    var subtitle:String
    var color:UIColor
    var linearcolor:UIColor
}

class LearnCell:UICollectionViewCell{
    
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 布局变化时更新渐变层
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = contentView.bounds
    }
    
    private func setupUI(){
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        setupGradientLayer()
        contentView.addSubview(imageView)
        contentView.addSubview(title)
        contentView.addSubview(subtitle)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(14)
            make.leading.trailing.equalToSuperview().inset(10)
            make.width.height.equalTo(160)
        }
        title.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(imageView.snp.bottom).offset(16)
        }
        subtitle.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
    
    private func setupGradientLayer() {
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor]
        contentView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    lazy var imageView:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    lazy var title:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var subtitle:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.numberOfLines = 0
        return label
    }()
    
    func configure(with item:LearnItem){
        self.imageView.image = UIImage(named: item.image)
        self.title.text = item.title
        self.title.textColor = item.color
        self.subtitle.text = item.subtitle
        gradientLayer.colors = [
            item.linearcolor.withAlphaComponent(1).cgColor,
            UIColor.white.cgColor
        ]
    }
}
