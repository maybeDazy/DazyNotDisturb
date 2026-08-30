# DazyNotDisturb

방해금지 모드로 선택한 앱의 알림을 가로채 텔레그램으로 전달하는 iOS tweak (RootHide).

## 빌드

GitHub Actions에서 `Build RootHide DazyNotDisturb Deb` 워크플로우를 실행하면 `.deb` 파일이 artifacts에 업로드됩니다.

수동 빌드 (macOS 또는 WSL/Linux):

```bash
make clean
make package THEOS_PACKAGE_SCHEME=roothide FINALPACKAGE=1
```

## 설치

`.deb`를 iOS 디바이스로 옮긴 후:

```bash
dpkg -i disturb.dazy.pro_*.deb
```

또는 Sileo/Zebra로 설치.

## 수정 내역 (4 bugs)

1. **Root.plist detail 키**: dict → `<string>DNBAppListController</string>`
2. **RESOURCE_FILES**: Info.plist만 → Info.plist + Root.plist + icon.png
3. **중복 entry plist**: DazyNotDisturbPrefs.plist 삭제, internal-stage 훅으로 staging 보장
4. **CFNotificationCenter observer**: NULL → `(__bridge void *)self` (+ dealloc에서 observer 제거)
