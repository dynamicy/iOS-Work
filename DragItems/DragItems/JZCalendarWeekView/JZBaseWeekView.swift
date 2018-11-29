//
//  JZBaseWeekView.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 28/3/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

public protocol JZBaseViewDelegate: class {
    
    /// When initDate changed, this function will be called. You can get the current date by adding numOfDays on initDate
    ///
    /// - Parameters:
    ///   - weekView: current JZBaseWeekView
    ///   - initDate: the new value of initDate
    func initDateDidChange(_ weekView: JZBaseWeekView, initDate: Date)
}

extension JZBaseViewDelegate {
    // Keep it optional
    func initDateDidChange(_ weekView: JZBaseWeekView, initDate: Date) {}
}

open class JZBaseWeekView: UIView {
    
    public var collectionView: JZCollectionView!
    public var flowLayout: JZWeekViewFlowLayout!
    
    /**
     - The initial date of current collectionView. When page is not scrolling, the inital date is always
     (numOfDays) days before current page first date, which means the start of the collectionView, not the current page first date
     - The core structure of JZCalendarWeekView is 3 pages, previous-current-next
     - If you want to update this value instead of using [updateWeekView(to date: Date)](), please **make sure the date is startOfDay**.
    */
    public var initDate: Date! {
        didSet {
            baseDelegate?.initDateDidChange(self, initDate: initDate)
        }
    }
    public var numOfDays: Int!
    public var scrollType: JZScrollType!
    public var currentTimelineType: JZCurrentTimelineType! {
        didSet {
            let viewClass = currentTimelineType == .section ? JZCurrentTimelineSection.self : JZCurrentTimelinePage.self
            self.collectionView.register(viewClass, forSupplementaryViewOfKind: JZSupplementaryViewKinds.currentTimeline, withReuseIdentifier: JZSupplementaryViewKinds.currentTimeline)
        }
    }
    public var firstDayOfWeek: DayOfWeek?
    public var allEventsBySection: [Date: [JZBaseEvent]]! {
        didSet {
            self.isAllDaySupported = allEventsBySection is [Date: [JZAllDayEvent]]
            if isAllDaySupported {
                setupAllDayEvents()
            }
        }
    }
    public var notAllDayEventsBySection = [Date: [JZAllDayEvent]]()
    public var allDayEventsBySection = [Date: [JZAllDayEvent]]()
    
    public weak var baseDelegate: JZBaseViewDelegate?
    open var contentViewWidth: CGFloat {
        return frame.width - flowLayout.rowHeaderWidth
    }
    private var isFirstAppear: Bool = true
    internal var isAllDaySupported: Bool!
    internal var initialContentOffset = CGPoint.zero
    internal var scrollSections:CGFloat!
    private var isDirectionLocked = false
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
        
    open func setup() {
        
        flowLayout = JZWeekViewFlowLayout()
        flowLayout.delegate = self
        
        collectionView = JZCollectionView(frame: bounds, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isDirectionalLockEnabled = true
        collectionView.bounces = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.white
        addSubview(collectionView)
        collectionView.setAnchorConstraintsFullSizeTo(view: self)
        
        registerViewClasses()
    }
    
    /// Override this function to customise items, supplimentaryViews and decorationViews
    open func registerViewClasses() {
        // supplementary
        self.collectionView.registerSupplimentaryViews([JZColumnHeader.self, JZCornerHeader.self, JZRowHeader.self, JZAllDayHeader.self])
        
        // decoration
        flowLayout.registerDecorationViews([JZColumnHeaderBackground.self, JZRowHeaderBackground.self,
                                            JZAllDayHeaderBackground.self, JZAllDayCorner.self])
        flowLayout.register(JZGridLine.self, forDecorationViewOfKind: JZDecorationViewKinds.verticalGridline)
        flowLayout.register(JZGridLine.self, forDecorationViewOfKind: JZDecorationViewKinds.horizontalGridline)
    }
   
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        flowLayout.sectionWidth = contentViewWidth / CGFloat(numOfDays)
        initialContentOffset = collectionView.contentOffset
    }
    
