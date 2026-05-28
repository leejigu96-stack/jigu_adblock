# JIGU AdBlock - Release Repository

JIGU AdBlock Chrome 확장의 자동 업데이트 배포 저장소.

**개인용. 라이센스 신경 X.**

## 🚨 키 백업 절대 규칙

`key.pem` = **이 키 잃으면 확장 ID 바뀜 → 사용자가 다시 설치해야 함.**

백업 위치:
- `F:\jigu_adblock_releases\key.pem` (원본)
- `D:\jigu_adblock_backup\key.pem` (1차 백업)
- `gdrive-jigu:backup/jigu_adblock_key.pem` (2차 백업, 구글드라이브)

GitHub 에 절대 push 하지 말 것. `.gitignore` 에 박혀있음.

## 확장 ID

**`eaegabiiaigcbdhfgjchgbehbfaceibb`**

`key.pem` 의 공개키 SHA256 에서 파생. 키 보존하는 한 영구 동일.

## 디렉토리

```
F:\jigu_adblock_releases\
├── key.pem             ← 서명용 비밀키 (백업 필수, git 제외)
├── extension_id.txt    ← 확장 ID (참고용, git 제외)
├── update.xml          ← Chrome 폴링 대상
├── update.xml          ← 매 릴리즈 갱신
├── release.ps1         ← 릴리즈 자동화
├── .gitignore
└── releases/
    ├── jigu_adblock-0.2.0.crx
    └── ...
```

## 릴리즈 절차

```powershell
# 코드 수정 (F:\jigu_adblock\) 후
cd F:\jigu_adblock_releases
.\release.ps1 -Version 0.3.0
```

이 한 줄이 자동으로:
1. manifest.json 버전 갱신
2. CRX 패킹 (같은 키)
3. update.xml 갱신
4. git commit + push

→ Chrome 본체가 5시간 내 자동 다운로드 및 적용

## 즉시 업데이트 트리거 (테스트용)

`chrome://extensions` → 우상단 "업데이트" 버튼 → 즉시 폴링 강제
