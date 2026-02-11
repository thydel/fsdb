# Get all journal related to duckdb

```bash
rsync -av $(rg --sort path -lig '*.md' duck | jq -rR './"/"|.[:2] | join("/")' | uniq) ../fsdb/journals/
cd ../fsdb/journals/
rm -rf */tmp */out/*.db
find -name '*~/ | xargs rm
```
