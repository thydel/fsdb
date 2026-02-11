<!--
echo '$table-of-contents$' > tmp/toc.md
< cte-class.md pandoc -f gfm -t gfm --toc --toc-depth=6 --template tmp/toc.md --columns=196 | grep -v Table.of.Contents
-->

-   [Operator classes (pipeline semantics)](#operator-classes-pipeline-semantics)
    -   [Core idea](#core-idea)
-   [Operator classes](#operator-classes)
    -   [`source`](#source)
    -   [`map`](#map)
    -   [`filter`](#filter)
    -   [`aggregate`](#aggregate)
    -   [`order_limit`](#order_limit)
-   [Summary table](#summary-table)
    -   [Rule of thumb](#rule-of-thumb)

# Operator classes (pipeline semantics)

Each step in the pipeline belongs to a **semantic operator class**.
Classes describe *how a step transforms rows*, not how it is implemented in SQL.

The key distinction is whether an operator preserves row identity and
cardinality, or whether it must reason about the input relation as a
whole.

## Core idea

* **Monotonic operators** transform rows independently.

  * Adding input rows cannot make existing output rows disappear.

* **Non-monotonic operators** may merge, collapse, or reshuffle rows.

  * Output cardinality cannot be reasoned about row-by-row.
  * These operators form semantic boundaries in the pipeline.

This classification is aligned with relational algebra, DataFrame
semantics, and DuckDB’s optimizer behavior.

---

# Operator classes

## `source`

Introduces rows into the pipeline.

* No implicit input
* Defines the initial relation

Examples:

* table scan
* view reference
* external file read

---

## `map`

Row-wise transformation with **exactly one output row per input row**.

* Preserves row cardinality
* Does not depend on other rows
* Order-independent

Typical uses:

* projection (`SELECT a, b`)
* computed columns (`SELECT *, expr AS x`)
* column exclusion
* formatting / decoration

---

## `filter`

Row elimination based on a predicate.

* Output rows are a subset of input rows
* Cardinality is **non-increasing**
* Row-wise and monotonic

Typical uses:

* `WHERE` conditions
* predicate-based pruning

---

## `aggregate`

Row-restructuring operations that **do not preserve row identity**.

* Output cardinality is not predictable from input cardinality
* Requires reasoning over the entire input relation
* Acts as a semantic barrier

Typical uses:

* `GROUP BY`
* `SUM`, `COUNT`, `AVG`, …
* `DISTINCT`
* global aggregates

---

## `order_limit`

Output shaping without changing row content.

* Does not create or modify values
* May restrict visible rows
* Typically applied at the end of a pipeline

Typical uses:

* `ORDER BY`
* `LIMIT`, `OFFSET`

---

# Summary table

| Class         | Row behavior                 | Monotonic | Notes                           |
| ------------- | ---------------------------- | --------- | ------------------------------- |
| `source`      | Introduces rows              | N/A       | Pipeline root                   |
| `map`         | 1 input → 1 output           | Yes       | Row-wise, cardinality preserved |
| `filter`      | Subset of input rows         | Yes (↓)   | Cardinality non-increasing      |
| `aggregate`   | Collapses / reshapes rows    | No        | Requires whole-relation view    |
| `order_limit` | Reorders or truncates output | Yes (↓)   | Presentation-level operator     |

---

## Rule of thumb

> If an operator must see the entire input relation to determine how
> many rows it produces, it is an **aggregate**.  Otherwise, it is a
> **map**, **filter**, or **order/limit** operator.

This rule is sufficient to classify all current pipeline steps and to
reason about valid compositions and rewrites.
