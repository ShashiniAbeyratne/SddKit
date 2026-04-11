#!/usr/bin/env bash
# SDD-Kit standards hook — runs after every Write/Edit tool call.
# Checks changed files against the universal rules from sdd-standards/standards-rules.md.
# Output is fed back to Claude as context — violations are seen immediately.
#
# Claude Code injects the tool input as JSON on stdin.
# We parse the file path(s) from it.

set -euo pipefail

# Parse file path from the tool input JSON (stdin)
INPUT=$(cat)
FILE=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    # Write tool uses 'file_path', Edit uses 'file_path' too
    print(d.get('file_path', ''))
except:
    pass
" 2>/dev/null || echo "")

# Only check source files — skip .sdd/, .claude/, markdown, json, yaml
if [ -z "$FILE" ]; then exit 0; fi
case "$FILE" in
  *.md|*.json|*.yaml|*.yml|*.sdd/*|*.claude/*|CLAUDE.md) exit 0 ;;
esac
if [ ! -f "$FILE" ]; then exit 0; fi

VIOLATIONS=""

# NO_CONSOLE_LOG — ERROR
if grep -nE '\bconsole\.(log|warn|error|debug|info)\b' "$FILE" 2>/dev/null | grep -v '// sdd-ignore' | grep -q .; then
  LINES=$(grep -nE '\bconsole\.(log|warn|error|debug|info)\b' "$FILE" | grep -v '// sdd-ignore' | head -5 | awk '{print "  " $0}')
  VIOLATIONS="${VIOLATIONS}\n[ERROR] NO_CONSOLE_LOG — console.* found in $FILE:\n$LINES"
fi

# NO_HARDCODED_SECRETS — ERROR
if grep -nEi '(password|secret|apikey|api_key|token|connectionstring)\s*=\s*["\x27][^"\x27${}]+["\x27]' "$FILE" 2>/dev/null | grep -v '// sdd-ignore' | grep -q .; then
  LINES=$(grep -nEi '(password|secret|apikey|api_key|token|connectionstring)\s*=\s*["\x27][^"\x27${}]+["\x27]' "$FILE" | grep -v '// sdd-ignore' | head -3 | awk '{print "  " $0}')
  VIOLATIONS="${VIOLATIONS}\n[ERROR] NO_HARDCODED_SECRETS — potential secret literal in $FILE:\n$LINES"
fi

# NO_SQL_CONCAT — ERROR (string building with SQL keywords)
if grep -nE '(SELECT|INSERT|UPDATE|DELETE|WHERE).*\+\s*[a-zA-Z]' "$FILE" 2>/dev/null | grep -v '// sdd-ignore' | grep -q .; then
  LINES=$(grep -nE '(SELECT|INSERT|UPDATE|DELETE|WHERE).*\+\s*[a-zA-Z]' "$FILE" | grep -v '// sdd-ignore' | head -3 | awk '{print "  " $0}')
  VIOLATIONS="${VIOLATIONS}\n[ERROR] NO_SQL_CONCAT — SQL string concatenation found in $FILE:\n$LINES"
fi

# NO_ANY_TYPE — WARNING (TypeScript)
if [[ "$FILE" == *.ts || "$FILE" == *.tsx ]]; then
  if grep -nE ':\s*any\b' "$FILE" 2>/dev/null | grep -v '// sdd-ignore' | grep -q .; then
    LINES=$(grep -nE ':\s*any\b' "$FILE" | grep -v '// sdd-ignore' | head -3 | awk '{print "  " $0}')
    VIOLATIONS="${VIOLATIONS}\n[WARNING] NO_ANY_TYPE — explicit 'any' type in $FILE:\n$LINES"
  fi
fi

# NO_MAGIC_NUMBERS — WARNING (bare numeric literals not in const/enum)
if grep -nE '[^a-zA-Z_][0-9]{2,}[^0-9;,\]]' "$FILE" 2>/dev/null | grep -vE '(const|enum|readonly|\bport\b|\bversion\b|import|//|/\*)' | grep -v '// sdd-ignore' | grep -q .; then
  LINES=$(grep -nE '[^a-zA-Z_][0-9]{2,}[^0-9;,\]]' "$FILE" | grep -vE '(const|enum|readonly|\bport\b|\bversion\b|import|//|/\*)' | grep -v '// sdd-ignore' | head -3 | awk '{print "  " $0}')
  VIOLATIONS="${VIOLATIONS}\n[WARNING] NO_MAGIC_NUMBERS — magic numbers in $FILE:\n$LINES"
fi

# Output violations — Claude Code feeds hook stdout back as context
if [ -n "$VIOLATIONS" ]; then
  echo ""
  echo "⚠️  SDD Standards violations detected in $FILE"
  echo "Fix these before running /sdd-standards or /sdd-commit."
  echo "Add // sdd-ignore on a line to suppress a specific check."
  echo -e "$VIOLATIONS"
fi

# Auto-format (stack-aware, best-effort — failures are silent)
if [[ "$FILE" == *.ts || "$FILE" == *.tsx || "$FILE" == *.js || "$FILE" == *.jsx ]]; then
  command -v npx &>/dev/null && npx prettier --write "$FILE" 2>/dev/null || true
elif [[ "$FILE" == *.cs ]]; then
  command -v dotnet &>/dev/null && dotnet format --include "$FILE" 2>/dev/null || true
elif [[ "$FILE" == *.go ]]; then
  command -v gofmt &>/dev/null && gofmt -w "$FILE" 2>/dev/null || true
elif [[ "$FILE" == *.py ]]; then
  command -v black &>/dev/null && black "$FILE" 2>/dev/null || true
fi

exit 0
