local Parser = require "argparse"
getmetatable(Parser()).error = function(_, msg) error(msg) end

describe("tests related to commands", function()
   it("handles commands after arguments", function()
      local parser = Parser "name"
      parser:argument "file"
      parser:command "create"
      parser:command "remove"

      local args = parser:parse{"temp.txt", "remove"}
      assert.same({file = "temp.txt", remove = true}, args)
   end)

   it("switches context properly", function()
      local parser = Parser "name"
         :add_help(false)
      local install = parser:command "install"
      install:flag "-q" "--quiet"

      local args = parser:parse{"install", "-q"}
      assert.same({install = true, quiet = true}, args)
      assert.has_error(function() parser:parse{"-q", "install"} end, "unknown option '-q'")
   end)

   it("uses command_target property to save command name", function()
      local parser = Parser "name"
         :add_help(false)
         :command_target("command")
      local install = parser:command "install"
      install:flag "-q" "--quiet"

      local args = parser:parse{"install", "-q"}
      assert.same({install = true, quiet = true, command = "install"}, args)
   end)

   it("allows to continue passing old options", function()
      local parser = Parser "name"
      parser:flag "-v" "--verbose" {
         count = "*"
      }
      parser:command "install"

      local args = parser:parse{"-vv", "install", "--verbose"}
      assert.same({install = true, verbose = 3}, args)
   end)

   it("handles nested commands", function()
      local parser = Parser "name"
      local foo = parser:command "foo"
      foo:command "bar"
      foo:command "baz"

      local args = parser:parse{"foo", "bar"}
      assert.same({foo = true, bar = true}, args)
   end)

   it("handles no commands depending on parser.require_command", function()
      local parser = Parser "name"
      parser:command "install"

      assert.has_error(function() parser:parse{} end, "a command is required")

      parser:require_command(false)
      local args = parser:parse{}
      assert.same({}, args)
   end)

   it("Detects wrong commands", function()
      local parser = Parser "name"
      parser:command "install"

      assert.has_error(function() parser:parse{"run"} end, "unknown command 'run'")
   end)

   it("stops parsing options after command with nargs='...'", function()
      local parser = Parser "name"
         :add_help(false)
      local cmd = parser:command "run"
         :args("...")
      cmd:option "--foo"

      local args = parser:parse{"run", "--bar", "--baz", "qux"}
      assert.same({run = {"--bar", "--baz", "qux"}}, args)
   end)

   it("parses options before command with nargs='...'", function()
      local parser = Parser "name"
         :add_help(false)
      parser:option "--global"
      local cmd = parser:command "run"
         :args("...")
      cmd:option "--foo"

      local args = parser:parse{"--global", "value", "run", "--bar", "--baz"}
      assert.same({global = "value", run = {"--bar", "--baz"}}, args)
   end)

   it("handles command with nargs='...' without remainder args", function()
      local parser = Parser "name"
         :add_help(false)
      local cmd = parser:command "run"
         :args("...")
      cmd:option "--foo"

      local args = parser:parse{"run"}
      assert.same({run = true}, args)
   end)

   it("handles nested commands with nargs='...'", function()
      local parser = Parser "name"
         :add_help(false)
      local foo = parser:command "foo"
      local bar = foo:command "bar"
         :args("...")
      bar:option "--opt"

      local args = parser:parse{"foo", "bar", "--something", "--else"}
      assert.same({foo = true, bar = {"--something", "--else"}}, args)
   end)

   it("command with nargs='...' captures options-like strings", function()
      local parser = Parser "name"
         :add_help(false)
      parser:option "--before"
      local cmd = parser:command "exec"
         :args("...")

      local args = parser:parse{"--before", "val", "exec", "-x", "--flag", "arg"}
      assert.same({before = "val", exec = {"-x", "--flag", "arg"}}, args)
   end)
end)
