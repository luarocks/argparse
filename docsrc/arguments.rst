Adding and configuring arguments
================================

Positional arguments can be added using ``:argument(name, description, default, convert, args)`` method. It returns an Argument instance, which can be configured in the same way as Parsers. The ``name`` property is required.

This and the following examples show contents of the result table returned by `parser:parse()` when the script is executed with given command-line arguments.

.. code-block:: lua
   :linenos:

   parser:argument "input"

.. code-block:: none

   $ lua script.lua foo

.. code-block:: lua

   {
      input = "foo"
   }

The data passed to the argument is stored in the result table at index ``input`` because it is the argument's name. The index can be changed using ``target`` property.

Setting number of consumed arguments
------------------------------------

``args`` property sets how many command line arguments the argument consumes. Its value is interpreted as follows:

================================================= =============================
Value                                             Interpretation
================================================= =============================
Number ``N``                                      Exactly ``N`` arguments
String ``A-B``, where ``A`` and ``B`` are numbers From ``A`` to ``B`` arguments
String ``N+``, where ``N`` is a number            ``N`` or more arguments
String ``?``                                      An optional argument
String ``*``                                      Any number of arguments
String ``+``                                      At least one argument
String ``...``                                    All remaining arguments
================================================= =============================

If more than one argument can be consumed, a table is used to store the data.

.. code-block:: lua
   :linenos:

   parser:argument("pair", "A pair of arguments.")
      :args(2)
   parser:argument("optional", "An optional argument.")
      :args "?"

.. code-block:: none

   $ lua script.lua foo bar

.. code-block:: lua

   {
      pair = {"foo", "bar"}
   }

.. code-block:: none

   $ lua script.lua foo bar baz

.. code-block:: lua

   {
      pair = {"foo", "bar"},
      optional = "baz"
   }

Setting argument choices
------------------------

The ``choices`` property can be used to restrict an argument to a set of choices. Its value is an array of string choices.

.. code-block:: lua
   :linenos:

   parser:argument "direction"
      :choices {"north", "south", "east", "west"}

.. code-block:: none

   $ lua script.lua foo

.. code-block:: none

   Usage: script.lua [-h] {north,south,east,west}

   Error: argument 'direction' must be one of 'north', 'south', 'east', 'west'

The ``...`` value can be used to capture all remaining command-line arguments, including options-like tokens. This is useful when passing arguments through to another command.

.. code-block:: lua
   :linenos:

   parser:argument "pass_through"
      :args "..."

.. code-block:: none

   $ lua script.lua foo --bar baz

.. code-block:: lua

   {
      pass_through = {"foo", "--bar", "baz"}
   }
