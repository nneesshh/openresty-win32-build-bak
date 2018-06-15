
colors = require "ansicolors"
import insert from table

config = require("lapis.config").get!

local *

flatten_params_helper = (params, out = {}, sep= ", ")->
  return {"{}"} unless params

  insert out, "{ "
  for k,v in pairs params
    insert out, tostring k
    insert out, ": "
    if type(v) == "table"
      flatten_params v, out
    else
      insert out, ("%q")\format v
    insert out, sep

  -- remove last ", "
  out[#out] = nil if out[#out] == sep

  insert out, " }"
  out


flatten_params = (params) ->
  table.concat flatten_params_helper params

query = do
  log_tpl = colors("%{bright}%{cyan}SQL: %{reset}%{magenta}%s%{reset}")
  (q) ->
    l = config.logging
    return unless l and l.queries
    print log_tpl\format q

request = (r) ->
  l = config.logging
  return unless l and l.requests

  import req, res from r

  status = if res.statusline
    res.statusline\match " (%d+) "
  else
    res.status or "200"

  status = tostring status
  status_color = if status\match "^2"
    "green"
  elseif status\match "^5"
    "red"
  else
    "yellow"

  t = "[%{#{status_color}}%s%{reset}] %{bright}%{cyan}%s%{reset} - %s"

  cmd = "#{req.cmd_mth} #{req.cmd_url}"
  print colors(t)\format status, cmd, flatten_params r.url_params

migration = do
  log_tpl = colors("%{bright}%{yellow}Migrating: %{reset}%{green}%s%{reset}")
  (name) -> print log_tpl\format name

notice = do
  log_tpl = colors("%{bright}%{yellow}Notice: %{reset}%s")
  (msg) -> print log_tpl\format msg

migration_summary = (count) ->
  noun = if count == 1
    "migration"
  else
    "migrations"

  print colors("%{bright}%{yellow}Ran%{reset} #{count} %{bright}%{yellow}#{noun}")

start_server = (port, environment_name) ->
  l = config.logging
  return unless l and l.server
  print colors("%{bright}%{yellow}Listening on port #{port}%{reset}")
  if environment_name
    print colors("%{bright}%{yellow}Environment: #{environment_name}%{reset}")

{ :request, :query, :migration, :migration_summary, :notice, :flatten_params,
  :start_server }

