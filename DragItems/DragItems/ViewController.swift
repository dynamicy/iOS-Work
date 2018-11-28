//
//  ViewController.swift
//  DragItems
//
//  Created by Chris on 2018/11/28.
//

import UIKit
import JZCalendarWeekView

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
    
    private func setupCalendarView() {
        
        calendarWeekView.baseDelegate = self
        
        // For example only
        if viewModel.currentSelectedData != nil {
            setupCalendarViewWithSelectedData()
            return
        }
        // Basic setup
        calendarWeekView.setupCalendar(numOfDays: 1,
                                       setDate: Date(),
                                       allEvents: viewModel.eventsByDate,
                                       scrollType: .pageScroll)
        // Optional
        calendarWeekView.updateFlowLayout(JZWeekViewFlowLayout(hourGridDivision: JZHourGridDivision.noneDiv))
    }
    
    /// For example only
//    private func setupCalendarViewWithSelectedData() {
//        guard let selectedData = viewModel.currentSelectedData else { return }
//        calendarWeekView.setupCalendar(numOfDays: selectedData.numOfDays,
//                                       setDate: selectedData.date,
//                                       allEvents: viewModel.eventsByDate,
//                                       scrollType: selectedData.scrollType,
//                                       firstDayOfWeek: selectedData.firstDayOfWeek)
//        calendarWeekView.updateFlowLayout(JZWeekViewFlowLayout(hourGridDivision: selectedData.hourGridDivision))
//    }

}

extension ViewController {
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: JZBaseViewDelegate {
    
    func initDateDidChange(_ weekView: JZBaseWeekView, initDate: Date) {
        updateNaviBarTitle()
    }
}

extension ViewController {
    
    func setupBasic() {
        // Add this to fix lower than iOS11 problems
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
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
