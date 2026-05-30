# Release gates

Release gate should check:

- executable signing;
- installer/updater signing;
- no PDB in release package unless explicitly allowed;
- no sourcemaps in production package unless explicitly allowed;
- no local developer paths;
- no secrets;
- no unsafe debug flags;
- version metadata;
- update manifest integrity.

Release gates are valuable because they can run offline without production backend impact.
