# Eval And Promotion

GEPA candidates are advisory until governed promotion occurs outside this repo.

## Candidate Receipts

Candidate receipts carry:

- candidate ref;
- source context packet ref;
- route decision ref;
- evaluation refs;
- score summary;
- trace ref;
- rollback posture;
- promotion recommendation only.

They must not mutate production state or publish product projections.

## Promotion Boundary

Promotion is owned by Mezzanine workflow truth, Citadel authority, and AppKit
review/projection surfaces. GEPA may recommend a candidate, but it never grants
authority or applies a production mutation.
