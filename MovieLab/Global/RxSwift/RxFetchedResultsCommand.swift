//
//  RxFetchedResultsCommand.swift
//  MovieLab
//
//  Created by aarthur on 1/15/21.
//  Copyright © 2021 Gigabit LLC. All rights reserved.
//

import CoreData
import Foundation
import os.log
import RxCocoa
import RxSwift

// https://medium.com/better-programming/rxswift-observable-and-core-data-55ab87fc02ea
class RxFetchedResultsCommand<T>: NSObject, ObservableType, NSFetchedResultsControllerDelegate where T: NSManagedObject {
    var fetchedResultsController: NSFetchedResultsController<T>?
    private let context: NSManagedObjectContext
    private var fetchRequest: NSFetchRequest<T>
    private let results = BehaviorSubject<[T]>(value: [])
    private var subscriptions = 0
    private var shouldObserveChanges: Bool!

    typealias Element = [T]

    init(fetchRequest: NSFetchRequest<T>, context: NSManagedObjectContext, shouldObserveChanges: Bool) {
        self.fetchRequest = fetchRequest
        self.context = context
        self.shouldObserveChanges = shouldObserveChanges
        super.init()
    }

    func refreshResults(query: String = "", shouldRefresh: Bool = true) {
        if shouldRefresh {
            _ = CoreDataUtility.updateRequest(fetchRequest, query: query)
        }
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        if shouldObserveChanges {
            controller.delegate = self
        }
        fetchedResultsController = controller as NSFetchedResultsController<T>
        do {
            try fetchedResultsController?.performFetch()
            let result = fetchedResultsController?.fetchedObjects ?? []
            results.onNext(result)
        } catch {
            os_log("Could not fetch objects %@", error.localizedDescription)
        }
    }
    
    // MARK: ObservableType implementation
    func subscribe<Observer>(_ observer: Observer) -> Disposable where Observer: ObserverType, RxFetchedResultsCommand.Element == Observer.Element {
        return FetcherDisposable(fetcher: self, observer: observer)
    }

    // MARK: NSFetchedResultsControllerDelegate implementation
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let result = controller.fetchedObjects as? [T] ?? []
        results.onNext(result)
    }

    // MARK: Private Stuff
    private func dropSubscription() {
        var stop = false

        objc_sync_enter(self)
        subscriptions -= 1
        stop = subscriptions == 0
        objc_sync_exit(self)

        if stop {
            fetchedResultsController?.delegate = nil
            fetchedResultsController = nil
        }
    }

    // MARK: Disposable
    private class FetcherDisposable: Disposable {
        var fetcher: RxFetchedResultsCommand?
        var disposable: Disposable?

        init<Observer>(fetcher: RxFetchedResultsCommand,
                       observer: Observer) where Observer: ObserverType, RxFetchedResultsCommand.Element == Observer.Element {
            self.fetcher = fetcher

            self.disposable = fetcher.results.subscribe(onNext: {
                observer.onNext($0)
            }, onError: {
                observer.onError($0)
            }, onCompleted: {
                observer.onCompleted()
            }, onDisposed: {})
        }

        func dispose() {
            disposable?.dispose()
            disposable = nil

            fetcher?.dropSubscription()
            fetcher = nil
        }
    }
}
