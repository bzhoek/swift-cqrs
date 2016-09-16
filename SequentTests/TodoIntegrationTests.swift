import XCTest

class CreateTodo: Command {
  let title: String
  let body: String
  
  init(uuid: String, title: String, body: String) {
    self.title = title
    self.body = body
    super.init(uuid: uuid)
  }
}

class TodoCreated: Event {
  let title: String
  let body: String
  
  init(uuid: String, title: String, body: String) {
    self.title = title
    self.body = body
    super.init(uuid: uuid)
  }

  override var description: String {
    return "\(super.description) title:\(title) body:\(body)"
  }
}

class CompleteTodo: Command {}

class TodoCompleted: Event {}

class TodoAggregate: Aggregate {

  var uuid = ""
  var title = ""
  var body = ""

  func handle(event: TodoCreated) {
    self.uuid = event.uuid
    self.title = event.title
    self.body = event.body
  }
  
  func handle(command: CreateTodo) {
    emit(TodoCreated(uuid: command.uuid, title: command.title, body: command.body))
  }
  
  func handle(command: CompleteTodo) {
    emit(TodoCompleted(uuid: command.uuid))
  }

}

class TodoHandler: CommandHandler {

  override func handle(command: Command) -> [Event]? {
    let aggregate = TodoAggregate(bus: bus)
    store.lookup(command.uuid)?.forEach({ self.handle(aggregate, event: $0) })
    if let command = command as? CreateTodo { aggregate.handle(command) }
    if let command = command as? CompleteTodo { aggregate.handle(command) }
    return []
  }
  
  func handle(aggregate: TodoAggregate, event: Event) {
    if let event = event as? TodoCreated { aggregate.handle(event) }
  }
  
}

class GivenWhenThenTests: XCTestCase {

  var commandBus: CommandBus!
  var eventBus: EventBus!
  var eventStore: EventStore!
  
  override func setUp() {
    super.setUp()
    eventBus = EventBus()
    eventStore = EventStore()
    commandBus = CommandBus(handlers: [TodoHandler(bus:eventBus, store: eventStore)])
  }
  
  func given(events: [Event]) {
    eventStore.add(events)
  }
  
  func when(command: Command) {
    commandBus.dispatch(command)
  }
  
  func then(events: [Event]) {
    XCTAssertEqual(events, eventBus.events)
  }
  
}

class TodoIntegrationTests: GivenWhenThenTests {
  
  func testCommandBus() {
    let command = CreateTodo(
      uuid: "1",
      title: "Title",
      body: "Body"
    )

    when(command)
    then([TodoCreated(uuid: "1", title: "Title", body: "Body")])
  }
  
  func testTodoCompletion() {
    given([TodoCreated(uuid: "1", title: "Title", body: "Body")])
    when(CompleteTodo(uuid: "1"))
    then([TodoCompleted(uuid: "1")])
  }
  
}