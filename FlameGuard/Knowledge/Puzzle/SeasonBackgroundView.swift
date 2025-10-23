//
//  SeasonBackgroundView.swift
//  QYproject
//
//  Created by 清云 on 2025/5/22.
//

import UIKit

class SeasonBackgroundView: UICollectionReusableView {
    static let identifier = "SeasonBackgroundView"
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(for season: Int) {
        switch season {
        case 0: backgroundImageView.image = UIImage(named: "AAA")
        case 1: backgroundImageView.image = UIImage(named: "BBB")
        case 2: backgroundImageView.image = UIImage(named: "CCC")
        case 3: backgroundImageView.image = UIImage(named: "DDD")
        default: backgroundImageView.image = nil
        }
    }
}
