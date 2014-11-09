## Columnist

This gem provides a DSL that makes it easy to write reports of various types in ruby. It eliminates
the need to litter your source with `puts` statements, instead providing a more readable, expressive
interface to your application. Some of the best features include:

* Formatters that automatically indicate progress
* Table syntax similar to HTML that makes it trivial to format your data in rows and columns
* Easily created headers and footers for your report
* Output suppression that makes it easy for your script to support a `quiet` flag
* Capture report output as a string

The latest release allows you to choose between UTF8 or ASCII for drawing tables. By default it will
use UTF8 if your system supports it.

Here is an example of output you can generate easily with **Columnist**:

![Screenshot](https://raw.githubusercontent.com/alb3rtuk/columnist/master/examples/screenshot-1.png)

### Installation

It is up on rubygems.org so add it to your bundle in the Gemfile..

```bash
gem 'columnist', '>=1.0'
```

Or do it the old fashioned way..

```bash
gem install columnist
```

### Usage

The gem provides a mixin that can be included in your script as follows:

```ruby
require 'columnist'

class YourClass
  include Columnist
  ...
end
```

The best way to get an idea of how it works is to look at an example program:

```ruby
require 'columnist'

class Example
    include Columnist

    def run
        table(:border => true, :border_color => 39) do
            row do
                column('NAME', :width => 20)
                column('ADDRESS', :width => 30)
                column('CITY', :width => 25, :align => 'right')
            end
            row do
                column('Dean Linden', :color => 'magenta')
                column('12 Appian Way', :color => 'magenta')
                column('New York')
            end
            row do
                column('Ross Joy')
                column('24 Golden Gate Road')
                column('San Francisco')
            end
            row do
                column('Tommy Booy', :color => 202)
                column('6210 Crenshaw', :color => 202)
                column('Los Angeles')
            end
        end
    end
end

Example.new.run
```

The above code will output the following result:

![Screenshot](https://raw.githubusercontent.com/alb3rtuk/columnist/master/examples/screenshot-3.png)

### Color Reference

**Columnist** has 256-color support! Use the chart below for reference.

![Screenshot](https://raw.githubusercontent.com/alb3rtuk/columnist/master/examples/screenshot-2.png)

### API Reference

There are several methods the mixin provides that do not depend on the formatter used:

* **header(hash)** and **footer(hash)**
  * **:title** - The title text for the section. **Default: 'Report'**
  * **:width** - The width in characters for the section. **Default: 100**
  * **:align** - 'left'|'right'|'center' align the title text. **Default: 'left'**
  * **:spacing** - Number of vertical lines to leave as spacing after|before the header|footer.
   **Default: 1**
  * **:timestamp** - Include a line indicating the timestamp below|above the header|footer text.
    Either true|false. **Default: false**
  * **:rule** - true|false indicates whether to include a horizontal rule below|above the
    header|footer. **Default: false**
  * **:color** - The color to use for the terminal output i.e. 'red' or 'blue' or 'green'
  * **:bold** - true|false to boldface the font
* **report(hash) {block}**
  * The first argument is a hash that defines the options for the method. See the details in the
    formatter section for allowed values.
  * The second argument is a block of ruby code that you want executed within the context of the
    reporter. Any ruby code is allowed. See the examples that follow in the formatter sections for
    details.
* **formatter=(string)**
  * Factory method indicating the formatter you want your application to use. At present the 2
    formatters are (**Default: 'nested'**):
  * 'progress' - Use the progress formatter
  * 'nested' - Use the nested (or documentation) formatter
* **horizontal_rule(hash)**
  * **:char** - The character used to build the rule. **Default: '-'**
  * **:width** - The width in characters of the rule. **Default: 100**
  * **:color** - The color to use for the terminal output i.e. 'red' or 'blue' or 'green'
  * **:bold** - true|false to boldface the font
* **vertical_spacing(int)**
  * Number of blank lines to output. **Default: 1**
* **datetime(hash)**
  * **:align** - 'left'|'center'|'right' alignment of the timestamp. **Default: 'left'**
  * **:width** - The width of the string in characters. **Default: 100**
  * **:format** - Any allowed format from #strftime#. **Default: %Y-%m-%d %H:%I:%S%p**
  * **:color** - The color to use for the terminal output i.e. 'red' or 'blue' or 'green'
  * **:bold** - true|false to boldface the font
* **aligned(string, hash)**
  * **text** - String to display
  * **:align** - 'left'|'right'|'center' align the string text. **Default: 'left'**
  * **:width** - The width in characters of the string text. **Default: 100**
  * **:color** - The color to use for the terminal output i.e. 'red' or 'blue' or 'green'
  * **:bold** - true|false to boldface the font
* **table(hash) {block}**
  * The first argument is a hash that defines properties of the table.
    * **:border** - true|false indicates whether to include borders around the table cells
    * **:encoding** - :ascii or :unicode (default unicode)
  * The second argument is a block which includes calls the to the**row**method
* **row {block}**
  * **:header** - Set to true to indicate if this is a header row in the table.
  * **:color** - The color to use for the terminal output i.e. 'red' or 'blue' or 'green'
  * **:bold** - true|false to boldface the font
* **column(string, hash)**
  * **text** - String to display in the table cell
  * **options** - The options to define the column
    * :width - defines the width of the column
    * :padding - The number of spaces to put on both the left and right of the text.
    * :align - Allowed values are left|right|center
    * :color - The color to use for the terminal output i.e. 'red' or 'blue' or 'green'
    * :bold - true|false to boldface the font
* **suppress_output** - Suppresses output stream that goes to STDOUT
* **capture_output** - Captures all of the output stream to a string and restores output to STDOUT
* **restore_output** - Restores the output stream to STDOUT

## Original

The original gem, created by [Wes Bailey](https://github.com/wbailey), can be found here:
[https://github.com/wbailey/command_line_reporter](https://github.com/wbailey/command_line_reporter)