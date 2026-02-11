# How to start

- I'm begining to use claude code (CC)
- I've not yet read the doc
- I've already had a session with CC who
  - Cloned a repo (`baj`)
  - Write a base README for the repo
  - Write a session report
- I know that I can put directives in `CLAUDE.md`
- The task I want to start involve
  - Reading a dozen journals (markowns (MD) files keeping track of
    what was done *and* code (`bash` and `jq` mainly)
  - Learning the personal tool I use (`baj`, some kind of macro
    generator that take MD or yaml files containing small `jq`,
    `bash`, `perl`, ... parts and assemble all snippet as a set of
    bash funcs)
  - All journals are various experimental POC about the tool I now
    want to build with CC
  - The pupopse of the tool is simple
    - Build `duckdb` (DD) DB from big file tree
	- Choosing the rigth set of SQL common table expression (CTE) for
      DD to be able to build pipeline on CTE encapsulated in `bash`
      func (BF) to allow exploration of file tree (mainly for capacity
      planning)
- So, first question is how to organize `CLAUDE.md`
  - I guess I can split the more detailled information that will be
    needed in many files reference in `CLAUDE.md`
  - What are the generic categories and mode of organisation do you
    recommand ?
  - Can you propose a template
