# Converts the active Hyprland .conf tree into a Lua migration draft.
# It preserves source order and source-line comments while translating active lines.

function trim(s) {
  sub(/^[ \t\r\n]+/, "", s)
  sub(/[ \t\r\n]+$/, "", s)
  return s
}

function lquote(s,    out, i, c) {
  out = "\""
  for (i = 1; i <= length(s); i++) {
    c = substr(s, i, 1)
    if (c == "\\") out = out "\\\\"
    else if (c == "\"") out = out "\\\""
    else if (c == "\t") out = out "\\t"
    else out = out c
  }
  return out "\""
}

function strip_comment(s,    i, c, prev) {
  for (i = 1; i <= length(s); i++) {
    c = substr(s, i, 1)
    prev = i > 1 ? substr(s, i - 1, 1) : ""
    if (c == "#" && prev != "\\") return trim(substr(s, 1, i - 1))
  }
  return trim(s)
}

function split_csv(s, arr,    i, c, part, n) {
  n = 1
  part = ""
  for (i = 1; i <= length(s); i++) {
    c = substr(s, i, 1)
    if (c == ",") {
      arr[n++] = trim(part)
      part = ""
    } else {
      part = part c
    }
  }
  arr[n] = trim(part)
  return n
}

function split_bind(s, arr, has_desc,    i, c, part, n, limit) {
  limit = has_desc ? 5 : 4
  n = 1
  part = ""
  for (i = 1; i <= length(s); i++) {
    c = substr(s, i, 1)
    if (c == "," && n < limit) {
      arr[n++] = trim(part)
      part = ""
    } else {
      part = part c
    }
  }
  arr[n] = trim(part)
  return n
}

function norm_ident(s) {
  s = trim(s)
  gsub(/-/, "_", s)
  return s
}

function table_key(s) {
  s = norm_ident(s)
  if (s ~ /^[A-Za-z_][A-Za-z0-9_]*$/) return s
  return "[" lquote(s) "]"
}

function lua_value(s,    low) {
  s = trim(s)
  if (s ~ /^\$[A-Za-z0-9_]+$/) {
    ref = substr(s, 2)
    if (lua_var[ref]) return ref
  }
  s = expand_vars(s)
  low = tolower(s)
  if (s == "") return "\"\""
  if (low == "true" || low == "on" || low == "yes") return "true"
  if (low == "false" || low == "off" || low == "no") return "false"
  if (s ~ /^[-+]?[0-9]+$/) return s
  if (s ~ /^[-+]?[0-9]+\.[0-9]+$/) return s
  return lquote(s)
}

function norm_mods(s,    a, n, i, out, token) {
  s = trim(s)
  if (s == "") return ""
  gsub(/[ \t]+/, " ", s)
  n = split(s, a, /[ \t]+/)
  out = ""
  for (i = 1; i <= n; i++) {
    token = trim(a[i])
    if (token == "") continue
    out = out (out == "" ? token : " + " token)
  }
  return out
}

function norm_key(mods, key,    m) {
  m = norm_mods(mods)
  key = trim(key)
  if (tolower(substr(key, 1, 4)) == "xf86") key = "XF86" substr(key, 5)
  if (key == "XF86audioraisevolume") key = "XF86AudioRaiseVolume"
  if (key == "XF86audiolowervolume") key = "XF86AudioLowerVolume"
  if (key == "XF86audiomute") key = "XF86AudioMute"
  if (key == "XF86AudioPlayPause") key = "XF86MediaPlayPause"
  if (key == "XF86audiostop") key = "XF86AudioStop"
  if (m == "") return key
  return m " + " key
}

function bind_opts(kind, desc,    opts, sep) {
  opts = "{"
  sep = ""
  if (index(kind, "m") > 0) { opts = opts sep "mouse = true"; sep = ", " }
  if (index(kind, "e") > 0) { opts = opts sep "repeating = true"; sep = ", " }
  if (index(kind, "l") > 0) { opts = opts sep "locked = true"; sep = ", " }
  if (index(kind, "r") > 0) { opts = opts sep "release = true"; sep = ", " }
  if (index(kind, "n") > 0) { opts = opts sep "non_consuming = true"; sep = ", " }
  if (index(kind, "t") > 0) { opts = opts sep "transparent = true"; sep = ", " }
  if (index(kind, "i") > 0) { opts = opts sep "ignore_mods = true"; sep = ", " }
  if (index(kind, "d") > 0 && desc != "") { opts = opts sep "description = " lquote(desc); sep = ", " }
  opts = opts "}"
  return opts == "{}" ? "" : ", " opts
}

