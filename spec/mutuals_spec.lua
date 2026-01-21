local Parser = require "argparse"
getmetatable(Parser()).error = function(_, msg) error(msg) end

describe("tests related to mutuals", function()
    describe("mutex tests", function()
        it("handles mutex correctly", function()
            local parser = Parser()
            parser:mutex(
                parser:flag "-q" "--quiet"
                :description "Supress logging. ",
                parser:flag "-v" "--verbose"
                :description "Print additional debug information. "
            )

            local args = parser:parse { "-q" }
            assert.same({ quiet = true }, args)

            args = parser:parse { "-v" }
            assert.same({ verbose = true }, args)

            args = parser:parse {}
            assert.same({}, args)
        end)

        it("handles mutex with an argument", function()
            local parser = Parser()
            parser:mutex(
                parser:flag "-q" "--quiet"
                :description "Supress output.",
                parser:argument "log"
                :args "?"
                :description "Log file"
            )

            local args = parser:parse { "-q" }
            assert.same({ quiet = true }, args)

            args = parser:parse { "log.txt" }
            assert.same({ log = "log.txt" }, args)

            args = parser:parse {}
            assert.same({}, args)
        end)

        it("handles mutex with default value", function()
            local parser = Parser()
            parser:mutex(
                parser:flag "-q" "--quiet",
                parser:option "-o" "--output"
                :default "a.out"
            )

            local args = parser:parse { "-q" }
            assert.same({ quiet = true, output = "a.out" }, args)
        end)

        it("raises an error if mutex is broken", function()
            local parser = Parser()
            parser:mutex(
                parser:flag "-q" "--quiet"
                :description "Supress logging. ",
                parser:flag "-v" "--verbose"
                :description "Print additional debug information. "
            )

            assert.has_error(function()
                parser:parse { "-qv" }
            end, "option '-v' can not be used together with option '-q'")

            assert.has_error(function()
                parser:parse { "-v", "--quiet" }
            end, "option '--quiet' can not be used together with option '-v'")
        end)

        it("raises an error if mutex with an argument is broken", function()
            local parser = Parser()
            parser:mutex(
                parser:flag "-q" "--quiet"
                :description "Supress output.",
                parser:argument "log"
                :args "?"
                :description "Log file"
            )

            assert.has_error(function()
                parser:parse { "-q", "log.txt" }
            end, "argument 'log' can not be used together with option '-q'")

            assert.has_error(function()
                parser:parse { "log.txt", "--quiet" }
            end, "option '--quiet' can not be used together with argument 'log'")
        end)

        it("handles multiple mutexes", function()
            local parser = Parser()
            parser:mutex(
                parser:flag "-q" "--quiet",
                parser:flag "-v" "--verbose"
            )
            parser:mutex(
                parser:flag "-l" "--local",
                parser:option "-f" "--from"
            )

            local args = parser:parse { "-q", "-q", "-fTHERE" }
            assert.same({ quiet = true, from = "THERE" }, args)

            args = parser:parse { "-vl" }
            assert.same({ verbose = true, ["local"] = true }, args)
        end)

        it("handles mutexes in commands", function()
            local parser = Parser()
            parser:mutex(
                parser:flag "-q" "--quiet",
                parser:flag "-v" "--verbose"
            )

            local install = parser:command "install"
            install:mutex(
                install:flag "-l" "--local",
                install:option "-f" "--from"
            )

            local args = parser:parse { "install", "-l" }
            assert.same({ install = true, ["local"] = true }, args)

            assert.has_error(function()
                parser:parse { "install", "-qlv" }
            end, "option '-v' can not be used together with option '-q'")
        end)
    end)

    describe("mutin tests", function()
        it("handles mutin correctly", function()
            local parser = Parser()
            parser:mutin(
                parser:option "--username",
                parser:option "--password"
            )

            local args = parser:parse { "--username", "john", "--password", "secret" }
            assert.same({ username = "john", password = "secret" }, args)

            args = parser:parse {}
            assert.same({}, args)
        end)

        it("raises an error if mutin is incomplete", function()
            local parser = Parser()
            parser:mutin(
                parser:option "--username",
                parser:option "--password"
            )

            assert.has_error(function()
                parser:parse { "--username", "john" }
            end, "option '--username' requires option '--password'")

            assert.has_error(function()
                parser:parse { "--password", "secret" }
            end, "option '--password' requires option '--username'")
        end)

        it("handles mutin with flags", function()
            local parser = Parser()
            parser:mutin(
                parser:flag "--enable-ssl",
                parser:option "--cert-path"
            )

            local args = parser:parse { "--enable-ssl", "--cert-path", "/path/to/cert" }
            assert.same({ enable_ssl = true, cert_path = "/path/to/cert" }, args)

            assert.has_error(function()
                parser:parse { "--enable-ssl" }
            end, "option '--enable-ssl' requires option '--cert-path'")
        end)

        it("handles mutin with arguments", function()
            local parser = Parser()
            parser:mutin(
                parser:argument "source",
                parser:argument "destination"
            )

            local args = parser:parse { "src.txt", "dst.txt" }
            assert.same({ source = "src.txt", destination = "dst.txt" }, args)

            assert.has_error(function()
                parser:parse { "src.txt" }
            end, "missing argument 'destination'")
        end)

        it("handles multiple mutins", function()
            local parser = Parser()
            parser:mutin(
                parser:option "--host",
                parser:option "--port"
            )
            parser:mutin(
                parser:option "--username",
                parser:option "--password"
            )

            local args = parser:parse { "--host", "localhost", "--port", "8080" }
            assert.same({ host = "localhost", port = "8080" }, args)

            assert.has_error(function()
                parser:parse { "--host", "localhost", "--username", "john" }
            end, "option '--host' requires option '--port'")
        end)

        it("shows correct error for multiple elements in mutin", function()
            local parser = Parser()
            parser:mutin(
                parser:option "-a",
                parser:option "-b",
                parser:option "-c"
            )

            assert.has_error(function()
                parser:parse { "-a", "1", "-b", "2" }
            end, "option '-a' and option '-b' require option '-c'")
        end)
    end)
end)
