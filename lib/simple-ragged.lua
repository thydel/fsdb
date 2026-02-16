-- simple_ragged.lua
-- A much simpler approach: Render -> Strip -> Return

function Table(el)
    -- 1. Let Pandoc render the table to a GFM string (heavy lifting done here)
    -- We wrap it in a Div or just write the element directly
    local raw_doc = pandoc.write(pandoc.Pandoc({el}), "gfm")
    
    -- 2. Now we "post-process" the string safely (because we know it's JUST a table)
    -- Strip padding spaces around pipes
    -- Note: This is safe because 'raw_doc' only contains the table text
    local stripped = raw_doc:gsub("| +", "|"):gsub(" +|", "|")
    
    -- 3. Return as raw markdown
    return pandoc.RawBlock("markdown", stripped)
end
