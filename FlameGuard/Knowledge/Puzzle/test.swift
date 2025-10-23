
import UIKit

struct SolarTerm {
    let name: String
    let code: String
    let description: String
    let imageName: String // 新增图片名称字段
}

class ViewControllerpt: UIViewController {
    
    private var collectionView: UICollectionView!
    private let backgroundImageView = UIImageView()

    let seasonsData: [SolarTerm] = [
        SolarTerm(name: "", code: "a1", description: "可燃物、助燃物和着火源缺一不可", imageName: "a1"),
        SolarTerm(name: "", code: "a2", description: "A类固体/B类液体/C类气体火灾区别", imageName: "a2"),
        SolarTerm(name: "", code: "a3", description: "干粉/泡沫/CO₂灭火器适用场景", imageName: "a3"),
        SolarTerm(name: "", code: "a4", description: "通用型灭火器，适用于A/B/C类火灾，注意使用后需及时清理残留粉末", imageName: "a4"),
        SolarTerm(name: "", code: "a5", description: "适用于精密仪器和电气火灾，使用时注意防冻伤和窒息风险", imageName: "a5"),
        SolarTerm(name: "", code: "a6", description: "环保型灭火器，适合A类固体火灾，不可用于电气和油类火灾", imageName: "a6"),
        
        SolarTerm(name: "", code: "b1", description: "火灾预防胜于救灾，日常消除隐患可避免90%以上火灾事故", imageName: "b1"),
        SolarTerm(name: "", code: "b2", description: "报警要冷静说明：起火地点、物质、火势及联系方式，保持电话畅通", imageName: "b2"),
        SolarTerm(name: "", code: "b3", description: "禁止在易燃物附近使用明火，祭祀、吸烟等火源必须完全熄灭", imageName: "b3"),
        SolarTerm(name: "", code: "b4", description: "林区严禁烟火，野外用火需审批，发现火情立即报告12119", imageName: "b4"),
        SolarTerm(name: "", code: "b5", description: "楼梯间、阳台不得堆放可燃物，确保逃生通道畅通无阻", imageName: "b5"),
        SolarTerm(name: "", code: "b6", description: "安全出口必须保持24小时畅通，防火门常闭不上锁", imageName: "b6"),
        
        SolarTerm(name: "", code: "c1", description: "90%火灾遇难者因缺乏逃生常识丧生，定期演练可提升70%生存率", imageName: "c1"),
        SolarTerm(name: "", code: "c2", description: "教室/宿舍起火应低姿快逃，严禁乘坐电梯，集合点需远离建筑", imageName: "c2"),
        SolarTerm(name: "", code: "c3", description: "提瓶→拔销→握管→压柄，对准火焰根部扫射（保持3-5米距离）", imageName: "c3"),
        SolarTerm(name: "", code: "c4", description: "浓烟中贴地照射逃生路径，频闪模式可发送求救信号（SOS节奏）", imageName: "c4"),
        SolarTerm(name: "", code: "c5", description: "30秒内完成佩戴：撕包装→拔塞子→套头带→滤毒罐朝外", imageName: "c5"),
        SolarTerm(name: "", code: "c6", description: "双手握黑色拉带，完全展开后覆盖火源，隔绝氧气灭火", imageName: "c6"),
        
        SolarTerm(name: "", code: "d1", description: "伦敦公寓大火：外墙保温材料引发的惨剧", imageName: "d1"),
        SolarTerm(name: "", code: "d2", description: "上海教师公寓：因电焊火花致58人遇难", imageName: "d2"),
        SolarTerm(name: "", code: "d3", description: "天津港爆炸：危险化学品管理教训", imageName: "d3"),
        SolarTerm(name: "", code: "d4", description: "气候变化下的消防新挑战", imageName: "d4"),
        SolarTerm(name: "", code: "d5", description: "78楼徒步逃生的正确决策", imageName: "d5"),
        SolarTerm(name: "", code: "d6", description: "森林火灾中的逆行者", imageName: "d6")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backButton.layer.cornerRadius = 20
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.frame = CGRect(x: 20, y: 50, width: 40, height: 40)
        view.addSubview(backButton)
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layout.headerReferenceSize = CGSize(width: view.bounds.width, height: 200)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.register(SeasonCell.self, forCellWithReuseIdentifier: SeasonCell.identifier)
        collectionView.register(
            SeasonBackgroundView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SeasonBackgroundView.identifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)
    }
    @objc private func backButtonTapped() {
        self.dismiss(animated: true)
    }
}
extension ViewControllerpt: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeasonCell.identifier, for: indexPath) as! SeasonCell
        let season = seasonsData[indexPath.section * 6 + indexPath.row]
        cell.configure(with: season.name, imageName: season.imageName, column: indexPath.section)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 20 * 2
        let spacing: CGFloat = 10 * 2
        let width = (collectionView.bounds.width - padding - spacing) / 3
        let height = (collectionView.bounds.height - 50) / 3 - 90
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let season = seasonsData[indexPath.section * 6 + indexPath.row]
        let detailVC = ptViewController(seasonName: season.name, seasonCode: season.code, seasonDescription: season.description)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            fatalError("Unsupported kind")
        }
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SeasonBackgroundView.identifier, for: indexPath) as! SeasonBackgroundView
        headerView.configure(for: indexPath.section)
        return headerView
    }
}
