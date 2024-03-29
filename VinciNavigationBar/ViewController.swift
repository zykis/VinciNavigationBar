//
//  ViewController.swift
//  NavigationBarItem
//
//  Created by Артём Зайцев on 16.10.2019.
//  Copyright © 2019 Артём Зайцев. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: VinciNavigationBar?
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        initWithCustomTitleView()
//        initWithLargeTitleAndSearchBar()
    }
    
    private func initWithCustomTitleView() {
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        
        let btn1 = UIButton(type: .close)
        btn1.sizeToFit()
        let btn2 = UIButton(type: .contactAdd)
        btn2.sizeToFit()
        let btn3 = UIButton()
        btn3.setTitle("Done", for: .normal)
        btn3.setTitleColor(.black, for: .normal)
        let btn4 = UIButton(type: .contactAdd)
        btn4.sizeToFit()
        let btn5 = UIButton(type: .contactAdd)
        btn5.sizeToFit()
        
        navigationBar?.displayMode = .smallTitleOnly
        navigationBar?.leftItems = [btn1, btn4, btn5]
        navigationBar?.rightItems = [btn3, btn2]

        let customTitleView = UIView()
        customTitleView.backgroundColor = .red
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "wtf?"
        label.font = .systemFont(ofSize: 17.0)
        label.sizeToFit()
        customTitleView.addSubview(label)
        label.leadingAnchor.constraint(equalTo: customTitleView.leadingAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: customTitleView.centerYAnchor).isActive = true
        
        navigationBar?.titleView = customTitleView
    }
    
    private func initWithLargeTitleAndSearchBar() {
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        
        let btn1 = UIButton(type: .close)
        btn1.sizeToFit()
        let btn2 = UIButton(type: .contactAdd)
        btn2.sizeToFit()
        let btn3 = UIButton()
        btn3.setTitle("Done", for: .normal)
        btn3.setTitleColor(.black, for: .normal)
        let btn4 = UIButton(type: .contactAdd)
        btn4.sizeToFit()
        let btn5 = UIButton(type: .contactAdd)
        btn5.sizeToFit()
        
        navigationBar?.displayMode = .largeTitleWithSearchBar
        navigationBar?.leftItems = [btn1, btn4, btn5]
        navigationBar?.rightItems = [btn3, btn2]
        
        let chatsButton = UIButton()
        chatsButton.setTitle("Chats", for: .normal)
        chatsButton.titleLabel?.font = .systemFont(ofSize: 24.0, weight: .semibold)
        
        let groupsButton = UIButton()
        groupsButton.setTitle("Groups", for: .normal)
        groupsButton.titleLabel?.font = .systemFont(ofSize: 24.0, weight: .semibold)
        
        let largeButton = UIButton()
        largeButton.setTitle("One more large title", for: .normal)
        
        navigationBar?.tabButtons = [chatsButton, groupsButton]
        navigationBar?.scrollView = tableView
        navigationBar?.placeholder = "search for anything"
        navigationBar?.searchBarDelegate = self
    }
}


extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.contentView.backgroundColor = .lightGray
        return cell
    }
}


extension ViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset: CGFloat = scrollView.contentOffset.y
        navigationBar?.offset = offset
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offset: CGFloat = scrollView.contentOffset.y
        let velocity: CGPoint = tableView.panGestureRecognizer.velocity(in: self.view)
        navigationBar?.didEndDragging(offset: offset, velocity: velocity.y)
    }
}


extension ViewController: UISearchBarDelegate {
    //
}
