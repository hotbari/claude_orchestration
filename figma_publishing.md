Figma MCP 연동 퍼블리싱 요구사항 정의서 v0.3
(React + Tailwind / PC Only / Content 1280 고정 + 공통 인터랙션/토스트/컨펌 추가)
0. 문서 정보
	•	문서명: Figma MCP 연동 퍼블리싱 요구사항 정의서 (1차 디자인)
	•	대상 Figma: 1차-디자인 (node-id=0-1)
	•	링크: https://www.figma.com/design/mxCTZeei87Q5piZ75HINFq/1%EC%B0%A8-%EB%94%94%EC%9E%90%EC%9D%B8?node-id=0-1&p=f&t=chYXEHyx558kxd3v-0
	•	기술 스택: React + TailwindCSS
	•	구동 환경: PC Web 전용(모바일/태블릿 미지원)
	•	작성일: 2026-02-13
	•	버전: v0.3

1. 목적 / 범위
1.1 목적
	•	Figma 디자인을 MCP로 연동하여 UI 퍼블리싱 코드를 빠르고 일관되게 생성/반영한다.
	•	생성형 AI 서비스 특성상 전 화면 크기/레이아웃 규칙을 통일하여 UI 흔들림을 제거한다.
	•	개발자는 퍼블리싱 기반 위에서 데이터/상태/API 연동을 진행한다.
1.2 포함 범위(퍼블리싱)
	•	React 페이지/레이아웃 구성(PC 전용)
	•	공통 컴포넌트(Button/Input/Modal/Table 등) 뼈대 제공
	•	Tailwind 기반 스타일/규칙(토큰/유틸 규정) 반영
	•	공통 레이아웃(AppShell) 및 고정 ContentContainer 규격 적용
	•	최소 UI 상태: Loading / Empty / Error (우선순위 화면 중심)
	•	공통 인터랙션 규칙(입력/버튼 애니메이션, 토스트, 컨펌 팝업) 적용
1.3 제외 범위(Out of Scope)
	•	백엔드 API 개발 및 실제 연동(목업 수준 가능)
	•	인증/SSO/OIDC, 권한 체계 구현
	•	복잡한 애니메이션(단, 공통 인터랙션 애니메이션은 포함)
	•	모바일/태블릿 반응형, i18n

2. 산출물 정의(개발 착수 기준)
2.1 산출물 형태
	•	Framework: React
	•	Styling: TailwindCSS
	•	산출물
	•	페이지 컴포넌트(라우팅 포함)
	•	공통 레이아웃(AppShell) + 공통 UI 컴포넌트
	•	공통 스타일 규칙(공통 래퍼/토큰/유틸) 및 인터랙션 규칙
	•	자산(SVG/이미지) export 및 코드 반영
2.2 폴더 구조(권장)
src/
  app/ (or pages/)
  components/
    layout/
    ui/
  features/
  styles/
  assets/
2.3 완료(수용) 기준
	•	전 페이지 Content 폭 1280 고정 규칙 준수
	•	피그마 대비 오차: spacing ±2px 허용
	•	지원 브라우저: Chrome / Edge (최신)
	•	접근성 최소:
	•	탭 이동 가능, 포커스 표시
	•	아이콘 버튼 aria-label 부여
	•	공통 토스트/컨펌/입력·버튼 애니메이션 규칙이 전 화면에서 동일하게 동작

3. 전 화면 사이즈 통일 규격 (확정)
모든 화면은 동일한 컨텐츠 폭/패딩/섹션 규칙을 사용한다.페이지별 임의의 폭/패딩 지정 금지.
3.1 기준 컨테이너(확정)
	•	기준 해상도(권장): 1440px 폭 환경
	•	AppShell 전체: PC 전용, 최소폭 적용
	•	min-w-[1440px] 권장(조직 표준이 1366이면 min-w-[1366px]로 조정 가능)
	•	ContentContainer 폭(확정): w-[1280px]
	•	중앙 정렬: mx-auto
	•	좌우 패딩: 기본 px-0 (내부 섹션에서 패딩 관리)
	•	기본 세로 패딩: py-6 (24px)
3.2 레이아웃 고정값(권장 확정안)
	•	Header 높이: 64px (h-16)
	•	Sidebar 폭: 260px (w-[260px])
	•	Content 영역: Header/Sidebar 제외한 본문 영역에 1280 고정 컨텐츠 배치
