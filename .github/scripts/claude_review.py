import anthropic
import os

MAX_DIFF_CHARS = 20000

with open("pr_diff.txt", "r") as f:
    diff = f.read()

if not diff.strip():
    with open("review_result.txt", "w") as f:
        f.write("변경된 코드가 없어요.")
    exit(0)

if len(diff) > MAX_DIFF_CHARS:
    diff = diff[:MAX_DIFF_CHARS] + "\n\n... (diff가 너무 커서 일부만 리뷰했어요)"

client = anthropic.Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])

message = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=2000,
    messages=[
        {
            "role": "user",
            "content": f"""다음 PR diff를 코드리뷰해줘.

리뷰 형식:
- 🔴 버그/보안 이슈 (있을 때만)
- 🟡 개선 권장 사항
- 🟢 잘된 점
- 우선순위 요약 테이블

코드가 없거나 단순 설정 변경이면 간략히 요약만 해줘.
한국어로 작성해줘.
````diff
{diff}
```""",
        }
    ],
)

review_text = f"## 🤖 Claude Code Review\n\n{message.content[0].text}"

with open("review_result.txt", "w") as f:
    f.write(review_text)