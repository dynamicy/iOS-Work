//
//  ViewController.swift
//  CalendarWeekView
//
//  Created by Chris on 2018/11/28.
//

import UIKit

public protocol ForceUpdateTimeDelegate : class {
    
//    func setTime()
    
//    func setTime(point: CGPoint, units: Int)
    
//    func updateTime(_ weekView: JZLongPressWeekView, editingEvent: AllDayEvent)
//    func updateTime(_ weekView: JZLongPressWeekView)
    func updateTime(cell: JZLongPressEventCell, units: Int)
}

class ViewController: UIViewController {
    
    @IBOutlet weak var calendarWeekView: DefaultWeekView!
    
    let viewModel = DefaultViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add this to fix lower than iOS11 problems
        self.automaticallyAdjustsScrollViewInsets = false
        
        setupCalendarView()
        setupNaviBar()
    }
    
    // Support device orientation change
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        JZWeekViewHelper.viewTransitionHandler(to: size, weekView: calendarWeekView)
    }
    
}

extension ViewController {
    
    private func setupCalendarView() {
        calendarWeekView.baseDelegate = self
        calendarWeekView.forceUpdateTimeDelegate = self
        
        if viewModel.currentSelectedData != nil {
            setupCalendarViewWithSelectedData()
        } else {
            calendarWeekView.setupCalendar(numOfDays: 1,
                                           setDate: Date(),
                                           allEvents: viewModel.eventsByDate,
                                           scrollType: .sectionScroll)
        }
        
        // LongPress delegate, datasorce and type setup
        calendarWeekView.longPressDelegate = self
        calendarWeekView.tapGestureDelegate = self
        calendarWeekView.longPressDataSource = self
        calendarWeekView.longPressTypes = [.addNew, .move]
        
        // Optional
        calendarWeekView.addNewDurationMins = 120
        calendarWeekView.moveTimeMinInterval = 15
    }
    
    /// For example only
    private func setupCalendarViewWithSelectedData() {
        guard let selectedData = viewModel.currentSelectedData else { return }
        calendarWeekView.setupCalendar(numOfDays: selectedData.numOfDays,
                                       setDate: selectedData.date,
                                       allEvents: viewModel.eventsByDate,
                                       scrollType: selectedData.scrollType,
                                       firstDayOfWeek: selectedData.firstDayOfWeek)
        calendarWeekView.updateFlowLayout(JZWeekViewFlowLayout(hourGridDivision: selectedData.hourGridDivision))
    }
}

extension ViewController: JZBaseViewDelegate {
    
    func initDateDidChange(_ weekView: JZBaseWeekView, initDate: Date) {
        updateNaviBarTitle()
    }
}

extension ViewController {
    
    private func setupNaviBar() {
        updateNaviBarTitle()
    }
    
    private func getSelectedData() -> OptionsSelectedData {
        let numOfDays = calendarWeekView.numOfDays!
        let firstDayOfWeek = numOfDays == 7 ? calendarWeekView.firstDayOfWeek : nil
        viewModel.currentSelectedData = OptionsSelectedData(viewType: .defaultView,
                                                            date: calendarWeekView.initDate.add(component: .day, value: numOfDays),
                                                            numOfDays: numOfDays,
                                                            scrollType: calendarWeekView.scrollType,
                                                            firstDayOfWeek: firstDayOfWeek,
                                                            hourGridDivision: calendarWeekView.flowLayout.hourGridDivision)
        return viewModel.currentSelectedData
    }
    
    func finishUpdate(selectedData: OptionsSelectedData) {
        
        // Update numOfDays
        if selectedData.numOfDays != viewModel.currentSelectedData.numOfDays {
            calendarWeekView.numOfDays = selectedData.numOfDays
            calendarWeekView.refreshWeekView()
        }
        // Update Date
        if selectedData.date != viewModel.currentSelectedData.date {
            calendarWeekView.updateWeekView(to: selectedData.date)
        }
        // Update Scroll Type
        if selectedData.scrollType != viewModel.currentSelectedData.scrollType {
            calendarWeekView.scrollType = selectedData.scrollType
        }
        // Update FirstDayOfWeek
        if selectedData.firstDayOfWeek != viewModel.currentSelectedData.firstDayOfWeek {
            calendarWeekView.updateFirstDayOfWeek(setDate: selectedData.date, firstDayOfWeek: selectedData.firstDayOfWeek)
        }
        // Update hourGridDivision
        if selectedData.hourGridDivision != viewModel.currentSelectedData.hourGridDivision {
            calendarWeekView.updateFlowLayout(JZWeekViewFlowLayout(hourGridDivision: selectedData.hourGridDivision))
        }
        
    }
    
