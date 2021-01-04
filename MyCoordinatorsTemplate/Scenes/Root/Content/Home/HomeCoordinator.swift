//
//  HomeCoordinator.swift
//  MyCoordinatorsTemplate
//
//  Created by Danyl Timofeyev on 21.12.2020.
//  Copyright © 2020 Danyl Timofeyev. All rights reserved.
//

import UIKit

protocol HomeCoordinatorProtocol {
    func pushProfile()
    func presentProfile()
    func displayAuthAsRoot()
}

protocol HomeCoordinatorDelegate: class {
    func didLogOut(_ coordinator: CoordinatorProtocol)
}

final class HomeCoordinator: BaseCoordinator, HomeCoordinatorProtocol {
    
    weak var delegate: HomeCoordinatorDelegate?
    
    private let title: String
    
    init(tabBarController: UITabBarController,
         delegate: HomeCoordinatorDelegate,
         title: String
    ) {
        self.delegate = delegate
        self.title = title
        super.init()
        self.tabBarController = tabBarController
    }
    
    override func start() {
        let homeViewModel = HomeViewModel(coordinator: self)
        let homeVewController = HomeViewController.instantiate(storyboard: .home, instantiation: .initial) {
            return  HomeViewController(title: "Home", viewModel: homeViewModel, coder: $0)!
        }
        let navigationController = UINavigationController.makeStyled(style: .blue, root: homeVewController)
        
        guard
            let tabBarController = tabBarController
            else { fatalError("internal inconsistency") }
        
        tabBarController.addControllerForTab(navigationController)
        self.navigationController = navigationController
    }
    
    // MARK: - Display profile scene
    func pushProfile() {
        guard let navigation = navigationController else { return }
        let child = ProfileCoordinator(parentCoordinator: self,
                                       title: "Profile",
                                       presentationType: .push(navigation))
        addChild(child)
        child.start()
    }
    
    func presentProfile() {
        let child = ProfileCoordinator(parentCoordinator: self,
                                       title: "Profile",
                                       presentationType: .modal)
        addChild(child)
        child.start()
    }
    
    func displayAuthAsRoot() {
        delegate?.didLogOut(self)
    }
    
}
