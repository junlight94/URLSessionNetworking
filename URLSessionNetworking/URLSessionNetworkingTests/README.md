# Tests

SwiftTesting 기반 단위 테스트

## 구조

```
URLSessionNetworkingTests/
├── HTTP/
│   ├── HTTPMethodTests.swift
│   ├── HTTPHeaderTests.swift
│   └── ContentTypeTests.swift
├── Request/
│   ├── ParameterEncoderTests.swift
│   └── RequestParameterTests.swift
├── Interceptor/
│   ├── HeaderAdapterTests.swift
│   ├── AuthAdapterTests.swift
│   └── DefaultRequestRetrierTests.swift
├── RequestTests.swift
└── DefaultNetworkClientTests.swift
```

## 테스트 파일

| 파일 | 테스트 내용 |
|------|------------|
| `HTTPMethodTests` | HTTP 메서드 rawValue 확인 |
| `HTTPHeaderTests` | 헤더 생성, 팩토리 메서드, Hashable |
| `ContentTypeTests` | ContentType rawValue 확인 |
| `ParameterEncoderTests` | JSON/URLQuery 인코딩 |
| `RequestParameterTests` | 파라미터 팩토리 메서드 |
| `HeaderAdapterTests` | 기본 헤더 추가 |
| `AuthAdapterTests` | 인증 토큰 주입 |
| `DefaultRequestRetrierTests` | 재시도 로직 |
| `RequestTests` | Request 프로토콜 기본값 |
| `DefaultNetworkClientTests` | 네트워크 요청/응답 처리 |

## 실행 방법

Xcode에서 `Cmd + U` 또는 Test Navigator에서 실행

## 테스트 도구

- **SwiftTesting**: Swift 5.9+ 테스트 프레임워크
- **Mock URLProtocol**: 네트워크 요청 모킹
