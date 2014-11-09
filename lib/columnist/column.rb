require 'colored'

module Columnist
    class Column
        include OptionsValidator

        VALID_OPTIONS = [:width, :padding, :align, :color, :bold, :underline, :reversed]
        attr_accessor :text, :size, *VALID_OPTIONS

        def initialize(text = nil, options = {})
            self.validate_options(options, *VALID_OPTIONS)
            self.text = text.to_s
            self.width = options[:width] || 10
            self.align = options[:align] || 'left'
            self.padding = options[:padding] || 0
            self.color = options[:color] || nil
            self.bold = options[:bold] || false
            self.underline = options[:underline] || false
            self.reversed = options[:reversed] || false

            raise ArgumentError unless self.width > 0
            raise ArgumentError unless self.padding.to_s.match(/^\d+$/)
        end

        def size
            self.width - 2 * self.padding
        end

        def required_width
            self.text.to_s.size + 2 * self.padding
        end

        def screen_rows
            if self.text.nil? || self.text.empty?
                [' ' * self.width]
            else
                self.text.scan(/.{1,#{self.size}}/m).map { |s| to_cell(s) }
            end
        end

        private

        def to_cell(str)
            # NOTE: For making underline and reversed work Change so that based on the
            # unformatted text it determines how much spacing to add left and right
            # then colorize the cell text
            cell = str.empty? ? blank_cell : aligned_cell(str)
            padding_str = ' ' * self.padding
            padding_str + colorize(cell) + padding_str
        end

        def blank_cell
            ' ' * self.size
        end

        def aligned_cell(str)
            case self.align
                when 'left'
                    str.ljust(self.size)
                when 'right'
                    str.rjust(self.size)
                when 'center'
                    str.ljust((self.size - str.size)/2.0 + str.size).rjust(self.size)
            end
        end

        def colorize(str)
            str = str.send('bold') if self.bold
            case self.color
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
            if is_number?(self.color)
                str = "\x1B[38;5;#{self.color}m#{str}\x1B[38;5;256m"
            end
            str
        end

        def is_number?(str)
            true if Integer(str) rescue false
        end
    end
end
