Mutual groups
=============

The argparse library supports two types of mutual groups: mutually exclusive groups (mutex) and mutually inclusive groups (mutin).

Mutually exclusive groups (mutex)
---------------------------------

A group of arguments and options can be marked as mutually exclusive using ``:mutex(argument_or_option, ...)`` method of the Parser class. If more than one element of a mutually exclusive group is used, an error is raised.

.. code-block:: lua
   :linenos:

   parser:mutex(
      parser:argument "input"
         :args "?",
      parser:flag "--process-stdin"
   )
   parser:mutex(
      parser:flag "-q --quiet",
      parser:flag "-v --verbose"
   )

.. code-block:: none

   $ lua script.lua -qv

.. code-block:: none

   Usage: script.lua ([-q] | [-v]) [-h] ([<input>] | [--process-stdin])

   Error: option '-v' can not be used together with option '-q'

.. code-block:: none

   $ lua script.lua file --process-stdin

.. code-block:: none

   Usage: script.lua ([-q] | [-v]) [-h] ([<input>] | [--process-stdin])

   Error: option '--process-stdin' can not be used together with argument 'input'

Mutually inclusive groups (mutin)
---------------------------------

A group of arguments and options can be marked as mutually inclusive using ``:mutin(argument_or_option, ...)`` method of the Parser class. If any element of a mutually inclusive group is used, all other elements must be used as well.

.. code-block:: lua
   :linenos:

   parser:mutin(
      parser:option "--username",
      parser:option "--password"
   )
   parser:mutin(
      parser:option "--host",
      parser:option "--port"
         :convert(tonumber)
   )

.. code-block:: none

   $ lua script.lua --username john

.. code-block:: none

   Usage: script.lua [-h] [--username USERNAME] [--password PASSWORD] [--host HOST] [--port PORT]

   Error: option '--username' requires option '--password'

.. code-block:: none

   $ lua script.lua --host localhost --port 8080 --username john --password secret

.. code-block:: lua

   {
      host = "localhost",
      port = 8080,
      username = "john",
      password = "secret"
   }

Unlike mutex groups, mutin groups are not shown in the usage message as they don't restrict which combinations can be used, only that certain options must appear together.