function strip_desc_opts(opts,    out) {
  out = opts
  gsub(/, description = "[^"]*"/, "", out)
  gsub(/description = "[^"]*", /, "", out)
  gsub(/description = "[^"]*"/, "", out)
  gsub(/\{, /, "{", out)
  gsub(/, \}/, "}", out)
  return out == ", {}" ? "" : out
}

function opts_with_desc(optbase, desc,    out) {
  if (desc == "") return optbase
  if (optbase == "") return ", {description = " lquote(desc) "}"
  out = optbase
  sub(/\}$/, ", description = " lquote(desc) "}", out)
  return out
}

function workspace_value(s) {
  s = trim(s)
  if (s ~ /^[+-]/) return lquote(s)
  return lua_value(s)
}

function flush_pending_bind() {
  if (pending_key != "") {
    print pending_line
    pending_key = ""
    pending_line = ""
    pending_expr = ""
    pending_optbase = ""
    pending_desc = ""
  }
}

function queue_bind(keystr, expr, opts, desc,    line, merged_opts, combined_desc, optbase) {
  optbase = strip_desc_opts(opts)
  if (pending_key == keystr && pending_optbase == optbase) {
    combined_desc = pending_desc
    if (desc != "") combined_desc = combined_desc == "" ? desc : combined_desc " + " desc
    merged_opts = opts_with_desc(optbase, combined_desc)
    print "hl.bind(" lquote(keystr) ", function() hl.dispatch(" pending_expr "); hl.dispatch(" expr ") end" merged_opts ")"
    pending_key = ""
    pending_line = ""
    pending_expr = ""
    pending_optbase = ""
    pending_desc = ""
    return
  }

  flush_pending_bind()
  line = "hl.bind(" lquote(keystr) ", " expr opts ")"
  pending_key = keystr
  pending_expr = expr
  pending_optbase = optbase
  pending_desc = desc
  pending_line = line
}

function dispatcher_expr(dispatcher, arg,    a) {
  dispatcher = trim(dispatcher)
  arg = trim(arg)
  if (dispatcher == "killactive") return "hl.dsp.window.close()"
  if (dispatcher == "exit") return "hl.dsp.exit(" (arg == "" ? "" : arg) ")"
  if (dispatcher == "workspace") return "hl.dsp.focus({ workspace = " workspace_value(arg) " })"
  if (dispatcher == "movetoworkspace") return "hl.dsp.window.move({ workspace = " workspace_value(arg) " })"
  if (dispatcher == "togglefloating") return "hl.dsp.window.float({ action = \"toggle\" })"
  if (dispatcher == "fullscreen") return "hl.dsp.window.fullscreen(" (arg == "" ? "" : lua_value(arg)) ")"
  if (dispatcher == "pseudo") return "hl.dsp.window.pseudo()"
  if (dispatcher == "togglegroup") return "hl.dsp.group.toggle()"
  if (dispatcher == "changegroupactive") return "hl.dsp.exec_raw(" lquote(trim(dispatcher " " arg)) ")"
  if (dispatcher == "cyclenext") return "hl.dsp.window.cycle_next()"
  if (dispatcher == "bringactivetotop") return "hl.dsp.window.bring_to_top()"
  if (dispatcher == "layoutmsg") return "hl.dsp.layout(" lua_value(arg) ")"
  return "hl.dsp.exec_raw(" lquote(trim(dispatcher " " arg)) ")"
}

function raw_dispatcher_expr(raw,    dispatcher, arg, first_space) {
  raw = trim(raw)
  first_space = index(raw, " ")
  if (first_space == 0) return dispatcher_expr(raw, "")
  dispatcher = substr(raw, 1, first_space - 1)
  arg = trim(substr(raw, first_space + 1))
  return dispatcher_expr(dispatcher, arg)
}

function emit_bind(kind, rhs,    fields, n, suffix, has_desc, mods, key, desc, dispatcher, arg, keystr, opts, raw, expr) {
  delete fields
  suffix = kind
  sub(/^bind/, "", suffix)
  has_desc = index(suffix, "d") > 0
  n = split_bind(rhs, fields, has_desc)
  mods = fields[1]
  key = fields[2]
  if (has_desc) {
    desc = fields[3]
    dispatcher = fields[4]
    arg = fields[5]
  } else {
    desc = ""
    dispatcher = fields[3]
    arg = fields[4]
  }
  keystr = norm_key(mods, key)
  opts = bind_opts(suffix, desc)
  if (dispatcher == "exec") {
    raw = arg
    sub(/^hyprctl dispatch[ \t]+/, "", raw)
    if (raw != arg) expr = raw_dispatcher_expr(raw)
    else expr = "hl.dsp.exec_cmd(" lquote(arg) ")"
  } else {
    expr = dispatcher_expr(dispatcher, arg)
  }
  queue_bind(keystr, expr, opts, desc)
}