    /**
     Basic Setup method for JZCalendarWeekView,it **must** be called.
     
     - Parameters:
        - numOfDays: Number of days in a page
        - setDate: The initial set date, the first date in current page except WeekView (numOfDays = 7)
        - allEvents: The dictionary of all the events for present. JZWeekViewHelper.getIntraEventsByDate can help transform the data
        - firstDayOfWeek: First day of a week, **only works when numOfDays is 7**. Default value is Sunday
        - scrollType: The horizontal scroll type for this view. Default value is pageScroll
        - currentTimelineType: The current time line type for this view. Default value is section
        - visibleTime: WeekView will be scroll to this time, when it appears the **first time**. This visibleTime only determines **y** offset. Defaut value is current time.
    */
    open func setupCalendar(numOfDays: Int,
                            setDate: Date,
                            allEvents: [Date:[JZBaseEvent]],
                            scrollType: JZScrollType = .pageScroll,
                            firstDayOfWeek :DayOfWeek? = nil,
                            currentTimelineType: JZCurrentTimelineType = .section,
                            visibleTime: Date = Date()) {
        
        self.numOfDays = numOfDays
        if numOfDays == 7 {
            updateFirstDayOfWeek(setDate: setDate, firstDayOfWeek: firstDayOfWeek ?? .Sunday)
        } else {
            self.initDate = setDate.startOfDay.add(component: .day, value: -numOfDays)
        }
        self.allEventsBySection = allEvents
        self.scrollType = scrollType
        self.currentTimelineType = currentTimelineType
        
        DispatchQueue.main.async { [unowned self] in
            self.layoutSubviews()
            self.forceReload(reloadEvents: allEvents)
            
            if self.isFirstAppear {
                self.isFirstAppear = false
                self.flowLayout.scrollCollectionViewTo(time: visibleTime)
            }
        }
    }
    
    open func setupAllDayEvents() {
        notAllDayEventsBySection.removeAll()
        allDayEventsBySection.removeAll()
        for (date, events) in allEventsBySection {
            let allDayEvents = events as! [JZAllDayEvent]
            notAllDayEventsBySection[date] = allDayEvents.filter { !$0.isAllDay }
            allDayEventsBySection[date] = allDayEvents.filter{ $0.isAllDay }
        }
    }
    
    open func updateAllDayBar(isScrolling: Bool) {
        guard isAllDaySupported else { return }
        var maxEventsCount: Int = 0
        getDatesInCurrentPage(isScrolling: isScrolling).forEach {
            let count = allDayEventsBySection[$0]?.count ?? 0
            if count > maxEventsCount {
                maxEventsCount = count
            }
        }
        flowLayout.allDayHeaderHeight = flowLayout.defaultAllDayOneLineHeight * CGFloat(min(maxEventsCount, 2))
    }
    
    /// Update collectionViewLayout with custom flowLayout. For some other values like gridThickness and contentsMargin, please inherit from JZWeekViewFlowLayout to change the default value
    /// - Parameter flowLayout: Custom CalendarWeekView flowLayout
    open func updateFlowLayout(_ flowLayout: JZWeekViewFlowLayout) {
        self.flowLayout.hourHeight = flowLayout.hourHeight
        self.flowLayout.rowHeaderWidth = flowLayout.rowHeaderWidth
        self.flowLayout.columnHeaderHeight = flowLayout.columnHeaderHeight
        self.flowLayout.hourGridDivision = flowLayout.hourGridDivision
        self.flowLayout.invalidateLayoutCache()
        self.flowLayout.invalidateLayout()
    }
    
    /// Reload the collectionView and flowLayout
    /// - Parameters:
    ///   - reloadEvents: If provided new events, current events will be reloaded. Default value is nil.
    open func forceReload(reloadEvents: [Date: [JZBaseEvent]]? = nil) {
        if let events = reloadEvents {
            self.allEventsBySection = events
        }
        
        // initial day is one page before the settle day
        collectionView.setContentOffsetWithoutDelegate(CGPoint(x:contentViewWidth, y:collectionView.contentOffset.y), animated: false)
        updateAllDayBar(isScrolling: false)
        
        flowLayout.invalidateLayoutCache()
        collectionView.reloadData()
    }
        
    
    /// Reload the WeekView to date with no animation
    /// - Parameters:
    ///    - date: this date is the current date in one-day view rather than initDate
    open func updateWeekView(to date: Date) {
        self.initDate = date.startOfDay.add(component: .day, value: -numOfDays)
        DispatchQueue.main.async { [unowned self] in
            self.layoutSubviews()
            self.forceReload()
        }
    }
    
