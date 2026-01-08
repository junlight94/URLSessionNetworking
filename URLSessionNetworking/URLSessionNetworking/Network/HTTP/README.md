# HTTP

HTTP 관련 타입 정의

## 파일

| 파일 | 역할 |
|------|------|
| `HTTPMethod` | HTTP 메서드 |
| `HTTPHeader` | 헤더 키-값 쌍 |
| `HTTPHeaders` | 헤더 컬렉션 |
| `ContentType` | Content-Type 값 |

## HTTPMethod

| 케이스 | 값 |
|--------|-----|
| `.get` | GET |
| `.post` | POST |
| `.put` | PUT |
| `.delete` | DELETE |
| `.patch` | PATCH |

## HTTPHeader

```swift
// 직접 생성
HTTPHeader(name: "X-Custom", value: "value")

// 팩토리 메서드
.contentType(.json)
.userAgent("MyApp/1.0")
.authorization("token")
.authorization(bearerToken: "token")
```

## ContentType

| 케이스 | 값 |
|--------|-----|
| `.json` | application/json |
| `.multipart` | multipart/form-data |
| `.formURLEncoded` | application/x-www-form-urlencoded |
