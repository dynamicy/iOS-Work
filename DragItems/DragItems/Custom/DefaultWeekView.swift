//
//  DefaultWeekView.swift
//  DragItems
//
//  Created by Chris on 2018/11/28.
//

import UIKit
import JZCalendarWeekView

class DefaultWeekView: JZBaseWeekView {
    
    override func registerViewClasses() {
        super.registerViewClasses()
        
        self.collectionView.register(UINib(nibName: EventCell.className, bundle: nil), forCellWithReuseIdentifier: EventCell.className)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCell.className, for: indexPath) as! EventCell
        cell.configureCell(event: getCurrentEvent(with: indexPath) as! DefaultEvent)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedEvent = getCurrentEvent(with: indexPath) as! DefaultEvent
        ToastUtil.toastMessageInTheMiddle(message: selectedEvent.title)
    }
}
