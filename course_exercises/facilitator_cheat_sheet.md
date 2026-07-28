# Facilitator Cheat Sheet (One Page)

Use this guide to run five 15-minute activities using the concrete AI prompts.
For Activities 4 and 5, the new prompt files are facilitator examples only, not the required learner wording.

## Session Setup (2 minutes)

- Ask learners to open:
  - ai_prompts/context_pack.md
  - ai_prompts/01_create_model.md
  - ai_prompts/02_explain_code.md
  - ai_prompts/03_suggest_improvements.md
  - ai_prompts/04_extract_data.md
  - ai_prompts/05_documentation.md
- Instruct learners to paste context first, then one full prompt block for Activities 1-3.
- For Activities 4-5, tell learners to write their own prompt from the exercise brief and use the example prompts as inspiration if they get stuck.
- Remind them: request full file content so outputs are copy-paste ready.

## Activity 1 (15 minutes): Create Model

- Prompt to use: Prompt A in ai_prompts/01_create_model.md
- Goal: generate models/playground/rpt_country_daily_revenue.sql + schema YAML.
- Expected artifact:
  - Correct grain: order_date + country
  - Metrics restricted to successful orders
  - Safe division for average metric
  - YAML tests included
- Fast grading signals:
  - Pass: uses ref('fct_orders') and ref('dim_customers')
  - Pass: includes not_null tests on order_date, country, successful_revenue
  - Fail: wrong grain or missing YAML/test changes

## Activity 2 (15 minutes): Explain Code

- Prompt to use: Prompt A in ai_prompts/02_explain_code.md
- Goal: produce an accurate, teachable explanation for models/marts/fct_orders.sql.
- Expected artifact:
  - Correct lineage and grain
  - Correct logic for is_successful_order
  - At least 3 real edge cases
  - Copy-paste-ready schema description text
- Fast grading signals:
  - Pass: states grain assumptions and join duplication risk
  - Pass: maps tests to concrete protection
  - Fail: generic explanation with no file-specific detail

## Activity 3 (15 minutes): Suggest Improvements

- Prompt to use: Prompt A in ai_prompts/03_suggest_improvements.md
- Goal: produce prioritized, implementable review findings for marts layer.
- Expected artifact:
  - High/medium/low prioritization
  - File-specific findings
  - Concrete SQL/YAML snippets for top 3 fixes
  - "Quick wins in 30 minutes" section
- Fast grading signals:
  - Pass: each finding includes issue + why + fix
  - Pass: references specific files/columns
  - Fail: only abstract recommendations

## Debrief Script (5 minutes)

- Ask: Which prompt produced the most reliable output and why?
- Ask: Which hallucination risk appeared first: grain, lineage, or tests?
- Ask: What one instruction in the prompt improved quality the most?

## Common Pitfalls To Watch

- Learner forgets to paste context pack before prompt.
- AI returns pseudo-code rather than full SQL/YAML.
- AI invents models/columns not in this repo.
- AI gives generic improvements without severity or implementation snippets.

## Optional Extension (10 minutes)

- Repeat Activity 1 using Prompt B in ai_prompts/01_create_model.md
- Compare quality across ecommerce vs SaaS domain tasks.

## Additional Hands-On Options (15 minutes each)

### Activity 4: Extract Data

- Example prompt available in ai_prompts/04_extract_data.md
- Goal: learners write their own AI prompt to help answer one clear business question using the project data.
- Suggested scope:
  - models/marts/
  - models/intermediate/
  - analyses/
- Expected artifact:
  - one clear business question
  - a practical SQL or transformation approach
  - a short explanation of what the result would help someone understand
- Fast grading signals:
  - Pass: keeps the scope narrow and focused on one question
  - Pass: suggests a practical extraction or shaping approach
  - Fail: generic advice with no clear business focus

### Activity 5: Documentation

- Example prompt available in ai_prompts/05_documentation.md
- Goal: learners write their own AI prompt to produce clear documentation for one model.
- Suggested scope:
  - models/marts/
  - models/intermediate/
  - models/staging/
- Expected artifact:
  - a short overview of the model
  - key columns or logic explained clearly
  - assumptions or caveats included
  - documentation that would help a new teammate
- Fast grading signals:
  - Pass: explains the purpose of the model clearly
  - Pass: includes useful context such as key fields or assumptions
  - Fail: generic description with no practical value
