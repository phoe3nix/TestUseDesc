//
//  ViewController.swift
//  TestUseDesc
//
//  Created by Usachev Vladislav on 28.01.2022.
//

import UIKit
import UseDesk

class Cell: UITableViewCell {
	@IBOutlet var messageLabel: UILabel!
	@IBOutlet var idLabel: UILabel!
	@IBOutlet var dateLabel: UILabel!
	let formatter = DateFormatter()

	func fill(_ message: UDMessage) {
		messageLabel.text = message.text
		idLabel.text = "\(message.id)"
		formatter.dateStyle = .short
		formatter.timeStyle = .short
		dateLabel.text = formatter.string(from: message.date ?? Date.distantPast)
	}
}
class ViewController: UIViewController, UITableViewDataSource {

	let useDesk = UseDeskSDK()
	var historyMessages: [UDMessage] = []
	var newMessages: [UDMessage] = []
	var messages: [UDMessage] {
		newMessages + historyMessages
	}

	@IBOutlet weak var messageInput: UITextField!
	@IBOutlet weak var tableView: UITableView!
	var refreshControl = UIRefreshControl()

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.dataSource = self
		refreshControl.addTarget(self, action: #selector(updateMessages), for: .valueChanged)
		tableView.addSubview(self.refreshControl)

		useDesk.start(
			withCompanyID: "1",
			chanelId: "30",// "bb0d0334473bebe76647e4e9ba9b707e6ab4068b",
			urlAPI: "secure.usedesk.ru/uapi",
			api_token: "ffa734efda28af13dc0811a3aa4140693a032819",
			url: "https://pubsub.m2.ru/") { isSuccess, status, string in
				print("$$$ connection \(isSuccess) \(status) \(string)")
			} errorStatus: { error, string in
				print("$$$ error \(error) \(string ?? "")")
			}

		useDesk.newMessageBlock = { [weak self] message in
			guard let message = message else {
				print("no message!")
				return
			}
			self?.newMessages.insert(message, at: 0)
		}
	}

	@IBAction func sendAction(_ sender: Any) {
		useDesk.sendMessage(messageInput.text ?? "-", messageId: "12345")
		messageInput.text = nil
	}

	// UITableViewDataSource
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		print("useDesk.historyMess.count = \(useDesk.historyMess.count)")
		print("messages.count = \(messages.count)")
		return messages.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath) as! Cell
		cell.fill(messages[indexPath.item])
		return cell
	}

	@objc
	private func updateMessages() {
		historyMessages = useDesk.historyMess.reversed()
		tableView.reloadData()
		refreshControl.endRefreshing()
	}
}