    /// Get current event with item indexPath
    ///
    /// - Parameter indexPath: The indexPath of an item in collectionView
    open func getCurrentEvent(with indexPath: IndexPath) -> JZBaseEvent? {
        let date = flowLayout.dateForColumnHeader(at: indexPath)
        return isAllDaySupported ? notAllDayEventsBySection[date]?[indexPath.row] : allEventsBySection[date]?[indexPath.row]
    }
    
    open func getDatesInCurrentPage(isScrolling: Bool) -> [Date] {
        var dates = [Date]()
        if !isScrolling {
            for i in numOfDays..<2*numOfDays {
                dates.append(initDate.set(day: initDate.day + i))
            }
            return dates
        }
        // Sometimes end scrolling will cause some 0.xxx offset margin
        let margin: CGFloat = 2
        var startDate = getDateForX(xCollectionView: collectionView.contentOffset.x + margin + flowLayout.rowHeaderWidth)
        let endDate = getDateForX(xCollectionView: collectionView.contentOffset.x + frame.width - margin)
        repeat {
            dates.append(startDate)
            startDate = startDate.add(component: .day, value: 1)
        } while startDate <= endDate
       
        return dates
    }
    
    /**
        Used to Refresh the weekView when viewWillTransition
     
        **Must override viewWillTransition in the ViewController and call this function**
    */
    open func refreshWeekView() {
        updateWeekView(to: self.initDate.add(component: .day, value: numOfDays))
    }
    
    open func updateFirstDayOfWeek(setDate: Date, firstDayOfWeek: DayOfWeek?) {
        guard let firstDayOfWeek = firstDayOfWeek, numOfDays == 7 else { return }
        let setDayOfWeek = setDate.getDayOfWeek()
        var diff = setDayOfWeek.rawValue - firstDayOfWeek.rawValue
        if diff < 0 { diff = 7 - abs(diff) }
        self.initDate = setDate.startOfDay.add(component: .day, value: -numOfDays - diff)
        self.firstDayOfWeek = firstDayOfWeek
    }
    
    /// Get Date for specific section.
    /// The 0 section start from previous page, which means the first date section in current page should be **numOfDays**.
    open func getDateForSection(_ section: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: section, to: initDate)!
    }
    
    /**
     Get date excluding time from points
     NOTICE: No need consider rowHeaderWidth, because that part is not considered in contentOffset
        - Parameters:
            - xCollectionView: x position in collectionView
     */
    open func getDateForX(xCollectionView: CGFloat) -> Date {
        let section = Int((xCollectionView - flowLayout.rowHeaderWidth) / flowLayout.sectionWidth)
        return getDateForSection(section)
    }
    
    /// Get time from point y position
    /// - Parameters:
    ///    - yCollectionView: y position in collectionView
    open func getDateForY(yCollectionView: CGFloat) -> (Int, Int) {
        let adjustedY = yCollectionView - flowLayout.columnHeaderHeight - flowLayout.contentsMargin.top - flowLayout.allDayHeaderHeight
        let hour = Int(adjustedY / flowLayout.hourHeight)
        let minute = Int((adjustedY / flowLayout.hourHeight - CGFloat(hour)) * 60)
        return (hour, minute)
    }
    
    /**
     Get date from current point, can be used for gesture recognizer
        - Parameters:
            - pointCollectionView: current point position in collectionView
     */
    open func getDateForPoint(pointCollectionView: CGPoint) -> Date {
        
        let yearMonthDay = getDateForX(xCollectionView: pointCollectionView.x)
        let hourMinute = getDateForY(yCollectionView: pointCollectionView.y)
        
        return yearMonthDay.set(hour: hourMinute.0, minute: hourMinute.1, second: 0)
    }
    
    /// Get weekview scroll direction (directionalLockEnabled)
    fileprivate func getScrollDirection() -> ScrollDirection {
        var scrollDirection: ScrollDirection
        
        if initialContentOffset.x != collectionView.contentOffset.x &&
            initialContentOffset.y != collectionView.contentOffset.y {
            scrollDirection = .crazy
        } else {
            if initialContentOffset.x > collectionView.contentOffset.x {
                scrollDirection = .left
            } else if initialContentOffset.x < collectionView.contentOffset.x {
                scrollDirection = .right
            } else if initialContentOffset.y > collectionView.contentOffset.y {
                scrollDirection = .up
            } else if initialContentOffset.y < collectionView.contentOffset.y {
                scrollDirection = .down
            } else {
                scrollDirection = .none
            }
        }
        return scrollDirection
    }
    
    /// Get scroll direction axis
    fileprivate var scrollDirectionAxis: ScrollDirection {
        switch getScrollDirection() {
        case .left, .right:
            return .horizontal
        case .up, .down:
            return .vertical
        case .crazy:
            return .crazy
        default:
            return .none
        }
    }
}


