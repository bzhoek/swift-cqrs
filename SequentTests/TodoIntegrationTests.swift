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

class TodoHandler: CommandHandler {
  
  override func handle(command: Command) -> [Event]? {
    if let command = command as? CreateTodo { handle(command) }
    if let command = command as? CompleteTodo { handle(command) }
    return []
  }
  
  func handle(command: CreateTodo) {
    emit(TodoCreated(uuid: command.uuid, title: command.title, body: command.body))
  }
  
  func handle(command: CompleteTodo) {
    
  }
}

class TodoIntegrationTests: XCTestCase {
  
  var eventBus: EventBus!
  
  override func setUp() {
    super.setUp()
    eventBus = EventBus()
  }

  func testCommandBus() {
    let bus = CommandBus(handlers: [TodoHandler(bus:eventBus)])
    let command = CreateTodo(
      uuid: "1",
      title: "Title",
      body: "Body"
    )

    bus.dispatch(command)

    XCTAssertEvents([TodoCreated(uuid: "1", title: "Title", body: "Body")])
  }
  
  func XCTAssertEvents(events: [Event]) {
    XCTAssertEqual(events, eventBus.events)
  }
  
}