3.3 스크롤 정책
	•	기본: Content 영역만 세로 스크롤
	•	Header/Sidebar: sticky/fixed 적용 가능(권장)
3.4 그리드/간격 규칙(통일)
	•	간격 스케일: 4/8/12/16/24/32/40/48
	•	카드/섹션 라운드: rounded-xl 통일
	•	테두리: border 통일
	•	그림자: shadow-sm 통일(과한 shadow 금지)

4. MCP 연동 방식 및 작업 원칙
4.1 MCP 적용 범위
	•	공통 컴포넌트/레이아웃 구조 추출
	•	Tailwind 스타일 규칙으로 매핑
	•	SVG/이미지 자산 export 및 반영
	•	코드베이스 적용 후 “통일 규칙 위반” 요소 제거(반복)
4.2 디자인 → 코드 매핑 원칙
	•	Figma Variant → React props로 매핑
	•	예: Button({ variant, size, disabled, loading })
	•	Auto-layout 우선 적용
	•	Absolute positioning은 예외로만 허용(사유 기록)

5. 화면 범위 및 우선순위(사용자 작성 기준 정리)
Figma Frame 기준, 우선순위대로 적용
P0) AI OCR & LLM Extraction Landing Page
	•	Frame 링크: https://www.figma.com/design/mxCTZeei87Q5piZ75HINFq/1%EC%B0%A8-%EB%94%94%EC%9E%90%EC%9D%B8?node-id=1-5251&t=chYXEHyx558kxd3v-0
	•	포함 상태(최소)
	•	랜딩 화면: 제품 특징 소개
	•	메뉴 이동
	•	파일 관리 → File Management & Sub Main
	•	통계 → Analytics Dashboard Sub Main
	•	설정 → Settings & Data Management Sub Main
	•	HI Vector AI → 외부 벡터 데이터 추출 솔루션 링크 이동
	•	MH Ontology AI → 외부 온톨로지 구축 솔루션 링크 이동
P1) File Management & Sub Main
	•	Frame 링크: https://www.figma.com/design/mxCTZeei87Q5piZ75HINFq/1%EC%B0%A8-%EB%94%94%EC%9E%90%EC%9D%B8?node-id=1-8516&t=chYXEHyx558kxd3v-0
	•	포함 상태(최소)
	•	사용자 업로드 파일 통계 제공
	•	파일명/작업자명/작업자ID 검색 → 테이블 표출
	•	필터
	•	전체파일/내파일(대분류)
	•	상태 멀티 체크: OCR 추출 / 완료됨 / 작업중
	•	버전 업데이트 버튼 → File Management & Version Update_stat 이동
	•	새 업로드 버튼 → File Management & New File Upload Start 이동
	•	파일명 클릭 → Edit File Metadata 이동(파일 정보 표시)
	•	“OCR 추출” 또는 “작업중” 클릭 → File Management & OCR Trigger 이동(추출 시작)
	•	연필(수정) 아이콘 클릭 → Edit File Metadata 이동(메타 수정)
	•	OCR 추출을 진행하지 않은 파일만 메타 수정 가능(정합성 유지 목적)
P3) Edit File Metadata
	•	Frame 링크: https://www.figma.com/design/mxCTZeei87Q5piZ75HINFq/1%EC%B0%A8-%EB%94%94%EC%9E%90%EC%9D%B8?node-id=1-6710&t=chYXEHyx558kxd3v-0
	•	포함 상태(최소)
	•	업로드 파일 상태 정보 표시
	•	OCR 미진행 파일만 파일명/파일 설명 입력 활성화
	•	파일 설명은 언제든 수정 가능
	•	파일명 저장 시 파일명 + 버전정보.pdf 형태로 저장
	•	버전명은 자동 입력(수정 불가)
	•	파일 삭제 권한: 관리자=전체, 사용자=본인 업로드만
	•	OCR 추출 권한: 관리자=전체, 사용자=본인 업로드만
	•	파일 삭제 시 공통 Confirm 팝업으로 확인 후 삭제
	•	취소 시 이전 화면으로 이동
	•	저장 결과(성공/경고/실패) → 공통 Toast로 우하단 표시
	•	PDF 뷰어: 프레임 내 확대/축소/다운로드 제공
