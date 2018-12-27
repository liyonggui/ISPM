import UIKit

/// 摄像头 VC
class CameraViewController: BaseViewController {
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        // 间距
        let spacing = 5
        // 一行几个
        let count = 3
        // 减去间距的宽度
        let viewWidth = spacing * (count - 1)
        // 每个cellk宽度
        let width = (SCREEN_WIDTH - CGFloat(viewWidth)) / CGFloat(count)
        
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumLineSpacing = CGFloat(spacing)
        layout.minimumInteritemSpacing = CGFloat(spacing)
        layout.scrollDirection = .vertical
//        layout.sectionInset = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        
        let v = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        v.registerNib(for: CameraCollectionViewCell.self)
        v.delegate = self
        v.dataSource = self
        v.backgroundColor = .white
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar(title: "摄像头")
        view.addSubview(collectionView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
}

// MARK: - 数据代理
extension CameraViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(of: CameraCollectionViewCell.self, for: indexPath, configure: { cell in
            MyPrint(indexPath.item)
            MyPrint(cell)
        })
    }
}

// MARK: - #name#
extension CameraViewController: UICollectionViewDelegate {
    
}
