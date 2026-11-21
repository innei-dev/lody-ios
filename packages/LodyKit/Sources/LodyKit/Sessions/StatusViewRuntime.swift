import Foundation
import LodyCore

/// The runtime's Status view methods. Swift builds the note's JSON (`StatusViewCommand.json`) and
/// decodes it into the generated params, so the list depends only on the method names
/// `statusViewCommand` and `snoozePresets`, not on how the generator names the command union.
@MainActor
enum StatusViewRuntime {
  static func command(_ workspaceId: String, _ command: StatusViewCommand) async throws {
    let runtime = try scoped(workspaceId)
    let params = try RuntimeJSON.decode(
      RuntimeContract.Calls.StatusViewCommand.Params.self,
      from: ["workspaceId": workspaceId, "command": command.json] as [String: Any]
    )
    _ = try await runtime.perform(RuntimeContract.Calls.StatusViewCommand.self, params)
  }

  /// The four Later presets with their resolved instants, computed by the runtime on its clock.
  static func presets(_ workspaceId: String) async throws -> [StatusViewSnoozePreset] {
    let runtime = try scoped(workspaceId)
    let params = try RuntimeJSON.decode(RuntimeContract.Calls.SnoozePresets.Params.self, from: ["workspaceId": workspaceId] as [String: Any])
    let result = try await runtime.perform(RuntimeContract.Calls.SnoozePresets.self, params)
    guard let presets = StatusViewSnoozePreset.decodeList(try JSONEncoder().encode(result)) else {
      throw DataRuntime.failure("command_failed", "invalid_result: snoozePresets")
    }
    return presets
  }

  private static func scoped(_ workspaceId: String) throws -> DataRuntime {
    guard let runtime = DataRuntime.current, runtime.workspace == workspaceId else {
      throw DataRuntime.failure("not_ready", String(localized: "native.runtime.sessionNotSynced", bundle: .lody))
    }
    return runtime
  }
}
