#!/usr/bin/env python3
"""依存関係のルール(設計書 第3〜4章)を確かめる。CIで動かし、違反があれば終了コード1で終わる。

- NaikenKit のターゲット間の依存は外側から内側へだけ向く
- 外部パッケージは SwiftLint のビルドプラグインだけ
- ウィジェットは SwiftData のストアを開かないので、Data・Platform・Features に依存しない
"""
import json
import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
PACKAGE_DIR = ROOT / "NaikenKit"
PROJECT_FILE = ROOT / "NaikenNote.xcodeproj" / "project.pbxproj"

# ターゲットごとに依存してよいターゲット
ALLOWED_TARGET_DEPENDENCIES = {
    "Domain": set(),
    "Data": {"Domain"},
    "Platform": {"Domain"},
    "DesignSystem": set(),
    "Features": {"Domain", "DesignSystem"},
    "DomainTests": {"Domain"},
    "DataTests": {"Data", "Domain"},
    "PlatformTests": {"Platform", "Domain"},
    "FeaturesTests": {"Features", "Domain"},
}
# 使ってよい外部パッケージ(SwiftPM の identity)
ALLOWED_PACKAGES = {"swiftlintplugins"}
# Xcode ターゲットごとに使ってよい NaikenKit のプロダクト
ALLOWED_PRODUCTS = {
    "NaikenNote": {"Domain", "Data", "Platform", "DesignSystem", "Features"},
    "NaikenWidgetExtension": {"Domain", "DesignSystem"},
}


def dependency_names(target):
    names = set()
    for dependency in target.get("dependencies", []):
        for kind in ("byName", "target", "product"):
            if kind in dependency:
                names.add(dependency[kind][0])
    return names


def package_identity(dependency):
    for kind in ("sourceControl", "fileSystem", "registry"):
        if kind in dependency:
            return dependency[kind][0]["identity"].lower()
    return json.dumps(dependency)


def check_package(errors):
    output = subprocess.check_output(["swift", "package", "dump-package"], cwd=PACKAGE_DIR)
    manifest = json.loads(output)
    for dependency in manifest.get("dependencies", []):
        identity = package_identity(dependency)
        if identity not in ALLOWED_PACKAGES:
            errors.append(f"外部パッケージ {identity} は使えない。入れるなら設計書に理由を書き、このスクリプトを更新する")
    targets = {target["name"]: target for target in manifest["targets"]}
    for name, target in targets.items():
        if name not in ALLOWED_TARGET_DEPENDENCIES:
            errors.append(f"ターゲット {name} の依存ルールが決まっていない。ALLOWED_TARGET_DEPENDENCIES に追加する")
            continue
        internal = dependency_names(target) & set(targets)
        forbidden = internal - ALLOWED_TARGET_DEPENDENCIES[name]
        if forbidden:
            errors.append(f"{name} は {', '.join(sorted(forbidden))} に依存できない")


def check_project(errors):
    output = subprocess.check_output(["plutil", "-convert", "json", "-o", "-", str(PROJECT_FILE)])
    objects = json.loads(output)["objects"]
    for object_id, body in objects.items():
        if body["isa"] == "XCRemoteSwiftPackageReference":
            errors.append(f"Xcode プロジェクトに外部パッケージ {body.get('repositoryURL', object_id)} が追加されている")
    for body in objects.values():
        if body["isa"] != "PBXNativeTarget":
            continue
        name = body["name"]
        products = {objects[product_id]["productName"] for product_id in body.get("packageProductDependencies", [])}
        allowed = ALLOWED_PRODUCTS.get(name)
        if allowed is None:
            errors.append(f"Xcode ターゲット {name} の依存ルールが決まっていない。ALLOWED_PRODUCTS に追加する")
        elif products - allowed:
            errors.append(f"{name} は {', '.join(sorted(products - allowed))} に依存できない")


def main():
    errors = []
    check_package(errors)
    check_project(errors)
    if errors:
        for error in errors:
            print(f"error: {error}")
        return 1
    print("依存関係のルールを満たしています")
    return 0


if __name__ == "__main__":
    sys.exit(main())
