import UIKit

class SeasonCell: UICollectionViewCell {
    static let identifier = "SeasonCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 0.8, green: 0.6, blue: 0.2, alpha: 1)
        label.font = UIFont(name: "slideyouran-Regular", size: 30)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private let backgroundImageView: UIImageView = {
        let background = UIImageView()
        background.contentMode = .scaleAspectFill
        background.clipsToBounds = true
        background.alpha = 0.7
        return background
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(titleLabel)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String, imageName: String, column: Int) {
        titleLabel.text = title
        backgroundImageView.image = UIImage(named: imageName) // 使用传入的图片名称
        
        // 根据列设置不同的背景色
        switch column {
        case 0:
            contentView.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.9, alpha: 1)
           
        case 1:
            contentView.backgroundColor = UIColor(red: 0.0, green: 0.3, blue: 0.2, alpha: 1)
        case 2:
            contentView.backgroundColor = UIColor(red: 1.0, green: 0.8, blue: 0.4, alpha: 1)
        case 3:
            contentView.backgroundColor = UIColor(red: 0.7, green: 0.8, blue: 1.0, alpha: 1)
        default:
            contentView.backgroundColor = .white
        }
    }
}
