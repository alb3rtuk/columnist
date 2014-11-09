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