import UIKit
import SnapKit

struct SetItem{
    var iconName:String
    var title:String
}

class SetCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var items: [SetItem] = []

    init(items: [SetItem]) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        super.init(frame: .zero, collectionViewLayout: layout)
        self.items = items
        backgroundColor = .white
        dataSource = self
        delegate = self
        register(SetCVCell.self, forCellWithReuseIdentifier: "SetCVCell")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SetCVCell", for: indexPath) as! SetCVCell
        cell.configure(with: items[indexPath.item])
        return cell
    }

    // MARK: - Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        return CGSize(width: width, height: 60)
    }
}

class SetCVCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let moreImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        
        imageView.contentMode = .scaleAspectFit
        
        moreImageView.image = UIImage(named: "arrow")
        moreImageView.contentMode = .scaleAspectFit
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center

        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(moreImageView)

        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(22)
            make.centerY.equalToSuperview()
        }
        
        moreImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(22)
            make.centerY.equalToSuperview()
            make.width.equalTo(7)
            make.height.equalTo(14)
        }
    }

    func configure(with item: SetItem) {
        imageView.image = UIImage(named: item.iconName)
        titleLabel.text = item.title
    }
}