P4) File Management & Version Update_stat
	•	Frame 링크: https://www.figma.com/design/mxCTZeei87Q5piZ75HINFq/1%EC%B0%A8-%EB%94%94%EC%9E%90%EC%9D%B8?node-id=1-7958&t=chYXEHyx558kxd3v-0
	•	포함 상태(최소)
	•	기존 파일을 신규 파일로 버전업하는 시작 화면
	•	파일 입력/선택 후 분석 → Version Update_File Select로 이동
	•	취소 시 이전 화면 이동
	•	본 화면에서는 파일 선택 기능만 제공
P6) File Management & Version Update_File Select
	•	Frame 링크: https://www.figma.com/design/mxCTZeei87Q5piZ75HINFq/1%EC%B0%A8-%EB%94%94%EC%9E%90%EC%9D%B8?node-id=1-8204&t=chYXEHyx558kxd3v-0
	•	포함 상태(최소)
	•	선택한 파일 정보 표시
	•	원본 파일명 비교 규칙: DB 파일명에서 버전/확장자 제거 후 동일해야 함
	•	동일 파일 발견 시 원본 파일명에 표기, 해당 원본 항목은 수정 불가
	•	파일명은 기본 표기되며 수정 가능
	•	버전은 메이저/마이너 업데이트 가능, 저장 시 파일명+버전+확장자 자동 반영
	•	파일 설명은 언제든 수정 가능
	•	취소 시 이전 화면 이동
	•	업로드 시작 클릭 시 업로드 로딩 팝업 애니메이션 → 완료 후 Toast로 결과 표시
P7) File Management & New File Upload Start
	•	Frame 링크: https://www.figma.com/design/mxCTZeei87Q5piZ75HINFq/1%EC%B0%A8-%EB%94%94%EC%9E%90%EC%9D%B8?node-id=1-8094&t=chYXEHyx558kxd3v-0
	•	포함 상태(최소)
	•	신규 파일 업로드 시작 화면
	•	파일 선택 기능만 제공(추가 입력값 없음)
P8) File Management & New File Upload Select
	•	Frame 링크: https://www.figma.com/design/mxCTZeei87Q5piZ75HINFq/1%EC%B0%A8-%EB%94%94%EC%9E%90%EC%9D%B8?node-id=1-6828&t=chYXEHyx558kxd3v-0
	•	포함 상태(최소)
	•	신규 파일 선택 후 정보 표시 화면
	•	파일 정보 읽어 표시
	•	파일명 변경 가능, 파일 설명 입력 가능
	•	업로드 시 로딩 화면 표시 → 완료 후 Toast로 결과 표시

6. 공통 레이아웃(AppShell) 요구사항
6.1 구조(필수)
	•	Header + Sidebar + Content
	•	Header: 좌(서비스명/로고), 우(사용자 메뉴 UI)
	•	Sidebar: 메뉴 그룹/선택 상태 표시, 메뉴 많아져도 유지(스크롤 가능)
6.2 컨텐츠 통일(필수)
	•	모든 페이지는 반드시 ContentContainer(1280) 사용
	•	페이지 타이틀 영역 통일: Title + Description + Primary Action(옵션)

7. 공통 컴포넌트 및 공통 인터랙션 규칙(필수 추가)
7.1 공통 컴포넌트 목록
컴포넌트
Props/Variants
상태
비고
Button
variant(primary/secondary/ghost), size(sm/md/lg)
hover/focus/disabled/loading
클릭 애니메이션/색상 변화 공통
Input
size, placeholder
focus/error/disabled/typing
입력중 상태 애니메이션 공통
Select
single
open/disabled
PC only
Modal
size(sm/md/lg)
open/close
공통 Confirm/Alert
Table
density, sortable(옵션)
loading/empty
말줄임/줄바꿈 규칙
Tabs
-
active
페이지/섹션 전환
Badge
tone
-
상태 표시
Toast
tone(success/warn/error/info)
show/hide
결과 메시지 자동 생성

