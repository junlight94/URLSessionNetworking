# Client

네트워크 요청을 수행하는 클라이언트

## 파일

| 파일 | 역할 |
|------|------|
| `NetworkClient` | 클라이언트 프로토콜 |
| `DefaultNetworkClient` | 기본 구현체 |
| `Session` | URLSession + Interceptor 조합 |

## 구조

```mermaid
classDiagram
    class NetworkClient {
        <<protocol>>
        +send(request) Response
    }
    
    class DefaultNetworkClient {
        -session: Session
        +send(request) Response
        -requestData() (Data, URLResponse)
        -handleResponse() T
    }
    
    class Session {
        +session: URLSession
        +configuration: URLSessionConfiguration
        +interceptor: RequestInterceptor
        +plain: Session
        +auth(tokenProvider) Session
    }
    
    NetworkClient <|.. DefaultNetworkClient
    DefaultNetworkClient --> Session
```

## Session 프리셋

| 프리셋 | 설명 |
|--------|------|
| `.plain` | 기본 헤더 + 재시도 |
| `.auth(tokenProvider:)` | 기본 헤더 + 인증 토큰 + 재시도 |
