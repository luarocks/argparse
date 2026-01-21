local Parser = require "argparse"
getmetatable(Parser()).error = function(_, msg) error(msg) end

describe("tests related to no-prefix negation", function()
    it("handles no-prefix flag correctly", function()
        local parser = Parser()
        parser:flag "--verbose"
            :no_prefix(true)

        local args = parser:parse { "--verbose" }
        assert.same({ verbose = true }, args)

        args = parser:parse { "--noverbose" }
        assert.same({ verbose = false }, args)

        args = parser:parse {}
        assert.same({}, args)
    end)

    it("preserves short options with no-prefix", function()
        local parser = Parser()
        parser:flag "-v --verbose"
            :no_prefix(true)

        local args = parser:parse { "-v" }
        assert.same({ verbose = true }, args)

        args = parser:parse { "--verbose" }
        assert.same({ verbose = true }, args)

        args = parser:parse { "--noverbose" }
        assert.same({ verbose = false }, args)
    end)

    it("does not apply no-prefix to flags without it enabled", function()
        local parser = Parser()
        parser:flag "--verbose"
        parser:flag "--debug"
            :no_prefix(true)

        assert.has_error(function()
            parser:parse { "--noverbose" }
        end, "unknown option '--noverbose'")

        local args = parser:parse { "--nodebug" }
        assert.same({ debug = false }, args)
    end)

    it("handles multiple no-prefix flags", function()
        local parser = Parser()
        parser:flag "--verbose"
            :no_prefix(true)
        parser:flag "--color"
            :no_prefix(true)

        local args = parser:parse { "--verbose", "--nocolor" }
        assert.same({ verbose = true, color = false }, args)

        args = parser:parse { "--noverbose", "--color" }
        assert.same({ verbose = false, color = true }, args)

        args = parser:parse { "--noverbose", "--nocolor" }
        assert.same({ verbose = false, color = false }, args)
    end)

    it("ignores no-prefix for options with arguments", function()
        local parser = Parser()
        parser:option "--output"
            :no_prefix(true)

        assert.has_error(function()
            parser:parse { "--nooutput" }
        end, "unknown option '--nooutput'")

        local args = parser:parse { "--output", "file.txt" }
        assert.same({ output = "file.txt" }, args)
    end)

    it("handles no-prefix with count action", function()
        local parser = Parser()
        parser:flag "-v --verbose"
            :no_prefix(true)
            :count "*"

        local args = parser:parse { "-vv" }
        assert.same({ verbose = 2 }, args)

        -- Count action doesn't switch to 0 with negation, it increments by 1
        args = parser:parse { "--noverbose" }
        assert.same({ verbose = 1 }, args)
    end)

    it("handles no-prefix in commands", function()
        local parser = Parser()
        local cmd = parser:command "run"
        cmd:flag "--verbose"
            :no_prefix(true)

        local args = parser:parse { "run", "--verbose" }
        assert.same({ run = true, verbose = true }, args)

        args = parser:parse { "run", "--noverbose" }
        assert.same({ run = true, verbose = false }, args)
    end)

    it("does not parse no-prefix with equals syntax", function()
        local parser = Parser()
        parser:flag "--verbose"
            :no_prefix(true)

        -- Parser doesn't recognize --noverbose=false at all
        assert.has_error(function()
            parser:parse { "--noverbose=false" }
        end, "unknown option '--noverbose'")
    end)

    it("handles no-prefix with overwrite", function()
        local parser = Parser()
        parser:flag "--verbose"
            :no_prefix(true)
            :count "*"
            :overwrite(true)

        -- With count action, each invocation increments
        local args = parser:parse { "--verbose", "--noverbose" }
        assert.same({ verbose = 2 }, args)

        args = parser:parse { "--noverbose", "--verbose" }
        assert.same({ verbose = 2 }, args)
    end)
end)
