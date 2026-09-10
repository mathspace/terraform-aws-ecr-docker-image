# Agent instructions

## Threat model

- Use [THREAT_MODEL.md](THREAT_MODEL.md) when reviewing code, and check relevant claims
  against the current code and deployment configuration. If the document has
  not landed yet, note that gap and review using the available evidence.
- Keep the threat model up to date with changes to code, deployment, and
  infrastructure. Once it exists, update affected sections in the same PR
  whenever a change alters the documented architecture, trust boundaries,
  data flows, permissions, or security assumptions.