function expand_vars(s,    out, i, c, j, name) {
  out = ""
  i = 1
  while (i <= length(s)) {
    c = substr(s, i, 1)
    if (c == "$") {
      j = i + 1
      name = ""
      while (j <= length(s) && substr(s, j, 1) ~ /[A-Za-z0-9_]/) {
        name = name substr(s, j, 1)
        j++
      }
      if (name == "HOME") out = out ENVIRON["HOME"]
      else if (name in vars) out = out vars[name]
      else out = out "$" name
      i = j
    } else {
      out = out c
      i++
    }
  }
  return out
}

function is_config_block(name) {
  return name ~ /^(animations|binds|cursor|debug|decoration|dwindle|ecosystem|experimental|general|gestures|group|input|layerrules|master|misc|render|xwayland)$/
}

function path_table_expr(key, value,    parts, n, i, expr) {
  n = 0
  for (i = 1; i <= block_depth; i++) parts[++n] = block_path[i]
  split(key, key_parts, ".")
  for (i = 1; i <= length(key_parts); i++) {
    if (key_parts[i] != "") parts[++n] = key_parts[i]
  }
  expr = table_key(parts[n]) " = " lua_value(value)
  for (i = n - 1; i >= 1; i--) expr = table_key(parts[i]) " = { " expr " }"
  return expr
}

function emit_config_assignment(key, value) {
  print "hl.config({ " path_table_expr(key, value) " })"
}

function emit_gesture(value,    fields, n, cmd) {
  delete fields
  n = split_csv(expand_vars(value), fields)
  if (n >= 3 && fields[3] == "workspace") {
    print "hl.gesture({ fingers = " fields[1] ", direction = " lquote(fields[2]) ", action = \"workspace\" })"
    return
  }
  if (n >= 5 && fields[3] == "dispatcher" && fields[4] == "exec") {
    cmd = fields[5]
    print "hl.gesture({ fingers = " fields[1] ", direction = " lquote(fields[2]) ", action = function() hl.exec_cmd(" lquote(cmd) ") end })"
    return
  }
  emit_raw_comment("gesture", "gesture = " value)
}

function emit_bezier(value,    fields, n) {
  delete fields
  n = split_csv(expand_vars(value), fields)
  if (n >= 5) print "hl.curve(" lquote(fields[1]) ", { type = \"bezier\", points = { {" fields[2] ", " fields[3] "}, {" fields[4] ", " fields[5] "} } })"
  else emit_raw_comment("bezier", "bezier = " value)
}

function emit_animation(value,    fields, n) {
  delete fields
  n = split_csv(expand_vars(value), fields)
  if (n >= 2) {
    printf "hl.animation({ leaf = %s, enabled = %s", lquote(fields[1]), fields[2]
    if (n >= 3 && fields[3] != "") printf ", speed = %s", fields[3]
    if (n >= 4 && fields[4] != "") printf ", bezier = %s", lquote(fields[4])
    if (n >= 5 && fields[5] != "") printf ", style = %s", lquote(fields[5])
    print " })"
  } else emit_raw_comment("animation", "animation = " value)
}

function reset_rule() {
  delete rule_key
  delete rule_val
  delete rule_match_key
  delete rule_match_val
  rule_count = 0
  rule_match_count = 0
}

function add_rule_assignment(key, value) {
  key = trim(key)
  value = expand_vars(value)
  if (key == "opacity") gsub(/[ \t]+=[ \t]+/, " ", value)
  if (key ~ /^match:/) {
    sub(/^match:/, "", key)
    rule_match_key[++rule_match_count] = norm_ident(key)
    rule_match_val[rule_match_count] = value
  } else {
    rule_key[++rule_count] = norm_ident(key)
    rule_val[rule_count] = value
  }
}

function emit_rule(kind,    i, out, sep, match_out) {
  out = ""
  sep = ""
  for (i = 1; i <= rule_count; i++) {
    out = out sep table_key(rule_key[i]) " = " lua_value(rule_val[i])
    sep = ", "
  }
  if (rule_match_count > 0) {
    match_out = ""
    for (i = 1; i <= rule_match_count; i++) {
      match_out = match_out (match_out == "" ? "" : ", ") table_key(rule_match_key[i]) " = " lua_value(rule_match_val[i])
    }
    out = out sep "match = { " match_out " }"
  }
  if (kind == "windowrule") print "hl.window_rule({ " out " })"
  else print "hl.layer_rule({ " out " })"
}

