//
//  DefaultWeekView.swift
//  DragItems
//
//  Created by Chris on 2018/11/28.
//

import UIKit

class DefaultWeekView: JZLongPressWeekView {
    
    var forceUpdateTimeDelegate: ForceUpdateTimeDelegate?
    
    override func registerViewClasses() {
        super.registerViewClasses()
        
        self.collectionView.register(UINib(nibName: LongPressEventCell.className, bundle: nil), forCellWithReuseIdentifier: LongPressEventCell.className)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LongPressEventCell.className, for: indexPath) as! LongPressEventCell
        
        let selectedEvent = getCurrentEvent(with: indexPath) as! AllDayEvent
        
        cell.configureCell(event: selectedEvent)
        
        cell.updateTimeDelegate = self
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == JZSupplementaryViewKinds.allDayHeader {
            let alldayHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as! JZAllDayHeader
            let date = flowLayout.dateForColumnHeader(at: indexPath)
            let events = allDayEventsBySection[date]
            let views = getAllDayHeaderViews(allDayEvents: events as? [AllDayEvent] ?? [])
            alldayHeader.updateView(views: views)
            return alldayHeader
        }
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    private func getAllDayHeaderViews(allDayEvents: [AllDayEvent]) -> [UIView] {
        var allDayViews = [UIView]()
        for event in allDayEvents {
            let view = UINib(nibName: LongPressEventCell.className, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! LongPressEventCell
            view.configureCell(event: event, isAllDay: true)
            allDayViews.append(view)
        }
        return allDayViews
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedEvent = getCurrentEvent(with: indexPath) as! AllDayEvent
        ToastUtil.toastMessageInTheMiddle(message: selectedEvent.title)
        selectedEvent.title = "frjkgljrlkg"
        selectedEvent.endDate = selectedEvent.endDate.add(component: .hour, value: 1)

        var temp = self
//        self.collectionView.reloadItems(at: [indexPath])
        
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LongPressEventCell.className, for: indexPath) as! LongPressEventCell
//        cell.configureCell(event: getCurrentEvent(with: indexPath) as! AllDayEvent)
        
        self.collectionView.reloadData()
    }
}

extension DefaultWeekView: UpdateTimeEventDelegate {
    
    func setTime(cell: JZLongPressEventCell, units: Int) {
        print("cellcellcellcellcell")
        
        forceUpdateTimeDelegate?.updateTime(cell: cell, units: units)
    }
}
