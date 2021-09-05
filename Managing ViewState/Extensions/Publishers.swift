import Combine

/**
 Convenient extensions for  handling events in Combine.
 For more info about handling events and side effects check out my article "Side Effects with Combine" https://obscuredpixels.com/side-effects-with-combine
 */
extension Publisher {
    func handleOutput(_ receiveOutput: @escaping ((Self.Output) -> Void)) -> Publishers.HandleEvents<Self> {
        handleEvents(receiveOutput: receiveOutput)
    }

    func handleError(_ receiveError: @escaping ((Self.Failure) -> Void)) -> Publishers.HandleEvents<Self> {
        handleEvents(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                receiveError(error)
            case .finished:
                ()
            }
        })
    }
}
