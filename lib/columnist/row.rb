module Columnist
    class Row
        include OptionsValidator

        VALID_OPTIONS = [:header, :color, :border_color, :bold, :encoding]
        attr_accessor :columns, :border, *VALID_OPTIONS

        def initialize(options = {})
            self.validate_options(options, *VALID_OPTIONS)
            self.columns = []
            self.border = false
            self.header = options[:header] || false
            self.color = options[:color]
            self.border_color = options[:border_color]
            self.bold = options[:bold] || false
            self.encoding = options[:encoding] || :unicode
        end

        def add(column)
            if column.color.nil? && self.color
                column.color = self.color
            end

            if self.bold || self.header
                column.bold = true
            end

            self.columns << column
        end

        def output
            screen_count.times do |sr|
                border_char = use_utf8? ? "\u2503" : '|'
                border_char = colorize(border_char, self.border_color)
                line = (self.border) ? "#{border_char} " : ''
                self.columns.size.times do |mc|
                    col = self.columns[mc]
                    # Account for the fact that some columns will have more screen rows than their
                    # counterparts in the row.  An example being:
                    # c1 = Column.new('x' * 50, :width => 10)
                    # c2 = Column.new('x' * 20, :width => 10)
                    #
                    # c1.screen_rows.size == 5
                    # c2.screen_rows.size == 2
                    #
                    # So when we don't have a screen row for c2 we need to fill the screen with the
                    # proper number of blanks so the layout looks like (parenthesis on the right just
                    # indicate screen row index)
                    #
                    # +-------------+------------+
                    # | xxxxxxxxxxx | xxxxxxxxxx | (0)
                    # | xxxxxxxxxxx | xxxxxxxxxx | (1)
                    # | xxxxxxxxxxx |            | (2)
                    # | xxxxxxxxxxx |            | (3)
                    # | xxxxxxxxxxx |            | (4)
                    # +-------------+------------+
                    if col.screen_rows[sr].nil?
                        line << ' ' * col.width
                    else
                        line << self.columns[mc].screen_rows[sr]
                    end
                    line << ' ' + ((self.border) ? "#{border_char} " : '')
                end
                puts line
            end
        end

        private

        def screen_count
            @sc ||= self.columns.inject(0) { |max, column| column.screen_rows.size > max ? column.screen_rows.size : max }
        end

        def use_utf8?
            self.encoding == :unicode && "\u2501" != "u2501"
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
