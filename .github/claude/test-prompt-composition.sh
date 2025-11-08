#!/usr/bin/env bash
#
# Test Prompt Composition Script
#
# This script tests the Architect-Gate prompt composition locally before pushing to CI.
# It validates that prompts combine correctly and estimates token usage.
#
# Usage:
#   ./.github/claude/test-prompt-composition.sh
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Architect-Gate Prompt Composition Test${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check we're in the right directory
if [ ! -d ".github/claude/prompts" ]; then
  echo -e "${RED}❌ Error: .github/claude/prompts directory not found${NC}"
  echo "   Please run this script from the repository root"
  exit 1
fi

# Create test directory
TEST_DIR=".architect-gate-test"
mkdir -p "$TEST_DIR"

echo -e "${GREEN}✓${NC} Test directory created: $TEST_DIR"

# Step 1: Compose prompts
echo ""
echo -e "${YELLOW}📝 Composing prompts...${NC}"

# Start with general architecture review (required)
cat .github/claude/prompts/01-general-architecture-review.prompt.md \
    > "$TEST_DIR/full-prompt.md"

echo -e "${GREEN}✓${NC} Added: 01-general-architecture-review.prompt.md"

# Add project-specific prompts if they exist
PROMPT_COUNT=1
for prompt in .github/claude/prompts/02-*.prompt.md .github/claude/prompts/03-*.prompt.md; do
  if [ -f "$prompt" ]; then
    echo "" >> "$TEST_DIR/full-prompt.md"
    echo "---" >> "$TEST_DIR/full-prompt.md"
    echo "" >> "$TEST_DIR/full-prompt.md"
    cat "$prompt" >> "$TEST_DIR/full-prompt.md"
    echo -e "${GREEN}✓${NC} Added: $(basename $prompt)"
    PROMPT_COUNT=$((PROMPT_COUNT + 1))
  fi
done

if [ $PROMPT_COUNT -eq 1 ]; then
  echo -e "${YELLOW}⚠${NC}  No project-specific prompts found (02-*.prompt.md)"
  echo "   Using only the general architecture review prompt"
  echo "   Consider creating a 02-your-project-rules.prompt.md file"
fi

# Step 2: Generate diff (if in git repo)
echo ""
echo -e "${YELLOW}📊 Generating diff vs base branch...${NC}"

if git rev-parse --git-dir > /dev/null 2>&1; then
  # Get default branch
  DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

  # Generate diff
  git diff --unified=3 "origin/$DEFAULT_BRANCH"...HEAD > "$TEST_DIR/pr.diff" 2>/dev/null || \
    git diff HEAD > "$TEST_DIR/pr.diff" 2>/dev/null || \
    echo "No diff available" > "$TEST_DIR/pr.diff"

  DIFF_LINES=$(wc -l < "$TEST_DIR/pr.diff")
  echo -e "${GREEN}✓${NC} Diff generated: $DIFF_LINES lines"

  # Show diff stats
  if [ "$DIFF_LINES" -gt 1 ]; then
    CHANGED_FILES=$(git diff --name-only "origin/$DEFAULT_BRANCH"...HEAD 2>/dev/null | wc -l || echo "0")
    echo "   Base: origin/$DEFAULT_BRANCH"
    echo "   Files changed: $CHANGED_FILES"
  else
    echo -e "${YELLOW}⚠${NC}  No uncommitted changes found"
  fi
else
  echo -e "${YELLOW}⚠${NC}  Not a git repository - skipping diff generation"
  echo "No diff available (not in git repo)" > "$TEST_DIR/pr.diff"
fi

# Step 3: Check context files
echo ""
echo -e "${YELLOW}📚 Checking context files...${NC}"

CONTEXT_FILES=(
  "CLAUDE.md"
  "README.md"
  "package.json"
  "memory-bank/"
  "docs/"
)

for file in "${CONTEXT_FILES[@]}"; do
  if [ -e "$file" ]; then
    echo -e "${GREEN}✓${NC} Found: $file"
  else
    echo -e "${YELLOW}⚠${NC}  Missing: $file (Claude won't see this context)"
  fi
done

# Step 4: Estimate token usage
echo ""
echo -e "${YELLOW}🧮 Estimating token usage...${NC}"

PROMPT_LINES=$(wc -l < "$TEST_DIR/full-prompt.md")
PROMPT_CHARS=$(wc -c < "$TEST_DIR/full-prompt.md")

# Rough estimate: ~4 characters per token
PROMPT_TOKENS=$((PROMPT_CHARS / 4))

echo "   Composed prompt: $PROMPT_LINES lines"
echo "   Estimated input tokens: ~$PROMPT_TOKENS"

# Context files token estimate (very rough)
CLAUDE_MD_TOKENS=0
if [ -f "CLAUDE.md" ]; then
  CLAUDE_MD_TOKENS=$(($(wc -c < "CLAUDE.md") / 4))
fi

MEMORY_BANK_TOKENS=0
if [ -d "memory-bank" ]; then
  MEMORY_BANK_SIZE=$(find memory-bank -type f -name "*.md" -exec wc -c {} + 2>/dev/null | tail -1 | awk '{print $1}' || echo "0")
  MEMORY_BANK_TOKENS=$((MEMORY_BANK_SIZE / 4))
fi

DIFF_TOKENS=$(($(wc -c < "$TEST_DIR/pr.diff") / 4))

TOTAL_INPUT_TOKENS=$((PROMPT_TOKENS + CLAUDE_MD_TOKENS + MEMORY_BANK_TOKENS + DIFF_TOKENS))

echo ""
echo "   Token breakdown:"
echo "   - Prompts:     ~$PROMPT_TOKENS tokens"
echo "   - CLAUDE.md:   ~$CLAUDE_MD_TOKENS tokens"
echo "   - Memory Bank: ~$MEMORY_BANK_TOKENS tokens"
echo "   - PR Diff:     ~$DIFF_TOKENS tokens"
echo "   ─────────────────────────────"
echo "   Total input:   ~$TOTAL_INPUT_TOKENS tokens"
echo ""

# Warn if approaching limits
if [ $TOTAL_INPUT_TOKENS -gt 150000 ]; then
  echo -e "${RED}⚠️  WARNING: Estimated input exceeds 150K tokens${NC}"
  echo "   This may exceed Claude's context window (200K)"
  echo "   Consider reducing context or using a smaller diff"
elif [ $TOTAL_INPUT_TOKENS -gt 100000 ]; then
  echo -e "${YELLOW}⚠️  WARNING: Estimated input >100K tokens${NC}"
  echo "   Large context - review may take longer"
else
  echo -e "${GREEN}✓${NC} Token estimate within safe limits (<100K)"
fi

# Step 5: Cost estimate
echo ""
echo -e "${YELLOW}💰 Cost estimate (Claude 3.5 Haiku)...${NC}"

# Haiku pricing (as of Oct 2024): $0.80/1M input, $4.00/1M output
# Assume ~5-10K output tokens for SAR
OUTPUT_TOKENS=7500

INPUT_COST=$(echo "scale=4; $TOTAL_INPUT_TOKENS * 0.80 / 1000000" | bc)
OUTPUT_COST=$(echo "scale=4; $OUTPUT_TOKENS * 4.00 / 1000000" | bc)
TOTAL_COST=$(echo "scale=4; $INPUT_COST + $OUTPUT_COST" | bc)

echo "   Input:  ~\$$INPUT_COST  ($TOTAL_INPUT_TOKENS tokens @ \$0.80/1M)"
echo "   Output: ~\$$OUTPUT_COST  (~$OUTPUT_TOKENS tokens @ \$4.00/1M)"
echo "   ─────────────────────────────"
echo "   Total:  ~\$$TOTAL_COST per review"
echo ""

# Step 6: Validation checks
echo -e "${YELLOW}🔍 Running validation checks...${NC}"

# Check prompt format
if grep -q "## Your Mission" "$TEST_DIR/full-prompt.md"; then
  echo -e "${GREEN}✓${NC} Prompt contains required sections"
else
  echo -e "${RED}❌${NC} Prompt missing '## Your Mission' section"
fi

if grep -q "SEVERITY:" "$TEST_DIR/full-prompt.md"; then
  echo -e "${GREEN}✓${NC} Prompt defines severity scoring"
else
  echo -e "${YELLOW}⚠${NC}  Prompt doesn't mention severity scoring"
fi

# Step 7: Next steps
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Prompt composition test complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Test artifacts saved to: $TEST_DIR/"
echo "  - full-prompt.md  (composed prompt)"
echo "  - pr.diff         (current changes)"
echo ""
echo "Next steps:"
echo "  1. Review composed prompt:"
echo "     ${BLUE}less $TEST_DIR/full-prompt.md${NC}"
echo ""
echo "  2. Test with ACT (local GitHub Actions):"
echo "     ${BLUE}act pull_request -s ANTHROPIC_API_KEY=\$ANTHROPIC_API_KEY${NC}"
echo ""
echo "  3. Push to branch and create PR to test in CI:"
echo "     ${BLUE}git push origin your-branch${NC}"
echo ""
echo "  4. Add ANTHROPIC_API_KEY secret to GitHub:"
echo "     ${BLUE}Repository Settings → Secrets → Actions → New secret${NC}"
echo ""

# Optional: Check if ACT is installed
if command -v act &> /dev/null; then
  echo -e "${GREEN}✓${NC} ACT is installed - you can test workflows locally"
else
  echo -e "${YELLOW}⚠${NC}  ACT not installed - install it to test workflows locally:"
  echo "   https://github.com/nektos/act#installation"
fi

echo ""
