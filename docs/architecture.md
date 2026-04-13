# Architecture

## Goal

Build a zero-cost, portfolio-quality resume analysis product that runs entirely in the browser for `v1`.

## System shape

```text
Flutter Web
  -> Upload and session flow
  -> JS interop bridges
  -> Resume parsing and normalization
  -> ATS scoring engine
  -> Job match engine
  -> Optional WebLLM rewrite layer
  -> IndexedDB / local browser persistence
```

## Core principles

- Deterministic analysis first
- AI as enhancement, not authority
- Local-first privacy posture
- Public GitHub-ready repo structure
- Clear separation between presentation, domain, and data concerns

## Main modules

- `lib/app`
  - app entry, router, theme
- `lib/core`
  - shared constants, models, layout widgets
- `lib/features/upload`
  - file intake and validation
- `lib/features/analysis`
  - ATS scoring, issue cards, section breakdown
- `lib/features/job_match`
  - target role parsing and keyword gaps
- `lib/features/ai_assist`
  - local AI rewrite prompts and capability checks
- `lib/features/report`
  - export and handoff surfaces
- `lib/features/demo`
  - deterministic sample walkthrough
- `web/js`
  - browser-specific interop bridges

## Planned data model

### ResumeDocument

- `id`
- `fileName`
- `fileType`
- `rawText`
- `sections`
- `contactInfo`

### ResumeSection

- `type`
- `title`
- `rawContent`
- `bullets`
- `order`

### AnalysisReport

- `overallScore`
- `atsScore`
- `readabilityScore`
- `impactScore`
- `keywordScore`
- `strengths`
- `issues`
- `sectionScores`

### JobMatchReport

- `matchScore`
- `matchedKeywords`
- `missingKeywords`
- `missingSkills`
- `tailoringSuggestions`

### RewriteSuggestion

- `sectionType`
- `originalText`
- `rewrittenText`
- `explanation`
- `confidence`

## Web integrations

- `pdf_bridge.js`
  - PDF text extraction via PDF.js
- `docx_bridge.js`
  - DOCX conversion via Mammoth.js
- `ai_bridge.js`
  - browser AI capability checks and worker orchestration
- `ai_worker.js`
  - isolated local AI execution

## Scoring guidance

Recommended first-pass score weights:

- 20% completeness
- 20% section quality
- 20% impact language
- 20% keyword relevance
- 10% readability
- 10% ATS safety
