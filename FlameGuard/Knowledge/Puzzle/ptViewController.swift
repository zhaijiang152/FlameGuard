import UIKit

class ptViewController: UIViewController {
    class PuzzlePiece: UIImageView {
        var correctPosition: CGPoint!
        var isInCorrectPosition = false
        var row: Int = 0
        var col: Int = 0
        
        init(image: UIImage, displaySize: CGSize, row: Int, col: Int) {
            super.init(image: image)
            self.frame.size = displaySize
            self.row = row
            self.col = col
            setupAppearance()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupAppearance() {
            self.layer.borderWidth = 1.0
            self.layer.borderColor = UIColor.white.cgColor
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOffset = CGSize(width: 2, height: 2)
            self.layer.shadowOpacity = 0.5
            self.layer.shadowRadius = 3
        }
    }
    
    let seasonName: String
    let seasonCode: String
    let seasonDescription: String
    
    var originalImage: UIImage!
    var puzzlePieces: [PuzzlePiece] = []
    var completionFrame: CGRect!
    var selectedPiece: PuzzlePiece?
    
    let rows = 3
    let cols = 3
    
    init(seasonName: String, seasonCode: String, seasonDescription: String) {
        self.seasonName = seasonName
        self.seasonCode = seasonCode
        self.seasonDescription = seasonDescription
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .white
            title = seasonName
            
            // 安全设置导航栏标题字体
            if let font = UIFont(name: "slideyouran-Regular", size: 30) {
                navigationController?.navigationBar.titleTextAttributes = [
                    .font: font,
                    .foregroundColor: UIColor.black
                ]
            }
            
            // 安全加载图片，避免崩溃
            originalImage = UIImage(named: seasonCode) ?? UIImage(named: "defaultImage") ?? UIImage(systemName: "photo")!
            setupGame()
        }

    func setupGame() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // 确保 originalImage 不为 nil
        guard originalImage != nil else {
            print("❌ Error: Failed to load image for seasonCode: \(seasonCode)")
            return
        }
        
        let completionWidth = screenWidth * 0.8
        let completionHeight = completionWidth * (originalImage.size.height / originalImage.size.width)
        
        completionFrame = CGRect(
            x: (screenWidth - completionWidth) / 2,
            y: (screenHeight - completionHeight) / 3,
            width: completionWidth,
            height: completionHeight
        )
        
        // 绘制完成区域边框
        let completionArea = UIView(frame: completionFrame)
        completionArea.layer.borderWidth = 2
        completionArea.layer.borderColor = UIColor.gray.cgColor
        completionArea.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        view.addSubview(completionArea)
        
        generatePuzzlePieces()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    func generatePuzzlePieces() {
        puzzlePieces.forEach { $0.removeFromSuperview() }
        puzzlePieces.removeAll()
        
        let pieceWidth = completionFrame.width / CGFloat(cols)
        let pieceHeight = completionFrame.height / CGFloat(rows)
        let resizedImage = originalImage.resized(to: completionFrame.size)
        
        for row in 0..<rows {
            for col in 0..<cols {
                let x = CGFloat(col) * pieceWidth
                let y = CGFloat(row) * pieceHeight
                let pieceRect = CGRect(x: x, y: y, width: pieceWidth, height: pieceHeight)
                
                guard let pieceImage = resizedImage.cropped(to: pieceRect) else {
                    print("裁剪失败 at row \(row), col \(col)")
                    continue
                }
                
                // 创建拼图块
                let piece = PuzzlePiece(
                    image: pieceImage,
                    displaySize: CGSize(width: pieceWidth, height: pieceHeight),
                    row: row,
                    col: col
                )
                
                let correctX = completionFrame.minX + CGFloat(col) * pieceWidth + pieceWidth / 2
                let correctY = completionFrame.minY + CGFloat(row) * pieceHeight + pieceHeight / 2
                piece.correctPosition = CGPoint(x: correctX, y: correctY)
                
                // 随机初始位置（屏幕底部）
                let randomX = CGFloat.random(in: 0...(UIScreen.main.bounds.width - pieceWidth))
                
                // 确保随机 Y 坐标范围有效
                let minY = completionFrame.maxY + 50
                let maxY = UIScreen.main.bounds.height - pieceHeight
                let randomY: CGFloat
                if minY < maxY {
                    randomY = CGFloat.random(in: minY...maxY)
                } else {
                    randomY = maxY
                }
                
                piece.frame.origin = CGPoint(x: randomX, y: randomY)
                
                piece.isUserInteractionEnabled = true
                view.addSubview(piece)
                puzzlePieces.append(piece)
            }
        }
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: view)
        
        switch gesture.state {
        case .began:
            for piece in puzzlePieces.reversed() {
                if piece.frame.contains(location) && !piece.isInCorrectPosition {
                    selectedPiece = piece
                    view.bringSubviewToFront(piece)
                    UIView.animate(withDuration: 0.2) {
                        piece.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    }
                    break
                }
            }
            
        case .changed:
            selectedPiece?.center = location
            
        case .ended, .cancelled:
            if let piece = selectedPiece {
                UIView.animate(withDuration: 0.2) {
                    piece.transform = CGAffineTransform.identity
                }
                
                checkPiecePosition(piece)
                selectedPiece = nil
                
                if puzzlePieces.allSatisfy({ $0.isInCorrectPosition }) {
                    showCompletionAlert()
                }
            }
            
        default:
            break
        }
    }
    
    func checkPiecePosition(_ piece: PuzzlePiece) {
        let distance = hypot(piece.center.x - piece.correctPosition.x,
                            piece.center.y - piece.correctPosition.y)
        let threshold = min(piece.frame.width, piece.frame.height) / 4
        
        if distance < threshold {
            UIView.animate(withDuration: 0.3) {
                piece.center = piece.correctPosition
            }
            piece.isInCorrectPosition = true
        } else {
            piece.isInCorrectPosition = false
        }
    }
    
    func showCompletionAlert() {
        let alert = UIAlertController(title: seasonName, message: seasonDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "再玩一次", style: .default, handler: { _ in
            self.resetGame()
        }))
        alert.addAction(UIAlertAction(title: "确定", style: .cancel))
        present(alert, animated: true)
    }
    
    func resetGame() {
        puzzlePieces.forEach { $0.removeFromSuperview() }
        puzzlePieces.removeAll()
        setupGame()
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    
    func cropped(to rect: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        // 转换坐标系（UIImage坐标系原点在左上角，CGImage在左下角）
        let croppingRect = CGRect(
            x: rect.origin.x * scale,
            y: rect.origin.y * scale,
            width: rect.width * scale,
            height: rect.height * scale
        )
        
        // 确保裁剪范围有效
        if croppingRect.maxX > CGFloat(cgImage.width) || croppingRect.maxY > CGFloat(cgImage.height) {
            return nil
        }
        
        guard let croppedCGImage = cgImage.cropping(to: croppingRect) else { return nil }
        return UIImage(cgImage: croppedCGImage, scale: scale, orientation: imageOrientation)
    }
}
