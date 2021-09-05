import Foundation
import Combine

struct Todo: Identifiable, Equatable {
    let id: String
    let title: String
    let completed: Bool
}

class TodoRepository {

    static let shared = TodoRepository()

    @Published
    private var todos: [Todo] = []

    var todosPublisher: AnyPublisher<[Todo], Never> {
        $todos.eraseToAnyPublisher()
    }
    func addTodo(title: String) -> AnyPublisher<Void, Error> {
        return Just(())
            .setFailureType(to: Error.self)
            .handleOutput { [unowned self] _ in
                todos.append(Todo(id: UUID().uuidString, title: title, completed: false))
            }
            .eraseToAnyPublisher()
    }

    func deleteTodos(indexSet: IndexSet) -> AnyPublisher<Void, Error> {
        return Just(())
            .setFailureType(to: Error.self)
            .handleOutput { [unowned self] _ in
                indexSet.forEach { index in
                    todos.remove(at: index)
                }
            }
            .eraseToAnyPublisher()
    }
}