extension JZBaseWeekView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // In order to keep efficiency, only 3 pages exist at the same time, previous-current-next
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3 * numOfDays
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let date = flowLayout.dateForColumnHeader(at: IndexPath(item: 0, section: section))
        
        if let events = allEventsBySection[date] {
            return isAllDaySupported ? notAllDayEventsBySection[date]!.count : events.count
        } else {
            return 0
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        preconditionFailure("This method must be overridden")
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view: UICollectionReusableView
        
        switch kind {
            
        case JZSupplementaryViewKinds.columnHeader:
            let columnHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as! JZColumnHeader
            columnHeader.updateView(date: flowLayout.dateForColumnHeader(at: indexPath))
            view = columnHeader
            
        case JZSupplementaryViewKinds.rowHeader:
            let rowHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as! JZRowHeader
            rowHeader.updateView(date: flowLayout.timeForRowHeader(at: indexPath))
            view = rowHeader
            
        case JZSupplementaryViewKinds.cornerHeader:
            let cornerHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as! JZCornerHeader
            view = cornerHeader
            
        case JZSupplementaryViewKinds.allDayHeader:
            let alldayHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as! JZAllDayHeader
            alldayHeader.updateView(views: [])
            view = alldayHeader
            
        case JZSupplementaryViewKinds.currentTimeline:
            if currentTimelineType == .page {
                let currentTimeline = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as! JZCurrentTimelinePage
                view = getPageTypeCurrentTimeline(timeline: currentTimeline, indexPath: indexPath)
            } else {
                let currentTimeline = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as! JZCurrentTimelineSection
                view = getSectionTypeCurrentTimeline(timeline: currentTimeline, indexPath: indexPath)
            }
        default:
            view = UICollectionReusableView()
        }
        return view
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        initialContentOffset = scrollView.contentOffset
    }
    
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollDirectionAxis == .vertical { return }
        targetContentOffset.pointee = scrollView.contentOffset
        pagingEffect(scrollView: scrollView, velocity: velocity)
    }
    
    // end dragging for loading drag to the leftmost and rightmost should load page
    // If put the checking process in scrollViewWillEndDragging, then it will not work well
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let isDraggedToEdge = scrollView.contentOffset.x == 0 || scrollView.contentOffset.x == contentViewWidth * 2
        guard scrollDirectionAxis != .vertical && isDraggedToEdge else { return }
        if !decelerate { isDirectionLocked = false }
        loadPage(scrollView)
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //for directionLock
        isDirectionLocked = false
    }
    
    // This function will be called by setting content offset (pagingEffect function)
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        //for directionLock
        isDirectionLocked = false
        
        if scrollType != .sectionScroll {
            loadPage(scrollView)
        } else {
            // changing initial date(loadPage) for one day scroll after paging effect
            if scrollSections != 0 {
                initDate = initDate.add(component: .day, value: -Int(scrollSections))
                self.forceReload()
            }
            // seems no need to do this
//            else {
//                // have to update all day bar because forceReload not called here
//                updateAllDayBar(isScrolling: false)
//            }
        }
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        var lockedDirection: ScrollDirection!
        
        if !isDirectionLocked {
            let isScrollingHorizontally = abs(scrollView.contentOffset.x - initialContentOffset.x) > abs(scrollView.contentOffset.y - initialContentOffset.y)
            lockedDirection = isScrollingHorizontally ? .vertical : .horizontal
            isDirectionLocked = true
        }
        
        // forbid scrolling two directions together
        if scrollDirectionAxis == .crazy {
            let newOffset = lockedDirection == .vertical ? CGPoint(x: scrollView.contentOffset.x, y: initialContentOffset.y) :
                                                           CGPoint(x: initialContentOffset.x, y: scrollView.contentOffset.y)
            scrollView.contentOffset = newOffset
        }
        
        // All Day Bar update
        guard flowLayout.sectionWidth != nil && scrollDirectionAxis != .vertical else { return }
        updateAllDayBar(isScrolling: true)
    }
    
    /// It is used for scroll paging effect, scrollTypes sectionScroll and pageScroll applied here
    private func pagingEffect(scrollView: UIScrollView, velocity: CGPoint) {
        
        let yCurrentOffset = scrollView.contentOffset.y
        let xCurrentOffset = scrollView.contentOffset.x
        
        let scrollXDistance = initialContentOffset.x - xCurrentOffset
        // scroll one section
        if scrollType == .sectionScroll {
            let sectionWidth = flowLayout.sectionWidth!
            scrollSections = (scrollXDistance/sectionWidth).rounded()
            scrollView.setContentOffset(CGPoint(x:initialContentOffset.x-sectionWidth * scrollSections,y:yCurrentOffset), animated: true)
        } else {
            // Only for pageScroll
            let scrollProportion:CGFloat = 1/5
            let isVelocitySatisfied = abs(velocity.x) > 0.2
            // scroll a whole page
            if scrollXDistance >= 0 {
                if scrollXDistance >= scrollProportion * contentViewWidth || isVelocitySatisfied {
                    scrollView.setContentOffset(CGPoint(x:initialContentOffset.x-contentViewWidth,y:yCurrentOffset), animated: true)
                }else{
                    scrollView.setContentOffset(initialContentOffset, animated: true)
                }
            } else {
                if -scrollXDistance >= scrollProportion * contentViewWidth || isVelocitySatisfied {
                    scrollView.setContentOffset(CGPoint(x:initialContentOffset.x+contentViewWidth,y:yCurrentOffset), animated: true)
                } else {
                    scrollView.setContentOffset(initialContentOffset, animated: true)
                }
            }
        }
    }
    
    /// For loading next page or previous page (Only three pages (3*numOfDays) exist at the same time)
    private func loadPage(_ scrollView: UIScrollView) {
        let maximumOffset = scrollView.contentSize.width - scrollView.frame.width
        let currentOffset = scrollView.contentOffset.x
    
        if maximumOffset <= currentOffset {
            //load next page
            loadNextOrPrevPage(isNext: true)
        }
        if currentOffset <= 0 {
            //load previous page
            loadNextOrPrevPage(isNext: false)
        }
    }
    
    /// Can be overrided to do some operations before reload
    open func loadNextOrPrevPage(isNext: Bool) {
        let addValue = isNext ? numOfDays : -numOfDays
        self.initDate = self.initDate.add(component: .day, value: addValue!)
        self.forceReload()
    }
    
    /// Get the section Type current timeline
    open func getSectionTypeCurrentTimeline(timeline: JZCurrentTimelineSection, indexPath: IndexPath) -> UICollectionReusableView {
        let date = flowLayout.dateForColumnHeader(at: indexPath)
        timeline.isHidden = !date.isToday
        return timeline
    }
    
    /// Get the page Type current timeline
    /// Rules are quite confused for now
    open func getPageTypeCurrentTimeline(timeline: JZCurrentTimelinePage, indexPath: IndexPath) -> UICollectionReusableView {
        let date = flowLayout.dateForColumnHeader(at: indexPath)
        let daysToToday = Date.daysBetween(start: date, end: Date(), ignoreHours: true)
        timeline.isHidden = abs(daysToToday) > numOfDays - 1
        timeline.updateView(needShowBallView: daysToToday == 0)
        return timeline
    }
}

extension JZBaseWeekView: WeekViewFlowLayoutDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, dayForSection section: Int) -> Date {
        return getDateForSection(section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, startTimeForItemAtIndexPath indexPath: IndexPath) -> Date {
        let date = flowLayout.dateForColumnHeader(at: indexPath)
        
        if let events = allEventsBySection[date] {
            let event = isAllDaySupported ? notAllDayEventsBySection[date]![indexPath.item] : events[indexPath.item]
            return event.intraStartDate
        } else {
            fatalError("Cannot get events")
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, endTimeForItemAtIndexPath indexPath: IndexPath) -> Date {
        let date = flowLayout.dateForColumnHeader(at: indexPath)
        
        if let events = allEventsBySection[date] {
            let event = isAllDaySupported ? notAllDayEventsBySection[date]![indexPath.item] : events[indexPath.item]
            return event.intraEndDate
        } else {
            fatalError("Cannot get events")
        }
    }
    
    //TODO: Only used when multiple cell types are used and need different overlap rules => layoutItemsAttributes
    public func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, cellTypeForItemAtIndexPath indexPath: IndexPath) -> String {
        return JZSupplementaryViewKinds.eventCell
    }
}