    private func updateNaviBarTitle() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM YYYY"
        self.navigationItem.title = dateFormatter.string(from: calendarWeekView.initDate.add(component: .day, value: calendarWeekView.numOfDays))
    }
}

// LongPress core
extension ViewController: JZLongPressViewDelegate, JZLongPressViewDataSource {
    
    func weekView(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date) {
        let newEvent = AllDayEvent(id: UUID().uuidString, title: "New Event", startDate: startDate, endDate: startDate.add(component: .hour, value: weekView.addNewDurationMins/60),
                                   location: "Melbourne", isAllDay: false)
        
        if viewModel.eventsByDate[startDate.startOfDay] == nil {
            viewModel.eventsByDate[startDate.startOfDay] = [AllDayEvent]()
        }
        viewModel.events.append(newEvent)
        viewModel.eventsByDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: viewModel.events)
        weekView.forceReload(reloadEvents: viewModel.eventsByDate)
    }
    
    func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date) {
        let event = editingEvent as! AllDayEvent
        let duration = Calendar.current.dateComponents([.minute], from: event.startDate, to: event.endDate).minute!
        let selectedIndex = viewModel.events.index(where: { $0.id == event.id })!
        viewModel.events[selectedIndex].startDate = startDate
        viewModel.events[selectedIndex].endDate = startDate.add(component: .minute, value: duration)
        
        viewModel.eventsByDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: viewModel.events)
        weekView.forceReload(reloadEvents: viewModel.eventsByDate)
    }
    
    func weekView(_ weekView: JZLongPressWeekView, viewForAddNewLongPressAt startDate: Date) -> UIView {
        let view = UINib(nibName: LongPressEventCell.className, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! LongPressEventCell
        view.titleLabel.text = "New Event"
//        view.delete(<#T##sender: Any?##Any?#>)
        return view
    }
}

extension ViewController: TapGestureDelegate {
    
    // KOFKOFKOFKOFKOFKOFKOFKOFKOFKOFKOFKOFKOFKOFKOFKOFKOF
    func tap(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date) {
        let event = editingEvent as! AllDayEvent
        let duration = Calendar.current.dateComponents([.minute], from: event.startDate, to: event.endDate).minute!
        let selectedIndex = viewModel.events.index(where: { $0.id == event.id })!
        viewModel.events[selectedIndex].startDate = startDate
//        viewModel.events[selectedIndex].endDate = startDate.add(component: .minute, value: duration).add(component: .hour, value: 1)
        viewModel.events[selectedIndex].endDate = startDate.add(component: .minute, value: duration)
        
        viewModel.eventsByDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: viewModel.events)
        weekView.forceReload(reloadEvents: viewModel.eventsByDate)
    }
}

extension ViewController: ForceUpdateTimeDelegate {
    func updateTime(cell: JZLongPressEventCell, units: Int) {
        
        var temp = self.calendarWeekView.collectionView.indexPath(for: cell)
         print("")
    }

//    func updateTime(_ weekView: JZLongPressWeekView, editingEvent: AllDayEvent) {
//        let selectedIndex = viewModel.events.index(where: { $0.id == editingEvent.id })!
//
//        viewModel.events[selectedIndex] = editingEvent
//        viewModel.eventsByDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: viewModel.events)
//        weekView.forceReload(reloadEvents: viewModel.eventsByDate)
//    }

//    func decreaseTime(_ weekView: JZLongPressWeekView, event: AllDayEvent) {
//        let selectedIndex = viewModel.events.index(where: { $0.id == event.id })!
//
//        viewModel.events[selectedIndex] = event
//        viewModel.eventsByDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: viewModel.events)
//        weekView.forceReload(reloadEvents: viewModel.eventsByDate)
//    }
}
