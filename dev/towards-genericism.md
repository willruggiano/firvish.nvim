# Towards Genericism

There are several patterns emerging. I think the path forward is to really focus on the Buffer.
Right now, we have several implementations of a buffer backed by arbitrary data. See: `:Buffers`,
`:Jobs`, `start_job()`, etc.

The jobs api is really just sugar coating. The crucial api is that of the Buffer, because this is
not really a job control plugin! It is a plugin where normal vim semantics can take on new meaning
in the context of a "firvish buffer", e.g. deleting a line in the buffer list deletes that buffer.

What we want is a Buffer abstraction, wherein the native buffer holds arbitrary data, and you can do
whatever you want to this data. Until you `:w` the buffer. Then the Buffer takes the difference
between the pre-write data and post-write data and presents this information to the user:

```lua
---@class Buffer
---@field on_line_add      function(line: string)
---@field on_line_remove   function(line: string)
---@field on_line_modify   function(old_line: string, new_line: string)
---@field on_lines_reorder function(old_lines: string[], new_lines: string[])
```

or maybe

```lua
---@class Buffer
---@field on_buf_write_cmd function(snapshot: Snapshot)
```

and then the user could do:

```lua
---@class Snapshot
---@field before string[] the buffer lines before writing
---@field after string[]  the buffer lines after writing
---@field additions
---@field deletions
---@field modifications

-- ... or ...

---@class Snapshot
---@field before string[] the buffer lines before writing
---@field after string[]  the buffer lines after writing
---@field changes Change[]

---@class Change
---@field type  "add"  | "del"  | "mod"  | "ord"
---@field where number | number | number | tuple<number,number>
---@field ... depends on type

local function on_buf_write_cmd(snapshot --[[@as Snapshot]])
  -- Do whatever you want
end
```

An open question is whether the Buffer should know about the concrete type or rather just deal in
lines of anonymous (WHAT IS THE WORD) data. For example we could have this interface:

```lua
---@class Buffer
---@field on_add     function(entry: T)
---@field on_remove  function(entry: T)
---@field on_modify  function(old_entry: T, new_entry: T)
---@field on_reorder function(old_entries: T[], new_entries: T[])
```

where `T` is some user-defined type, e.g. a `Job`.
To accomplish this, we could say that `T` must satisfy some requirements:

```lua
T.mt = {
  ---@return string
  __tostring = function(self)
    -- Stringifies an object of type T, making it suitable to appear in a buffer
  end,
  ---@return T
  __fromstring = function(str)
    -- Constructs an object of type T from a string previously created by tostring()
  end,
}
```

The problem is that not all Ts can be "constructed" from a string. Take for example a `Job`, which
holds a reference to a native vim job handle.

<!-- vim: set tw=100: -->
