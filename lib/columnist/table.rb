module Columnist
    class Table
        include OptionsValidator

        VALID_OPTIONS = [:border, :border_color, :width, :encoding]
        attr_accessor :rows, *VALID_OPTIONS

        def initialize(options = {})
            self.validate_options(options, *VALID_OPTIONS)
            self.border       = options[:border] || false
            self.border_color = options[:border_color] || false
            self.width        = options[:width] || false
            self.encoding     = options[:encoding] || Columnist::DEFAULTS[:encoding]
            @rows             = []
            raise ArgumentError, 'Invalid encoding' unless [:ascii, :unicode].include? self.encoding
        end

        def add(row)
            # Inheritance from the table
            row.border       = self.border
            row.border_color = self.border_color

            # Inherit properties from the appropriate row
            inherit_column_attrs(row) if self.rows[0]

            self.rows << row
        end

        def output
            return if self.rows.size == 0 # we got here with nothing to print to the screen
            auto_adjust_widths if self.width == :auto

            puts separator('first') if self.border
            self.rows.each_with_index do |row, index|
                row.output
                puts separator('middle') if self.border && (index != self.rows.size - 1)
            end
            puts separator('last') if self.border
        end

        def auto_adjust_widths
            column_widths = []

            self.rows.each do |row|
                row.columns.each_with_index do |col, i|
                    column_widths[i] = [col.required_width, (column_widths[i] || 0)].max
                end
            end

            self.rows.each do |row|
                row.columns.each_with_index do |col, i|
                    col.width = column_widths[i]
                end
            end
        end

        private

        def separator(type = 'middle')
            left, center, right, bar = use_utf8? ? utf8_separator(type) : ascii_separator
            separator_str            = left + self.rows[0].columns.map { |c| bar * (c.width + 2) }.join(center) + right
            separator_str            = colorize(separator_str, self.border_color)
        end

        def use_utf8?
            self.encoding == :unicode && "\u2501" != "u2501"
        end

        def ascii_separator
            left = right = center = '+'
            bar  = '-'
            [left, right, center, bar]
        end

        def utf8_separator(type)
            bar = "\u2501"

            left, center, right = case type
                                      when 'first'
                                          ["\u250F", "\u2533", "\u2513"]
                                      when 'middle'
                                          ["\u2523", "\u254A", "\u252B"]
                                      when 'last'
                                          ["\u2517", "\u253B", "\u251B"]
                                  end

            [left, center, right, bar]
        end

        def inherit_column_attrs(row)
            row.columns.each_with_index do |c, i|
                use_positional_attrs(c, i)
                use_color(row, c, i)
                use_bold(row, c, i)
            end
        end

        def use_positional_attrs(c, i)
            # The positional attributes are always required to inheret to make sure the table
            # displays properly
            %w{align padding width}.each do |attr|
                val = self.rows[0].columns[i].send(attr)
                c.send(attr + "=", val)
            end
        end

        def inherit_from
            self.rows[0].header ? 1 : 0
        end

        def use_color(row, c, i)
            if c.color
                # keep default
            elsif row.color
                c.color = row.color
            elsif inherit_from != 1
                c.color = self.rows[inherit_from].columns[i].color
            end
        end

        def use_bold(row, c, i)
            if row.bold
                c.bold = row.bold
            elsif inherit_from != 1
                c.bold = self.rows[inherit_from].columns[i].bold
            end
        end

        def colorize(str, color)
            case color
                when 'red'
                    return "\x1B[38;5;9m#{str}\x1B[38;5;256m"
                when 'green'
                    return "\x1B[38;5;10m#{str}\x1B[38;5;256m"
                when 'yellow'
                    return "\x1B[38;5;11m#{str}\x1B[38;5;256m"
                when 'blue'
                    return "\x1B[38;5;33m#{str}\x1B[38;5;256m"
                when 'magenta'
                    return "\x1B[38;5;13m#{str}\x1B[38;5;256m"
                when 'cyan'
                    return "\x1B[38;5;14m#{str}\x1B[38;5;256m"
                when 'gray'
                    return "\x1B[38;5;240m#{str}\x1B[38;5;256m"
                when 'white'
                    return "\x1B[38;5;255m#{str}\x1B[38;5;256m"
                when 'black'
                    return "\x1B[38;5;0m#{str}\x1B[38;5;256m"
            end
            if is_number?(color)
                str = "\x1B[38;5;#{color}m#{str}\x1B[38;5;256m"
            end
            str
        end

        def is_number?(str)
            true if Integer(str) rescue false
        end

    end
end
