//
//  CounterViewController.swift
//  Counter
//
//  Created by Suyeol Jeon on 02/05/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

// Conform to the protocol `View` then the property `self.reactor` will be available.
final class CounterViewController: UIViewController, StoryboardView {
  @IBOutlet var decreaseButton: UIButton!
  @IBOutlet var increaseButton: UIButton!
  @IBOutlet var valueLabel: UILabel!
  @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
  var disposeBag = DisposeBag()

  // Called when the new value is assigned to `self.reactor`
  // MARK: view는 UI와 UI의 action을 reactor에 넘기고 reactor의 state를 구독하고 있는 형태
  func bind(reactor: CounterViewReactor) {
      bindAction(reactor)
      bindState(reactor)
  }
    
    private func bindAction(_ reactor: CounterViewReactor ) {
        // MARK: Action
        increaseButton.rx.tap               // Tap event
          .map { Reactor.Action.increase }  // Convert to Action.increase
          .bind(to: reactor.action)         // Bind to reactor.action
          .disposed(by: disposeBag)

        decreaseButton.rx.tap
          .map { Reactor.Action.decrease }
          .bind(to: reactor.action)
          .disposed(by: disposeBag)

    }
    
    private func bindState(_ reactor: CounterViewReactor ) {
        // MARK: State
        reactor.state.map { $0.value }   // 10
          .distinctUntilChanged()
          .map { "\($0)" }               // "10"
          .bind(to: valueLabel.rx.text)  // Bind to valueLabel
          .disposed(by: disposeBag)

        reactor.state.map { $0.isLoading }
          .distinctUntilChanged()
          .bind(to: activityIndicatorView.rx.isAnimating)
          .disposed(by: disposeBag)

        reactor.pulse(\.$alertMessage)
          .compactMap { $0 }
          .subscribe(onNext: { [weak self] message in
            let alertController = UIAlertController(
              title: nil,
              message: message,
              preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(
              title: "OK",
              style: .default,
              handler: nil
            ))
            self?.present(alertController, animated: true)
          })
          .disposed(by: disposeBag)
    }
}
