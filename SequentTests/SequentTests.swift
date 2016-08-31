import XCTest
@testable import Sequent

class Command {
  let uuid: NSUUID
  init(uuid: NSUUID) {
    self.uuid = uuid
  }
}

class CommandBus {
  let handlers: [CommandHandler]

  init(handlers: [CommandHandler]) {
    self.handlers = handlers
  }

  func dispatch(command: Command) {
    handlers.map {
      $0.handle(command)
    }.flatMap {
      $0
    }.flatMap {
      self.emit($0)
    }
  }

  func emit(events: [Event]) {

  }
}

class CommandHandler {
  func handle(command: Command) -> [Event]? {
    return .None
  }
}

class CommandBusTests: XCTestCase {

  class MockCommandHandler: CommandHandler {
    override func handle(command: Command) -> [Event]? {
      return [Event()]
    }
  }

  func testCommandBus() {
    let bus = CommandBus(handlers: [MockCommandHandler()])
    let command = Command(uuid: NSUUID(UUIDString: "01000000-0000-0000-0000-000000000000")!)
    bus.dispatch(command)
  }
}

class CreateTodo: Command {
  let title: String
  let description: String

  init(uuid: NSUUID, title: String, description: String) {
    self.title = title
    self.description = description
    super.init(uuid: uuid)
  }
}

class Aggregate {
}

class Event {
}

class EventStore {
}

class SequentTests: XCTestCase {

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testCommandUUID() {
    let command = Command(uuid: NSUUID(UUIDString: "01000000-0000-0000-0000-000000000000")!)
    XCTAssertEqual("01000000-0000-0000-0000-000000000000", command.uuid.UUIDString)
  }

}
