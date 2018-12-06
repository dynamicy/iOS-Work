//
//  LongPressEventCell.swift
//  DragItems
//
//  Created by Chris on 2018/11/28.
//

import UIKit

class LongPressEventCell: JZLongPressEventCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var borderView: UIView!
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var bottomView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupBasic()
        
        setGesture()
        
        self.contentView.backgroundColor = UIColor(hex: 0xEEF7FF)
    }
    
    func setGesture() {
        let topViewLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleTopViewLongPressGesture(_:)))
        topViewLongPressGesture.delegate = self
        topView.addGestureRecognizer(topViewLongPressGesture)
        
        let bottomViewLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleBottomViewLongPressGesture(_:)))
        bottomViewLongPressGesture.delegate = self
        bottomView.addGestureRecognizer(bottomViewLongPressGesture)
        
        let mainViewLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleMainViewLongPressGesture(_:)))
        mainViewLongPressGesture.delegate = self
        self.addGestureRecognizer(mainViewLongPressGesture)
    }
    
    func setupBasic() {
        self.clipsToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 5
        layer.shadowOpacity = 0
        locationLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        borderView.backgroundColor = UIColor(hex: 0x0899FF)
    }
    
    func configureCell(event: AllDayEvent, isAllDay: Bool = false) {
        self.event = event
        locationLabel.text = event.location
        titleLabel.text = event.title
        
        locationLabel.isHidden = isAllDay
    }
    
}

extension LongPressEventCell: UIGestureRecognizerDelegate {
    
    @objc private func handleTopViewLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        print("1111")
    }
    
    @objc private func handleBottomViewLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        print("222222")
    }
    
    @objc private func handleMainViewLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        print("33333")
    }
}

extension UIColor {
    
    fileprivate convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: a
        )
    }
    // Get UIColor by hex
    fileprivate convenience init(hex: Int, a: CGFloat = 1.0) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF,
            a: a
        )
    }
}
