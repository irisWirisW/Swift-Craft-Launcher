import Foundation

struct CurseForgeSearchResult: Codable {
    let data: [CurseForgeMod]
}

struct CurseForgeMod: Codable {
    let id: Int
    let name: String
    let summary: String
}

struct CurseForgeModDetail: Codable {
    let id: Int
    let name: String
    let summary: String
    let classId: Int
    let categories: [CurseForgeCategory]

    /// 获取对应的内容类型枚举
    var contentType: CurseForgeClassId? {
        return CurseForgeClassId(rawValue: classId)
    }

    /// 获取目录名称
    var directoryName: String {
        return contentType?.directoryName ?? "mods"
    }
}

/// CurseForge 内容类型枚举
enum CurseForgeClassId: Int, CaseIterable {
    case mods = 6           // 模组
    case resourcePacks = 12 // 资源包
    case shaders = 6552     // 光影
    case datapacks = 6945   // 数据包

    var directoryName: String {
        switch self {
        case .mods:
            return "mods"
        case .resourcePacks:
            return "resourcepacks"
        case .shaders:
            return "shaderpacks"
        case .datapacks:
            return "datapacks"
        }
    }
}

struct CurseForgeCategory: Codable {
    let id: Int
    let name: String
    let slug: String
}

struct CurseForgeModDetailResponse: Codable {
    let data: CurseForgeModDetail
}

struct CurseForgeFilesResult: Codable {
    let data: [CurseForgeModFileDetail]
}

struct CurseForgeModFileDetail: Codable {
    let id: Int
    let displayName: String
    let fileName: String
    let downloadUrl: String?
    let fileDate: String
    let releaseType: Int
    let gameVersions: [String]
    let dependencies: [CurseForgeDependency]?
    let changelog: String?
    let fileLength: Int?
    let hash: CurseForgeHash?
    let modules: [CurseForgeModule]?
    let projectId: Int?
    let projectName: String?
    let authors: [CurseForgeAuthor]?
}

struct CurseForgeDependency: Codable {
    let modId: Int
    let relationType: Int
}

struct CurseForgeHash: Codable {
    let value: String
    let algo: Int
}

struct CurseForgeModule: Codable {
    let name: String
    let fingerprint: Int
}

struct CurseForgeAuthor: Codable {
    let name: String
    let url: String?
}

// MARK: - CurseForge Manifest Models

/// CurseForge 整合包的 manifest.json 格式
struct CurseForgeManifest: Codable {
    let minecraft: CurseForgeMinecraft
    let manifestType: String
    let manifestVersion: Int
    let name: String
    let version: String?  // 修改为可选类型，因为某些整合包可能缺少此字段
    let author: String?
    let files: [CurseForgeManifestFile]
    let overrides: String?

    enum CodingKeys: String, CodingKey {
        case minecraft
        case manifestType
        case manifestVersion
        case name
        case version
        case author
        case files
        case overrides
    }
}

/// CurseForge manifest 中的 Minecraft 配置
struct CurseForgeMinecraft: Codable {
    let version: String
    let modLoaders: [CurseForgeModLoader]
}

/// CurseForge manifest 中的模组加载器配置
struct CurseForgeModLoader: Codable {
    let id: String
    let primary: Bool
}

/// CurseForge manifest 中的文件信息
struct CurseForgeManifestFile: Codable {
    let projectID: Int
    let fileID: Int
    let required: Bool

    enum CodingKeys: String, CodingKey {
        case projectID
        case fileID
        case required
    }
}

/// CurseForge 整合包索引信息（转换后的格式）
struct CurseForgeIndexInfo {
    let gameVersion: String
    let loaderType: String
    let loaderVersion: String
    let modPackName: String
    let modPackVersion: String
    let author: String?
    let files: [CurseForgeManifestFile]
    let overridesPath: String?
}
