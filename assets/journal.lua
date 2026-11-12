-- Cabecera de artículo y línea «Cite as», al estilo de una revista.
-- Lee el front matter de cada entrada (solo las que tienen `date`):
--   article-type  (por defecto «Original Article»)
--   keywords      (lista; Quarto la muestra en el encabezado)
--   received / accepted (fechas opcionales)
-- Volumen = año − 2025 en romanos; número = mes. Sin mantenimiento a mano.
-- sitio.html mueve el bloque generado dentro del encabezado del título.

local months = { "January", "February", "March", "April", "May", "June", "July",
  "August", "September", "October", "November", "December" }
local romans = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X",
  "XI", "XII", "XIII", "XIV", "XV" }

local function str(x)
  if x == nil then return nil end
  local t = pandoc.utils.stringify(x)
  if t == "" then return nil end
  return t
end

local function esc(t)
  return (t:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function parse_date(t)
  local y, m, d = t:match("^(%d%d%d%d)-(%d%d?)-(%d%d?)")
  if y then return tonumber(y), tonumber(m), tonumber(d) end
  local mon, dd, yy = t:match("^(%a+)%s+(%d+),%s*(%d%d%d%d)")
  if mon then
    for i, name in ipairs(months) do
      if name:lower() == mon:lower() then return tonumber(yy), i, tonumber(dd) end
    end
  end
  return nil
end

local function pretty(t)
  local y, m, d = parse_date(t)
  if not y then return t end
  return string.format("%d %s %d", d, months[m], y)
end

local function authors(meta)
  local a = meta.author
  if a == nil then return nil end
  if pandoc.utils.type(a) == "List" then
    local out = {}
    for _, item in ipairs(a) do
      local nm = item.name or item
      out[#out + 1] = str(nm.literal or nm)
    end
    return table.concat(out, ", ")
  end
  return str(a)
end

function Pandoc(doc)
  local meta = doc.meta
  local date = str(meta.date)
  if not date then return nil end
  local y, m = parse_date(date)
  if not y then return nil end

  local vol = romans[y - 2025] or tostring(y - 2025)
  local kind = str(meta["article-type"]) or "Original Article"

  local rows = {}
  local function row(label, value)
    if value then
      rows[#rows + 1] = '<p><span class="dd-lbl">' .. label .. '.</span> ' .. esc(value) .. '</p>'
    end
  end

  local rec, acc = str(meta.received), str(meta.accepted)
  if rec then row("Received", pretty(rec)) end
  if acc then row("Accepted", pretty(acc)) end

  local front = string.format(
    '<div class="dd-jfront"><p class="dd-jline"><span class="dd-seg">%s</span> <span class="dd-sep">·</span> <span class="dd-seg">Vol.&nbsp;%s</span> <span class="dd-sep">·</span> <span class="dd-seg">No.&nbsp;%d</span> <span class="dd-sep">·</span> <span class="dd-seg">%s&nbsp;%d</span></p>%s</div>',
    esc(kind), vol, m, months[m], y,
    #rows > 0 and ('<div class="dd-jmeta">' .. table.concat(rows) .. '</div>') or '')
  table.insert(doc.blocks, 1, pandoc.RawBlock("html", front))

  local title = str(meta.title) or ""
  local who = authors(meta)
  local cite = string.format(
    '<div class="dd-cite"><p><span class="dd-lbl">Cite as</span> %s(%d). <em>%s</em>. Drift &amp; Diffusion, %d(%d).</p></div>',
    who and (esc(who) .. " ") or "", y, esc(title), y - 2025, m)
  table.insert(doc.blocks, pandoc.RawBlock("html", cite))
  return doc
end
