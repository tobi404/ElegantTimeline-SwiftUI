// Kevin Li - 1:18 PM - 7/3/20

import SwiftUI

fileprivate class HostingCell: UITableViewCell {

    static let identifier = "HostingCell"

    private var hostingController: UIHostingController<AnyView>?

    func configure(with view: AnyView) {
        if let hostingController = hostingController {
            hostingController.rootView = view
        } else {
            let controller = UIHostingController(rootView: view)
            hostingController = controller

            let rootView = controller.view!
            rootView.translatesAutoresizingMaskIntoConstraints = false

            contentView.addSubview(rootView)

            NSLayoutConstraint.activate([
                rootView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                rootView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                rootView.topAnchor.constraint(equalTo: contentView.topAnchor),
                rootView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }

        layoutIfNeeded()
    }

}

struct VisitsPreviewList: UIViewRepresentable {

    @Environment(\.autoTimer) private var autoTimer: AutoTimer

    typealias UIViewType = UITableView

    let visitsProvider: VisitsProvider
    let sideBarTracker: VisitsSideBarTracker

    func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView.visitsPreview(source: context.coordinator)
        sideBarTracker.attach(to: tableView)
        return tableView
    }

    func updateUIView(_ tableView: UITableView, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITableViewDataSource {

        private let parent: VisitsPreviewList

        private var visitsTracker: VisitsSideBarTracker {
            parent.sideBarTracker
        }

        private var visitsProvider: VisitsProvider {
            parent.visitsProvider
        }

        init(_ parent: VisitsPreviewList) {
            self.parent = parent
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // TODO: Ok so I've figured out that the tableview sets the contentinset based on the number of rows
            visitsTracker.descendingDayComponents.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: HostingCell.identifier) as! HostingCell

            let index = indexPath.row

            let rootView = dayVisitsView(
                dayComponent: visitsProvider.descendingDayComponents[index],
                isFilled: (index % 2) == 0)
                .environment(\.autoTimer, parent.autoTimer)
                .id(index)
                .erased

            cell.configure(with: rootView)

            return cell
        }

        private func dayVisitsView(dayComponent: DateComponents, isFilled: Bool) -> DayVisitsView {
            DayVisitsView(date: dayComponent.date,
                          visits: visitsProvider.visitsForDayComponents[dayComponent] ?? [],
                          isFilled: isFilled)
        }

    }

}


private extension UITableView {

    static func visitsPreview(source: UITableViewDataSource) -> UITableView {
        let tableView = UITableView()

        // TODO: uncomment this out in the future
//        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.scrollsToTop = false

        tableView.rowHeight = VisitPreviewConstants.blockHeight
        tableView.estimatedRowHeight = VisitPreviewConstants.blockHeight

        tableView.dataSource = source

        tableView.register(HostingCell.self, forCellReuseIdentifier: HostingCell.identifier)

        return tableView
    }

}