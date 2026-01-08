# Error

네트워크 에러 정의

## NetworkError

| 케이스 | 설명 |
|--------|------|
| `invalidURL` | URL 생성 실패 |
| `parsingError` | HTTPURLResponse 변환 실패 |
| `decodingFailure` | JSON 디코딩 실패 |
| `invalidStatusCode(Int)` | 2xx 이외의 상태 코드 |
| `jsonEncodingFailed(Error)` | JSON 인코딩 실패 |
