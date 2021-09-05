import Combine
import Foundation

/**
 The ObservableViewState protocol insures that all view state entities provide an initial value and are equatable to prevent duplicte updates.
 */
protocol ObservableViewState: Equatable {
    static var initialViewState: Self { get }
}

/**
 The ObservableViewModel utitlizes generics to avoid duplicate code by attaching reusable reacrtive funtionality to our view models.
 When inheretting from this class, the view model must specify the following types:
 - an Input associative enum  to resemble Inputs to process into Actions. (I)
 - an Action associatie enum  to resemble Actions to apply to our ViewState. (A)
 - a ViewState entity that represents a view model's state (S). This can be a struct or associateive enum
 */
class ObservableViewModel<I, A, S: ObservableViewState>: ObservableObject {
    @Published
    var viewState: S = S.initialViewState
    private let inputSubject = PassthroughSubject<I, Never>()
    private var subscribed = false

    /**
     Given that our SwiftUI views can be instantiated well before their views are dsplayed on a device, we avoid initializing any observations until a view explicitly calls the view model's subscribe method.
     A good point in the view lifecycle to call this method is during onAppear. Note we insure that the view model is only subscirbed once during it's lifecycle by tracking the local subscribed Bool property.
     While onAppear should theoritically only occur once, there has been known bugs or scenarios where that isn't the case.
     */
    func subscribe() {
        if subscribed {
            return
        }
        subscribed = true
        Publishers.Merge(internalInputPublisher, inputSubject)
            .handleOutput({ [weak self] input in
                guard let self = self else {
                    fatalError()
                }
                self.onInput(input: input)
            })
            .flatMap { [weak self] input -> AnyPublisher<A, Never> in
                guard let self = self else {
                    fatalError()
                }
                return self.processInput(input: input)
            }
            .handleOutput({ [weak self] action in
                guard let self = self else {
                    fatalError()
                }
                self.onAction(action: action)
            })
            .scan(viewState, { [weak self] currentState, action in
                guard let self = self else {
                    return currentState
                }
                return self.processAction(currentState: currentState, action: action)
            })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: &$viewState)
    }

    /**
     The internalInputPublisher provides a means of channeling Inputs to the view model internally that doesn't require user interaction. Common examples include listening to external updates from a repository or reacting to changes that might occur from a Redux store.
     */
    var internalInputPublisher: AnyPublisher<I, Never> {
        Empty()
            .setFailureType(to: Never.self)
            .eraseToAnyPublisher()
    }

    /**
     All classes that inherit the ObservableViewModel must override this method to provide the logic for processing Inputs into Actions.
     */
    func processInput(input: I) -> AnyPublisher<A, Never> {
        fatalError()
    }

    /**
     All classes that inherit the ObservableViewModel must override this method to provide the logic for processing Actions into an updated ViewState
     */
    func processAction(currentState: S, action: A) -> S {
        fatalError()
    }

    /**
     One of the benifits of using a reactive view model is the ability to easily attach side effects to specific inputs. For example, we might want to keep track of certian inputs for analytical purposes. View models can override this method to log specific inputs as they occur
     */
    func onInput(input: I) {}

    /**
     One of the benifits of using a reacive view model is the ability to easily attach side effects to specific Actions. For example, we might want to update a global store when specific actions occur or trigger a programatic navigation
     */
    func onAction(action: A) {}

    func send(_ input: I) {
        inputSubject.send(input)
    }
}