function reset_device() {
  delete device_key
  delete device_val
  device_count = 0
}

function emit_device(    i, out) {
  out = ""
  for (i = 1; i <= device_count; i++) {
    out = out (out == "" ? "" : ", ") table_key(device_key[i]) " = " lua_value(device_val[i])
  }
  print "hl.device({ " out " })"
}

function add_device_assignment(key, value) {
  device_key[++device_count] = norm_ident(key)
  device_val[device_count] = expand_vars(value)
}

function emit_monitor(value,    fields, n, i, out, key) {
  delete fields
  n = split_csv(expand_vars(value), fields)
  out = "output = " lquote(fields[1])
  if (n >= 2 && fields[2] != "") out = out ", mode = " lquote(fields[2])
  if (n >= 3 && fields[3] != "") out = out ", position = " lquote(fields[3])
  if (n >= 4 && fields[4] != "") out = out ", scale = " lua_value(fields[4])
  i = 5
  while (i <= n) {
    key = norm_ident(fields[i])
    if (key != "" && i + 1 <= n) out = out ", " table_key(key) " = " lua_value(fields[i + 1])
    i += 2
  }
  print "hl.monitor({ " out " })"
}

function emit_raw_comment(reason, text) {
  print "-- TODO(" reason "): " text
}

BEGIN {
  print "-- Generated from the current .conf files. Do not edit blindly; regenerate after .conf changes."
  print "-- Source of truth for this migration pass is hyprland.conf and the active files it includes."
  print ""
  print "local function load_hyprlang_vars(path)"
  print "  local values = {}"
  print "  local file = io.open(path, \"r\")"
  print "  if not file then return values end"
  print "  for line in file:lines() do"
  print "    local name, value = line:match(\"^%s*%$([%w_]+)%s*=%s*(.-)%s*$\")"
  print "    if name then"
  print "      value = value:gsub(\"%s+#.*$\", \"\"):gsub(\"^%s+\", \"\"):gsub(\"%s+$\", \"\")"
  print "      values[name] = value"
  print "    end"
  print "  end"
  print "  file:close()"
  print "  return values"
  print "end"
  print ""
  print "local wallust_vars = load_hyprlang_vars(os.getenv(\"HOME\") .. \"/.config/hypr/wallust/wallust-hyprland.conf\")"
  print ""
}

