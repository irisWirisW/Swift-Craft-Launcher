//
//  GameActionManager.swift
//  SwiftCraftLauncher
//
//  Created by su on 2025/1/27.
//

import SwiftUI
import AppKit

/// 游戏操作管理器
/// 提供游戏相关的通用操作，如显示在访达、删除游戏等
@MainActor
class GameActionManager: ObservableObject {

    static let shared = GameActionManager()

    private init() {}

    // MARK: - Public Methods

    /// 在访达中显示游戏目录
    /// - Parameter game: 游戏版本信息
    func showInFinder(game: GameVersionInfo) {
        let gameDirectory = AppPaths.profileDirectory(gameName: game.gameName)

        // 检查目录是否存在
        guard FileManager.default.fileExists(atPath: gameDirectory.path) else {
            Logger.shared.warning("游戏目录不存在: \(gameDirectory.path)")
            return
        }

        // 在访达中显示目录
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: gameDirectory.path)
        Logger.shared.info("在访达中显示游戏目录: \(game.gameName)")
    }

    /// 删除游戏及其文件夹
    /// - Parameters:
    ///   - game: 要删除的游戏版本信息
    ///   - gameRepository: 游戏仓库
    ///   - selectedItem: 当前选中的侧边栏项目（用于删除后切换）
    func deleteGame(
        game: GameVersionInfo,
        gameRepository: GameRepository,
        selectedItem: Binding<SidebarItem>? = nil
    ) {
        Task {
            do {
                // 先切换到其他游戏或资源页面，避免删除后页面重新加载
                if let selectedItem = selectedItem {
                    await MainActor.run {
                        if let firstGame = gameRepository.games.first(where: {
                            $0.id != game.id
                        }) {
                            selectedItem.wrappedValue = .game(firstGame.id)
                        } else {
                            selectedItem.wrappedValue = .resource(.mod)
                        }
                    }
                }

                // 先删除游戏文件夹
                let profileDir = AppPaths.profileDirectory(gameName: game.gameName)
                try FileManager.default.removeItem(at: profileDir)

                // 然后删除游戏记录
                try await gameRepository.deleteGame(id: game.id)

                Logger.shared.info("成功删除游戏: \(game.gameName)")
            } catch {
                let globalError = GlobalError.fileSystem(
                    chineseMessage: "删除游戏失败: \(error.localizedDescription)",
                    i18nKey: "error.filesystem.game_deletion_failed",
                    level: .notification
                )
                Logger.shared.error("删除游戏失败: \(globalError.chineseMessage)")
                GlobalErrorHandler.shared.handle(globalError)
            }
        }
    }
}
