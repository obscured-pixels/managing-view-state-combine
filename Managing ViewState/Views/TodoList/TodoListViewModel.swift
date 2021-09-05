import Combine
import Foundation

extension TodoListView {
    enum ViewState: ObservableViewState {
        case loading
        case content(todos: [Todo])
        case error

        static var initialViewState: ViewState = .loading
    }

    enum Input {
        case todosUpdated([Todo])
        case removeTodos(IndexSet)
    }

    enum Action {
        case setState(ViewState)
        case noOp
    }

    class ViewModel: ObservableViewModel<Input, Action, ViewState> {
        private let todoRepository = TodoRepository.shared

        override var internalInputPublisher: AnyPublisher<Input, Never> {
            todoRepository.todosPublisher
                .map({ todos in
                    Input.todosUpdated(todos)
                })
                .eraseToAnyPublisher()
        }

        override func processInput(input: Input) -> AnyPublisher<Action, Never> {
            switch input {
            case .todosUpdated(let todos):
                return Just(Action.setState(.content(todos: todos)))
                    .eraseToAnyPublisher()
            case .removeTodos(let indexSet):
                return todoRepository.deleteTodos(indexSet: indexSet)
                    .map({ _ in
                        /**
                         Since our internalInputPublisher will channel updates from our todo repository as todos are added or removed, there is no need to perform a mutating action on our view state for this specific update. The concept of a noOp action servers well for these purposes, where the reducer wil simply return the current state
                         */
                        Action.noOp
                    })
                    .replaceError(with: .setState(.error))
                    .eraseToAnyPublisher()
            }
        }

        override func processAction(currentState: ViewState, action: Action) -> ViewState {
            switch action {
            case .setState(let state):
                return state
            case .noOp:
                return currentState
            }
        }
    }
}