{
  original = $0
  line = strip_comment($0)

  if (line == "") {
    if (mode == "") flush_pending_bind()
    print ""
    next
  }

  if (mode == "" && line !~ /^bind[a-z]*[ \t]*=/) flush_pending_bind()
  print "-- " FILENAME ":" FNR ": " original

  if (mode == "config") {
    if (match(line, /^[A-Za-z0-9_:-]+[ \t]*\{$/)) {
      name = trim(line)
      sub(/[ \t]*\{$/, "", name)
      block_path[++block_depth] = norm_ident(name)
      next
    }
    if (line == "}") {
      if (block_depth > 1) block_depth--
      else { mode = ""; block_depth = 0 }
      next
    }
    if (line ~ /^[A-Za-z0-9_.:-]+[ \t]*=/) {
      key = trim(substr(line, 1, index(line, "=") - 1))
      value = trim(substr(line, index(line, "=") + 1))
      if (block_path[1] == "gestures" && key == "gesture") emit_gesture(value)
      else if (block_path[1] == "animations" && key == "bezier") emit_bezier(value)
      else if (block_path[1] == "animations" && key == "animation") emit_animation(value)
      else emit_config_assignment(key, value)
      next
    }
    emit_raw_comment("untranslated", line)
    next
  }

  if (mode == "device") {
    if (line == "}") {
      emit_device()
      mode = ""
      next
    }
    if (line ~ /^[A-Za-z0-9_.:-]+[ \t]*=/) {
      key = trim(substr(line, 1, index(line, "=") - 1))
      value = trim(substr(line, index(line, "=") + 1))
      add_device_assignment(key, value)
      next
    }
    emit_raw_comment("untranslated", line)
    next
  }

  if (mode == "windowrule" || mode == "layerrule") {
    if (line == "}") {
      emit_rule(mode)
      mode = ""
      next
    }
    if (line ~ /^[A-Za-z0-9_.:-]+[ \t]*=/) {
      key = trim(substr(line, 1, index(line, "=") - 1))
      value = trim(substr(line, index(line, "=") + 1))
      add_rule_assignment(key, value)
      next
    }
    emit_raw_comment("untranslated", line)
    next
  }

  if (line ~ /^\$/) {
    split(line, kv, "=")
    name = trim(substr(kv[1], 2))
    value = expand_vars(trim(substr(line, index(line, "=") + 1)))
    vars[name] = value
    if (FILENAME ~ /wallust-hyprland\.conf$/) {
      lua_var[name] = 1
      print "local " name " = wallust_vars." name " or " lquote(value)
    } else {
      print "local " name " = " lquote(value)
    }
    next
  }

  if (line ~ /^source[ \t]*=/) {
    value = trim(substr(line, index(line, "=") + 1))
    print "-- source preserved by generator ordering: " value
    next
  }

  if (match(line, /^windowrule[ \t]*\{$/)) {
    mode = "windowrule"
    reset_rule()
    next
  }

  if (match(line, /^layerrule[ \t]*\{$/)) {
    mode = "layerrule"
    reset_rule()
    next
  }

  if (match(line, /^device[ \t]*\{$/)) {
    mode = "device"
    reset_device()
    next
  }

  if (match(line, /^[A-Za-z0-9_:-]+[ \t]*\{$/)) {
    name = trim(line)
    sub(/[ \t]*\{$/, "", name)
    name = norm_ident(name)
    if (is_config_block(name)) {
      mode = "config"
      block_depth = 1
      block_path[1] = name
      next
    }
  }

  if (line ~ /^[A-Za-z0-9_]+:[A-Za-z0-9_.:-]+[ \t]*=/) {
    key = trim(substr(line, 1, index(line, "=") - 1))
    value = trim(substr(line, index(line, "=") + 1))
    split(key, colon_parts, ":")
    block_depth = 1
    block_path[1] = norm_ident(colon_parts[1])
    emit_config_assignment(colon_parts[2], value)
    block_depth = 0
    next
  }

  if (line ~ /^exec-once[ \t]*=/) {
    value = expand_vars(trim(substr(line, index(line, "=") + 1)))
    print "hl.on(\"hyprland.start\", function() hl.exec_cmd(" lquote(value) ") end)"
    next
  }

  if (line ~ /^exec[ \t]*=/) {
    value = expand_vars(trim(substr(line, index(line, "=") + 1)))
    print "hl.exec_cmd(" lquote(value) ")"
    next
  }

  if (line ~ /^env[ \t]*=/) {
    value = expand_vars(trim(substr(line, index(line, "=") + 1)))
    delete fields
    split_csv(value, fields)
    print "hl.env(" lquote(fields[1]) ", " lquote(fields[2]) ")"
    next
  }

  if (line ~ /^monitor[ \t]*=/) {
    value = trim(substr(line, index(line, "=") + 1))
    if (FILENAME ~ /hyprland-gui\.conf$/) {
      print "-- monitor skipped: nwg-displays generated monitors.conf is authoritative"
    } else {
      emit_monitor(value)
    }
    next
  }

  if (line ~ /^workspace[ \t]*=/) {
    value = expand_vars(trim(substr(line, index(line, "=") + 1)))
    print "hl.workspace_rule({ workspace = " lquote(value) " })"
    next
  }

  if (line ~ /^bezier[ \t]*=/) {
    value = expand_vars(trim(substr(line, index(line, "=") + 1)))
    delete fields
    n = split_csv(value, fields)
    if (n >= 5) print "hl.curve(" lquote(fields[1]) ", { type = \"bezier\", points = { {" fields[2] ", " fields[3] "}, {" fields[4] ", " fields[5] "} } })"
    else emit_raw_comment("bezier", line)
    next
  }

  if (line ~ /^animation[ \t]*=/) {
    value = expand_vars(trim(substr(line, index(line, "=") + 1)))
    delete fields
    n = split_csv(value, fields)
    if (n >= 2) {
      printf "hl.animation({ leaf = %s, enabled = %s", lquote(fields[1]), fields[2]
      if (n >= 3 && fields[3] != "") printf ", speed = %s", fields[3]
      if (n >= 4 && fields[4] != "") printf ", bezier = %s", lquote(fields[4])
      if (n >= 5 && fields[5] != "") printf ", style = %s", lquote(fields[5])
      print " })"
    } else emit_raw_comment("animation", line)
    next
  }

  if (line ~ /^bind[a-z]*[ \t]*=/) {
    kind = trim(substr(line, 1, index(line, "=") - 1))
    rhs = expand_vars(trim(substr(line, index(line, "=") + 1)))
    emit_bind(kind, rhs)
    next
  }

  emit_raw_comment("untranslated", line)
}

END {
  flush_pending_bind()
}
