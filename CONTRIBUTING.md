# Spin Standard Library Style Guide

Traditionally, Spin has been difficult for inexperienced developers to start with.
This has to change for it to be taken seriously as an educational platform.

This guide has been written to aid in developing a consistent, accessible out-of-the-box
experience of the Spin language.

## Submissions

New object submissions should include demos for readily available reference
hardware. For example:

*   Sample code that runs as-is on a Hackable Electronic Badge
*   Sample code and a circuit schematic for running the code on a Propeller
    Activity Board. Circuit schematics should be PNG and kept under 50kB.

## Naming Conventions

*   Version numbers are not included in a filename. A version comment is
    added with other metadata to the release.

*   File extensions are lower-case.

*   Core object names are lower-case, with individual words separated by periods.
    This prevents issues with OBJ blocks on non-Windows platforms.

        com.serial.object.spin

*   Demos and examples are CamelCase, with no spaces.

        SerialExample.spin

*   Templates are given pretty names, with spaces replaced with underscores.

        Serial_Template.spin

## Organization

The Spin Standard Library is organized into the following folder structure.

    .
    └── library
        ├── demos
        ├── examples
        └── templates

#### library/

The top-level of the library that will be included with PropellerIDE. All core
object additions go here. Anything above this level is not distributed.

These should be named according to their function, and placed into groups. Thus,
the classic FullDuplexSerial object, a serial driver used for I/O, should be renamed to:

    com.serial.fullduplex.spin

If there are other serial drivers, they may be named:

    com.serial.tiny.spin
    com.serial.highspeed.spin
    com.serial.lowspeed.spin
    ...
    ...

##### demos/

These files are organized hierarchically based on the object they demonstrate. Say
we use the object from the previous example.

    com.serial.fullduplex

You should be able to find sample code for it in the following location:

    com/serial/FullDuplex.spin

Or if there are multiple examples:

    com/serial/fullduplex/ThisDemo.spin
    com/serial/fullduplex/ThatDemo.spin

##### examples/

Not all sample code fits neatly into one object or another. For more complex demonstrations that may
use many different objects, the `examples/` folder is used.

This is a good place for demonstrations that will run as-is on a given piece of hardware.

##### templates/

Files included in `templates/` will be available within PropellerIDE's "New From Template" feature. These are 
named how they will appear, with spaces replaced with underscores. Therefore, "Awesome Template v1.0"
should be saved as:

    Awesome_Template_v1.0.spin

## Coding Style

Owing to Spin's similarity to Python, for topics not covered here, please refer
to [PEP-8](https://www.python.org/dev/peps/pep-0008/) where appropriate.

In no particular order:

*   Skip one line after declaring a block and before starting a new one; no more, no less.

    Yes:

        PUB Foo

            Bar

        PUB Biz

            Boo

    No:

        PUB Foo
            Bar
        PUB Biz
        


            Boo 

*   Use **4** spaces for indentation.

*   Always *indent* inside of blocks. Existing Spin compilers do not require this
    but failing to do so produces hard-to-read code.

    Yes:

        PUB Foo

            Bar
            Baz

    No:

        PUB Foo

        Bar
        Baz
      
*   Treat all files as case-sensitive. Spin does not require this but it is good practice
    anyway.

*   Always capitalize the same way.

      *   Blocks and constants are upper-case (`PUB`, `CON`, ...).

      *   Variables, labels, and non-block keywords are lower-case (`offsetx`, `temp`, ...).

      *   Function names are CamelCase (`DoSomething`, `EnableFeature`, ...).

*   Avoid extraneous spaces in code.

*   Avoid excessive commenting; only comment individual lines of code when necessary.

*   **Do not** add licensing stubs or header information. This information is automatically
    added to software releases from the repository itself.

*   **Do** add documentation comments after function block declarations. These will be
    rendered into documentation in later PropellerIDE releases.

        PUB ThisFunction(val, val2)
        '' This is an interesting function

            HereIsTheCode
            MoreCode(val2)
            val += 2

*   **Do** use markdown syntax in documentation comments.

*   Do not use Parallax font-specific special characters or in-source schematic diagrams.
    This feature is not portable and will be removed from PropellerIDE in the future.
    Since PropellerIDE will support markdown documentation, it is recommended to draw
    pictures of any diagrams and add them to a folder called `images/` in the same folder
    as the object.

    For an illustration in a core object:

        com.serial.fullduplex.spin
        images/com/serial/fullduplex/img1.png

    For a demo object:

        com/serial/fullduplex/FullDuplex.spin
        com/serial/fullduplex/images/img1.png

## Questions?

Please submit any questions or feedback you have to the
[issue tracker](https://github.com/parallaxinc/spin-standard-library/issues). 