8. 공통 UX 규칙 (요청 반영 핵심)
8.1 Input(입력 박스) 공통 규칙
	•	상태 정의
	•	Enabled(입력 가능): 기본 입력 가능 상태
	•	Focused(포커스): 테두리/그림자 강조
	•	Disabled(비활성): 입력 불가/회색 처리
	•	Error(오류): 에러 테두리 + 메시지
	•	Typing(입력중): 사용자가 입력을 진행 중임을 시각적으로 표시
	•	입력중(Typing) 애니메이션 요구
	•	예: 포커스 링이 미세하게 pulse, 또는 underline이 좌→우로 흐르는 효과(과하지 않게)
	•	적용 범위: 모든 Input/Textarea/Search 입력 공통
8.2 Button(버튼) 공통 규칙
	•	기본 상태: default/hover/focus/disabled/loading
	•	클릭 애니메이션 요구
	•	버튼 클릭(press) 시 색상 변화 + 눌림(살짝 scale-down) 효과를 공통 적용
	•	적용 범위: Primary/Secondary/Ghost 버튼 모두(강도는 동일 규칙)
8.3 결과 메시지(Toast) 공통 규칙
	•	화면 동작의 결과는 자동 메시지 생성 → Toast로 표출한다.
	•	노출 위치: 화면 우하단 고정
	•	노출 타입: success / info / warn / error
	•	기본 동작:
	•	성공/정보: 일정 시간 후 자동 닫힘
	•	경고/실패: 자동 닫힘(옵션) 또는 사용자가 닫기 가능
	•	자동 메시지 생성 규칙(예시)
	•	업로드 성공: “업로드가 완료되었습니다.”
	•	저장 성공: “변경 사항이 저장되었습니다.”
	•	삭제 성공: “파일이 삭제되었습니다.”
	•	실패: “요청 처리에 실패했습니다. 잠시 후 다시 시도해주세요.”
	•	권한 없음: “권한이 없습니다.”
8.4 중요 결정(Destructive Action) 공통 Confirm 팝업
	•	삭제, OCR 실행, 버전업로드 시작 등 되돌리기 어려운 행위는 공통 Confirm 팝업으로 확인을 받는다.
	•	Confirm 팝업 기본 구성(통일)
	•	제목: “진행하시겠습니까?” 또는 “삭제하시겠습니까?”
	•	본문: 영향 설명(예: “삭제한 파일은 복구할 수 없습니다.”)
	•	버튼: [취소] [확인(위험 색상)]
	•	적용 대상(최소)
	•	파일 삭제(필수)
	•	업로드 시작(옵션: 대용량 업로드 시)
	•	OCR 추출 시작(옵션: 장시간 소요/비용 발생 시)

9. Tailwind 운영 규칙
	•	페이지별 임의 width/padding 금지→ 폭/외곽 간격은 ContentContainer와 공통 래퍼에서만 관리
	•	커스텀 토큰 최소화(필요 시 tailwind.config.js에)
	•	brand color 1~2개
	•	radius scale
	•	shadow scale
	•	인터랙션 애니메이션(입력중/버튼 클릭)은 공통 클래스/유틸로만 제공(페이지별 개별 구현 금지)

10. 자산(SVG/이미지) 규칙
	•	아이콘: SVG 원본, currentColor 우선
	•	크기: 16/20/24 기준
	•	파일명: ic_{name}_{size}.svg
	•	이미지: img_{feature}_{name}.png

11. 개발 전달 체크리스트(업데이트)
	•	개발자 Figma 접근 권한 확인
	•	P0 Frame 목록 확정(링크 포함)
	•	ContentContainer = 1280 고정 규칙 합의 완료
	•	Header(64) / Sidebar(260) 고정값 합의
	•	Loading 표현 방식 확정(스켈레톤 vs 스피너)
	•	Input Typing 애니메이션 공통 적용 합의
	•	Button 클릭 색상 변화/press 애니메이션 공통 적용 합의
	•	Toast 자동 메시지 생성 규칙 합의
	•	Destructive Action Confirm 팝업 적용 범위 합의(삭제 필수)

개발자에게 전달하는 결론 문장(갱신)
	•	“React + Tailwind로 PC 전용 퍼블리싱을 진행하며, 모든 페이지는 AppShell을 사용하고 ContentContainer 폭을 1280으로 고정하여 화면별 레이아웃/사이즈 흔들림을 원천 차단한다. 또한 Input 입력중 상태 애니메이션, Button 클릭 애니메이션, 결과 Toast 자동 메시지, 삭제 등 중요 작업 Confirm 팝업을 공통 UX로 표준화한다.”

