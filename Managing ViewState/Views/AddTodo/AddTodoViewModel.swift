import Combine

extension AddTodoView {

    struct ViewState: ObservableViewState {
        var valid: Bool
        var loading: Bool
        var dismiss: Bool

        static var initialViewState: ViewState {
            ViewState(valid: false,
                      loading: false,
                      dismiss: false)
        }
    }

    enum Input {
        case validate(title: String)
        case addTodo(title: String)
    }

    enum Action {
        case setValidity(Bool)
        case setLoading(Bool)
        case dismiss
    }

    class ViewModel: ObservableViewModel<Input, Action, ViewState> {
        private var todoRepository = TodoRepository.shared

        override func processInput(input: Input) -> AnyPublisher<Action, Never> {
            switch input {
            case .validate(let title):
                let valid = !title.trimmingCharacters(in: .whitespaces).isEmpty
                return Just(Action.setValidity(valid))
                    .eraseToAnyPublisher()
            case .addTodo(let title):
                return todoRepository.addTodo(title: title)
                    .map({ _ in
                        Action.dismiss
                    })
                    .replaceError(with: .setLoading(false))
                    .prepend(.setLoading(true))
                    .eraseToAnyPublisher()
            }
        }

        override func processAction(currentState: ViewState, action: Action) -> ViewState {
            switch action {
            case .setLoading(let loading):
                var updated = currentState
                updated.loading = loading
                return updated
            case .setValidity(let valid):
                var updated = currentState
                updated.valid = valid
                return updated
            case .dismiss:
                var updated = currentState
                updated.dismiss = true
                return updated
            }
        }
    }
}
